import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_face_recognition/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:test_face_recognition/features/attendance/data/datasources/face_local_data_source.dart';
import 'package:test_face_recognition/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:test_face_recognition/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/authenticate_user.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/get_attendance_logs.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/get_all_users.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/delete_user.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/register_user.dart';
import 'package:test_face_recognition/features/attendance/presentation/bloc/attendance_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Attendance
  // Bloc
  sl.registerFactory(
    () => AttendanceBloc(
      registerUser: sl(),
      authenticateUser: sl(),
      getAttendanceLogs: sl(),
      getAllUsers: sl(),
      deleteUser: sl(),
      repository: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => AuthenticateUser(sl()));
  sl.registerLazySingleton(() => GetAttendanceLogs(sl()));
  sl.registerLazySingleton(() => GetAllUsers(sl()));
  sl.registerLazySingleton(() => DeleteUser(sl()));

  // Repository
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<FaceLocalDataSource>(
    () => FaceLocalDataSourceImpl(),
  );

  // ! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Supabase Client
  sl.registerLazySingleton(() => Supabase.instance.client);
}
