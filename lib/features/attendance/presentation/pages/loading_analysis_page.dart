import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_face_recognition/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/attendance_page.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/result_detail_page.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/result_page.dart';

class LoadingAnalysisPage extends StatefulWidget {
  const LoadingAnalysisPage({super.key});

  @override
  State<LoadingAnalysisPage> createState() => _LoadingAnalysisPageState();
}

class _LoadingAnalysisPageState extends State<LoadingAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state.status == AttendanceStatus.authenticated) {
            // Success Logic
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultPage(
                  isSuccess: true,
                  title: 'Selamat Datang!',
                  message:
                      'Halo, ${state.user?.name}. Presensi berhasil dicatat.',
                  onSeeDetail: () {
                    if (state.user != null &&
                        state.lastDistance != null &&
                        state.capturedImagePath != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultDetailPage(
                            user: state.user!,
                            similarity: state.lastDistance!,
                            capturedImagePath: state.capturedImagePath!,
                            faceAttributes: state.faceAttributes,
                            capturedEmbedding: state.capturedEmbedding,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          } else if (state.status == AttendanceStatus.failure) {
            if (state.lastDistance != null && state.user != null) {
              // Mismatch Case (Recorded Failure)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(
                    isSuccess: false,
                    title: 'Gagal Identifikasi',
                    message:
                        'Wajah terdeteksi mirip ${state.user?.name} (${state.lastDistance!.toStringAsFixed(3)}), namun belum memenuhi standar akurasi (Threshold ${state.threshold}).',
                    onSeeDetail: () {
                      if (state.user != null &&
                          state.lastDistance != null &&
                          state.capturedImagePath != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultDetailPage(
                              user: state.user!,
                              similarity: state.lastDistance!,
                              capturedImagePath: state.capturedImagePath!,
                              faceAttributes: state.faceAttributes,
                              capturedEmbedding: state.capturedEmbedding,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            } else {
              // Generic Failure
              // Show a snackbar or small delay then go back to scan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? "Wajah tidak dikenali"),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );

              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendancePage(),
                    ),
                  );
                }
              });
            }
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Sedang Mencocokkan...",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Menganalisis biometrik wajah",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
