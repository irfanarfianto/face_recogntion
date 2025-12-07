import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:test_face_recognition/core/utils/ml_kit_utils.dart';
import 'package:test_face_recognition/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/loading_analysis_page.dart';
import 'package:test_face_recognition/features/attendance/presentation/widgets/face_painter.dart';
import 'package:test_face_recognition/features/attendance/presentation/widgets/camera_preview_widget.dart';
import 'package:test_face_recognition/features/attendance/presentation/widgets/camera_header_overlay.dart';
import 'package:screen_brightness/screen_brightness.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isBusy = false; // To prevent concurrent processing
  late FaceDetector _faceDetector;
  CameraDescription? _frontCamera;

  // Liveness Detection State
  bool _livenessVerified = false;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();
    // Initialize Face Detector with Classification enabled for Eyes/Smile
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification:
          true, // Enable classification for eye open probability
      minFaceSize: 0.15,
    );
    _faceDetector = FaceDetector(options: options);

    // Load threshold on init
    context.read<AttendanceBloc>().add(LoadThresholdEvent());

    _setBrightness();
    _initializeCamera();
  }

  Future<void> _setBrightness() async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (e) {
      debugPrint("Failed to set brightness: $e");
    }
  }

  Future<void> _resetBrightness() async {
    try {
      await ScreenBrightness().resetApplicationScreenBrightness();
    } catch (e) {
      debugPrint("Failed to reset brightness: $e");
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      _frontCamera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Best for Android ML Kit
    );

    _initializeControllerFuture = _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _startImageStream();
    });
  }

  void _startImageStream() {
    _controller!.startImageStream((CameraImage image) {
      if (_isBusy) return;
      _isBusy = true;
      _processCameraImage(image);
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      final rotation = MLKitUtils.rotationIntToImageRotation(
        _frontCamera!.sensorOrientation,
      );

      final inputImage = MLKitUtils.inputImageFromCameraImage(
        image,
        _frontCamera!,
        rotation,
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;

        // 1. Center Check Logic
        final double imageCenterX = image.width / 2;
        final double imageCenterY = image.height / 2;

        final faceCenter = face.boundingBox.center;

        final dx = (faceCenter.dx - imageCenterX).abs();
        final dy = (faceCenter.dy - imageCenterY).abs();

        final xTolerance = image.width * 0.25;
        final yTolerance = image.height * 0.25;

        final isCentered = dx < xTolerance && dy < yTolerance;

        if (isCentered) {
          // 2. Liveness Detection Logic (Blink)
          if (!_livenessVerified) {
            final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
            final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;

            // Thresholds: Closed < 0.2, Open > 0.5
            if (leftEyeOpen < 0.2 && rightEyeOpen < 0.2) {
              _isBlinking = true; // Eyes are closed
            } else if (_isBlinking && leftEyeOpen > 0.5 && rightEyeOpen > 0.5) {
              // Was blinking, now open -> Blink Completed!
              setState(() {
                _livenessVerified = true;
              });
            }
          } else {
            // 3. Already Verified, Proceed to Scan
            await _stopStreamAndScan();
          }
        }
      }
    } catch (e) {
      debugPrint("Error processing face: $e");
    } finally {
      if (mounted &&
          _controller != null &&
          _controller!.value.isStreamingImages) {
        _isBusy = false;
      }
    }
  }

  Future<void> _stopStreamAndScan() async {
    // 0. Reset Brightness immediately as we are done scanning
    await _resetBrightness();

    // 1. Stop Stream
    await _controller!.stopImageStream();

    if (!mounted) return;

    // 2. Take Picture
    try {
      final xFile = await _controller!.takePicture();

      // 3. Send to Bloc and Navigate
      if (mounted) {
        context.read<AttendanceBloc>().add(AuthenticateEvent(xFile));

        // Push Loading Page using REPLACE
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoadingAnalysisPage()),
        );
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
      // If error, restart stream
      _isBusy = false;
      _livenessVerified = false; // Reset liveness on error retry
      _isBlinking = false;
      _startImageStream();
    }
  }

  @override
  void dispose() {
    _resetBrightness();
    _faceDetector.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          CameraPreviewWidget(
            controller: _controller,
            initializeFuture: _initializeControllerFuture,
          ),

          // 2. Face Painter Overlay
          if (_controller != null && _controller!.value.isInitialized)
            CustomPaint(painter: FacePainter(), child: Container()),

          // 3. Header Overlay
          CameraHeaderOverlay(
            title: 'Scan Wajah',
            onBack: () => Navigator.pop(context),
          ),

          // 4. Bottom Status Overlay
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Loading indicator removed from here, now handled by full screen overlay
                    if (state.lastDistance != null &&
                        state.status != AttendanceStatus.loading)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.lastDistance! < state.threshold
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: state.lastDistance! < state.threshold
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Score: ${state.lastDistance!.toStringAsFixed(4)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Hint text
                    const SizedBox(height: 20),
                    Text(
                      _livenessVerified
                          ? "Tahan posisi..."
                          : (_isBlinking
                                ? "Buka mata Anda..."
                                : "Silakan kedipkan mata untuk verifikasi"),
                      style: const TextStyle(
                        color: Colors.white, // Made brighter for emphasis
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
