import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_face_recognition/features/attendance/presentation/bloc/attendance_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Threshold Akurasi (Jarak)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semakin KECIL nilai, semakin KETAT akurasi (sulit tembus).\nSemakin BESAR nilai, semakin MUDAH (rawan salah orang).',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('0.1'),
                    Expanded(
                      child: Slider(
                        value: state.threshold,
                        min: 0.1,
                        max: 2.0,
                        divisions: 19,
                        label: state.threshold.toStringAsFixed(1),
                        onChanged: (value) {
                          context.read<AttendanceBloc>().add(
                            UpdateThresholdEvent(value),
                          );
                        },
                      ),
                    ),
                    const Text('2.0'),
                  ],
                ),
                Center(
                  child: Text(
                    'Nilai Saat Ini: ${state.threshold.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
