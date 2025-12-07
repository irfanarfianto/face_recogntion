import 'package:test_face_recognition/features/attendance/domain/entities/attendance_log_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';

class AttendanceLogModel extends AttendanceLogEntity {
  const AttendanceLogModel({
    required super.id,
    required super.userName,
    required super.scanTime,
    super.matchScore,
    super.imageUrl, // Add to constructor
    super.enrolledImageUrl,
    super.faceAttributes,
    super.threshold,
  });

  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLogModel(
      id: json['id'] ?? '',
      // Accessing nested user data from join
      userName: json['users'] != null
          ? json['users']['name'] ?? 'Unknown'
          : 'Unknown',
      enrolledImageUrl: json['users'] != null
          ? json['users']['image_url']
          : null,
      scanTime: DateTime.parse(json['scan_time']).toLocal(),
      matchScore: (json['match_score'] as num?)?.toDouble(),
      imageUrl: json['image_url'],
      faceAttributes: json['face_attributes'] != null
          ? _parseAttributes(json['face_attributes'])
          : null,
      threshold: (json['val_threshold'] as num?)
          ?.toDouble(), // Using val_threshold to avoid reserved keyword issues if any
    );
  }

  static FaceAttributes? _parseAttributes(dynamic json) {
    if (json is! Map) return null;
    return FaceAttributes(
      yaw: (json['yaw'] as num?)?.toDouble(),
      roll: (json['roll'] as num?)?.toDouble(),
      pitch: (json['pitch'] as num?)?.toDouble(),
      smilingProbability: (json['smilingProbability'] as num?)?.toDouble(),
      leftEyeOpenProbability: (json['leftEyeOpenProbability'] as num?)
          ?.toDouble(),
      rightEyeOpenProbability: (json['rightEyeOpenProbability'] as num?)
          ?.toDouble(),
    );
  }
}
