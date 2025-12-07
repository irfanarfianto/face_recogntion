import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/repositories/attendance_repository.dart';

class RegisterUser {
  final AttendanceRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, UserEntity>> call(String name, XFile image) async {
    return await repository.registerUser(name, image);
  }
}
