import 'package:dartz/dartz.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';
import 'package:camera/camera.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/attendance_log_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';

abstract class AttendanceRepository {
  /// Registrasi user baru dengan wajah
  Future<Either<Failure, UserEntity>> registerUser(String name, XFile image);

  /// Verifikasi wajah user untuk absensi
  /// Mengembalikan [(UserEntity, double, FaceAttributes, List<double>, double)]
  /// jika match (User + Distance Score + Attributes + Embedding + ThresholdUsed)
  Future<
    Either<Failure, (UserEntity, double, FaceAttributes, List<double>, double)>
  >
  authenticateUser(XFile image);

  /// Get all users
  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  Future<double> getThreshold();
  Future<void> setThreshold(double value);

  Future<Either<Failure, List<AttendanceLogEntity>>> getAttendanceLogs();

  Future<Either<Failure, void>> deleteUser(String userId);
}
