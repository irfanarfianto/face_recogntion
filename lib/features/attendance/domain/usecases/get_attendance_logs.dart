import 'package:dartz/dartz.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/attendance_log_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/repositories/attendance_repository.dart';

class GetAttendanceLogs {
  final AttendanceRepository repository;

  GetAttendanceLogs(this.repository);

  Future<Either<Failure, List<AttendanceLogEntity>>> call() async {
    return await repository.getAttendanceLogs();
  }
}
