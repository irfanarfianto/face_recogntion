import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';
import 'package:test_face_recognition/features/attendance/domain/repositories/attendance_repository.dart';

class AuthenticateUser {
  final AttendanceRepository repository;

  AuthenticateUser(this.repository);

  Future<
    Either<Failure, (UserEntity, double, FaceAttributes, List<double>, double)>
  >
  call(XFile image) async {
    return await repository.authenticateUser(image);
  }
}
