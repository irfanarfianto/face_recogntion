import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/core/utils/math_utils.dart';
import 'package:test_face_recognition/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:test_face_recognition/features/attendance/data/datasources/face_local_data_source.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/attendance_log_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final FaceLocalDataSource localDataSource;
  final SharedPreferences sharedPreferences;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<
    Either<Failure, (UserEntity, double, FaceAttributes, List<double>, double)>
  >
  authenticateUser(XFile image) async {
    try {
      final (currentEmbedding, attributes) = await localDataSource
          .getFaceEmbedding(image);
      final users = await remoteDataSource.getAllUsers();

      if (users.isEmpty) {
        return const Left(AuthenticationFailure('No registered users found'));
      }

      double minDistance = 100.0;
      UserEntity? closestUser;

      for (var user in users) {
        double distance = MathUtils.euclideanDistance(
          currentEmbedding,
          user.faceEmbedding,
        );
        if (distance < minDistance) {
          minDistance = distance;
          closestUser = user;
        }
      }

      double threshold = await getThreshold();


      if (closestUser != null && minDistance < threshold) {
        // Record attendance log
        await remoteDataSource.recordAttendance(
          closestUser.id,
          minDistance,
          image.path,
          attributes,
          threshold,
        );

        return Right((
          closestUser,
          minDistance,
          attributes,
          currentEmbedding,
          threshold,
        ));
      } else {
        // Also record failure
        if (closestUser != null) {
          await remoteDataSource.recordAttendance(
            closestUser.id,
            minDistance,
            image.path,
            attributes,
            threshold,
          );
          return Right((
            closestUser,
            minDistance,
            attributes,
            currentEmbedding,
            threshold,
          ));
        }

        return Left(
          AuthenticationFailure(
            'Wajah tidak dikenali',
            matchDistance: minDistance,
          ),
        );
      }
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final users = await remoteDataSource.getAllUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerUser(
    String name,
    XFile image,
  ) async {
    try {
      final (embedding, _) = await localDataSource.getFaceEmbedding(image);
      final newUser = await remoteDataSource.registerUser(
        name,
        embedding,
        image.path,
      );
      return Right(newUser);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<double> getThreshold() async {
    return sharedPreferences.getDouble('threshold') ?? 1.0;
  }

  @override
  Future<void> setThreshold(double value) async {
    await sharedPreferences.setDouble('threshold', value);
  }

  @override
  Future<Either<Failure, List<AttendanceLogEntity>>> getAttendanceLogs() async {
    try {
      final logs = await remoteDataSource.getAttendanceLogs();
      return Right(logs);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
