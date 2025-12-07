import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/data/models/attendance_log_model.dart';
import 'package:test_face_recognition/features/attendance/data/models/user_model.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';

abstract class AttendanceRemoteDataSource {
  Future<UserModel> registerUser(
    String name,
    List<double> embedding,
    String imagePath,
  );
  Future<List<UserModel>> getAllUsers();
  Future<List<AttendanceLogModel>> getAttendanceLogs();
  Future<void> recordAttendance(
    String userId,
    double matchScore,
    String imagePath,
    FaceAttributes attributes,
    double threshold,
  );
  Future<void> deleteUser(String userId);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final SupabaseClient supabaseClient;

  AttendanceRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> registerUser(
    String name,
    List<double> embedding,
    String imagePath,
  ) async {
    try {
      final imageUrl = await _uploadImage(imagePath, 'users');

      final response = await supabaseClient
          .from('users')
          .insert({
            'name': name,
            'face_embedding': embedding,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw const ServerFailure('Failed to register user to Supabase');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await supabaseClient.from('users').select();

      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerFailure('Failed to fetch users from Supabase');
    }
  }

  @override
  Future<List<AttendanceLogModel>> getAttendanceLogs() async {
    try {
      // Select logs and join with users table to get name
      // Using dynamic to bypass type inference issues temporarily
      final dynamic response = await supabaseClient
          .from('attendance_logs')
          .select('*, users(name, image_url)')
          .order('scan_time', ascending: false);

      if (response == null) return [];

      // Explicit cast to List<dynamic>
      final List<dynamic> data = response as List<dynamic>;

      return data.map((e) => AttendanceLogModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching logs: $e');
      throw const ServerFailure('Failed to fetch logs from Supabase');
    }
  }

  @override
  Future<void> recordAttendance(
    String userId,
    double matchScore,
    String imagePath,
    FaceAttributes attributes,
    double threshold,
  ) async {
    try {
      final imageUrl = await _uploadImage(imagePath, 'attendance_logs/$userId');

      await supabaseClient.from('attendance_logs').insert({
        'user_id': userId,
        'scan_time': DateTime.now().toUtc().toIso8601String(),
        'match_score': matchScore,
        'image_url': imageUrl,
        'face_attributes': {
          'yaw': attributes.yaw,
          'roll': attributes.roll,
          'pitch': attributes.pitch,
          'smilingProbability': attributes.smilingProbability,
          'leftEyeOpenProbability': attributes.leftEyeOpenProbability,
          'rightEyeOpenProbability': attributes.rightEyeOpenProbability,
        },
        'val_threshold': threshold,
      });
    } catch (e) {
      print('Error recording attendance: $e');
      // throw const ServerFailure('Failed to record attendance');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await supabaseClient.from('users').delete().eq('id', userId);
    } catch (e) {
      throw const ServerFailure('Failed to delete user');
    }
  }

  Future<String?> _uploadImage(String imagePath, String folder) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(imagePath);
      final path = '$folder/$fileName';

      await supabaseClient.storage.from('avatars').upload(path, file);

      final imageUrl = supabaseClient.storage
          .from('avatars')
          .getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null; // Return null if upload crashes, so we can still save record without image
    }
  }
}
