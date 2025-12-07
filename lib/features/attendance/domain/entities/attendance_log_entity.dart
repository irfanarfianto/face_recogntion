import 'package:equatable/equatable.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';

class AttendanceLogEntity extends Equatable {
  final String id;
  final String userName;
  final DateTime scanTime;
  final double? matchScore;
  final String? imageUrl; // Captured image
  final String? enrolledImageUrl; // From registration
  final FaceAttributes? faceAttributes;
  final double? threshold;

  const AttendanceLogEntity({
    required this.id,
    required this.userName,
    required this.scanTime,
    this.matchScore,
    this.imageUrl,
    this.enrolledImageUrl,
    this.faceAttributes,
    this.threshold,
  });

  @override
  List<Object?> get props => [
    id,
    userName,
    scanTime,
    matchScore,
    imageUrl,
    enrolledImageUrl,
    faceAttributes,
    threshold,
  ];
}
