import 'package:dartz/dartz.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/domain/repositories/attendance_repository.dart';

class DeleteUser {
  final AttendanceRepository repository;

  DeleteUser(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.deleteUser(userId);
  }
}
