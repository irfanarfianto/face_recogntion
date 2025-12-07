import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:test_face_recognition/core/error/failures.dart';

import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';

abstract class FaceLocalDataSource {
  Future<void> loadModel();
  Future<(List<double>, FaceAttributes)> getFaceEmbedding(XFile imageFile);
}

class FaceLocalDataSourceImpl implements FaceLocalDataSource {
  Interpreter? _interpreter;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
  );

  @override
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/tflite/mobilefacenet.tflite',
      );
    } catch (e) {
      throw const FaceDetectionFailure('Failed to load face recognition model');
    }
  }

  @override
  Future<(List<double>, FaceAttributes)> getFaceEmbedding(
    XFile imageFile,
  ) async {
    if (_interpreter == null) await loadModel();

    // 1. Detect Face
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      throw const FaceDetectionFailure('No face detected');
    }

    // Ambil wajah terbesar/pertama
    final face = faces.first;

    // 2. Crop Face from Image
    final bytes = await File(imageFile.path).readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw const FaceDetectionFailure('Failed to decode image');
    }

    // Crop area wajah
    int x = face.boundingBox.left.toInt();
    int y = face.boundingBox.top.toInt();
    int w = face.boundingBox.width.toInt();
    int h = face.boundingBox.height.toInt();

    // Ensure crop is within image bounds
    x = max(0, x);
    y = max(0, y);
    w = min(w, originalImage.width - x);
    h = min(h, originalImage.height - y);

    img.Image croppedFace = img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: w,
      height: h,
    );

    // 3. Preprocess Image (Resize to 112x112 for MobileFaceNet)
    img.Image resizedFace = img.copyResize(
      croppedFace,
      width: 112,
      height: 112,
    );

    // 4. Convert to List [1, 112, 112, 3]
    var input = _imageToInputList(resizedFace);

    // 5. Inference
    // Output MobileFaceNet: [1, 192]
    List<List<double>> outputBuffer = List.generate(
      1,
      (index) => List.filled(192, 0.0),
    );

    // Run inference
    _interpreter!.run(input, outputBuffer);

    // Extract attributes
    final attributes = FaceAttributes(
      yaw: face.headEulerAngleY,
      roll: face.headEulerAngleZ,
      pitch: face.headEulerAngleX,
      smilingProbability: face.smilingProbability,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
    );

    return (outputBuffer[0], attributes);
  }

  /// Convert Image to 4D List [1, 112, 112, 3]
  List<List<List<List<double>>>> _imageToInputList(img.Image image) {
    var input = List.generate(
      1,
      (i) => List.generate(
        112,
        (y) => List.generate(112, (x) => List.filled(3, 0.0)),
      ),
    );

    for (var y = 0; y < 112; y++) {
      for (var x = 0; x < 112; x++) {
        var pixel = image.getPixel(x, y);

        // Normalized to -1..1 or (x-128)/128
        // Assuming image v4 logic for Pixel object access
        num r = pixel.r;
        num g = pixel.g;
        num b = pixel.b;

        input[0][y][x][0] = (r - 128) / 128.0;
        input[0][y][x][1] = (g - 128) / 128.0;
        input[0][y][x][2] = (b - 128) / 128.0;
      }
    }
    return input;
  }
}
