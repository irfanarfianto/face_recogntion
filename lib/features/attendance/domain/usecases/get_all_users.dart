import 'package:dartz/dartz.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/repositories/attendance_repository.dart';

class GetAllUsers {
  final AttendanceRepository repository;

  GetAllUsers(this.repository);

  Future<Either<Failure, List<UserEntity>>> call() async {
    return await repository.getAllUsers();
  }
}
