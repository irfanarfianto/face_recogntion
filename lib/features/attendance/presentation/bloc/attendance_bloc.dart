import 'package:camera/camera.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/attendance_log_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/authenticate_user.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/delete_user.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/get_attendance_logs.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/get_all_users.dart';
import 'package:test_face_recognition/features/attendance/domain/usecases/register_user.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final RegisterUser registerUser;
  final AuthenticateUser authenticateUser;
  final GetAttendanceLogs getAttendanceLogs;
  final GetAllUsers getAllUsers;
  final DeleteUser deleteUser;
  final AttendanceRepository repository;

  AttendanceBloc({
    required this.registerUser,
    required this.authenticateUser,
    required this.getAttendanceLogs,
    required this.getAllUsers,
    required this.deleteUser,
    required this.repository,
  }) : super(const AttendanceState()) {
    on<LoadThresholdEvent>((event, emit) async {
      final threshold = await repository.getThreshold();
      emit(state.copyWith(threshold: threshold));
    });

    on<UpdateThresholdEvent>((event, emit) async {
      await repository.setThreshold(event.newThreshold);
      emit(
        state.copyWith(
          threshold: event.newThreshold,
          status: AttendanceStatus.thresholdUpdated,
        ),
      );
    });

    on<RegisterEvent>((event, emit) async {
      emit(state.copyWith(status: AttendanceStatus.loading));
      final result = await registerUser(event.name, event.image);
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: AttendanceStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (user) => emit(
          state.copyWith(status: AttendanceStatus.registered, user: user),
        ),
      );
    });

    on<AuthenticateEvent>((event, emit) async {
      emit(state.copyWith(status: AttendanceStatus.loading));
      final result = await authenticateUser(event.image);
      result.fold(
        (failure) {
          double? distance;
          if (failure is AuthenticationFailure) {
            distance = failure.matchDistance;
          }
          emit(
            state.copyWith(
              status: AttendanceStatus.failure,
              errorMessage: failure.message,
              lastDistance: distance,
            ),
          );
        },
        (resultTuple) {
          final user = resultTuple.$1;
          final distance = resultTuple.$2;
          final attributes = resultTuple.$3;
          final embedding = resultTuple.$4;
          final thresholdUsed = resultTuple.$5;

          // Use the threshold returned by the repository to ensure consistency
          if (distance < thresholdUsed) {
            emit(
              state.copyWith(
                status: AttendanceStatus.authenticated,
                user: user,
                lastDistance: distance,
                capturedImagePath: event.image.path,
                faceAttributes: attributes,
                capturedEmbedding: embedding,
                threshold: thresholdUsed, // Update state with used threshold
              ),
            );
          } else {
            // It is a mismatch, but we have the data
            emit(
              state.copyWith(
                status: AttendanceStatus.failure,
                user: user, // The closest user
                lastDistance: distance,
                capturedImagePath: event.image.path,
                faceAttributes: attributes,
                capturedEmbedding: embedding,
                threshold: thresholdUsed, // Update state with used threshold
                errorMessage:
                    'Wajah tidak cocok (Score: ${distance.toStringAsFixed(4)})',
              ),
            );
          }
        },
      );
    });

    on<LoadLogsEvent>((event, emit) async {
      emit(state.copyWith(status: AttendanceStatus.loading));
      final result = await getAttendanceLogs();
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: AttendanceStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (logs) => emit(
          state.copyWith(status: AttendanceStatus.logsLoaded, logs: logs),
        ),
      );
    });

    on<LoadUsersEvent>((event, emit) async {
      emit(state.copyWith(status: AttendanceStatus.loading));
      final result = await getAllUsers();
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: AttendanceStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (users) => emit(
          state.copyWith(status: AttendanceStatus.usersLoaded, allUsers: users),
        ),
      );
    });

    on<DeleteUserEvent>((event, emit) async {
      emit(state.copyWith(status: AttendanceStatus.loading));
      final result = await deleteUser(event.userId);
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: AttendanceStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (_) {
          // After successful deletion, reload the user list
          add(LoadUsersEvent());
          // Optionally emit a temporary deleted status if needed for snackbar,
          // but reloading triggers loading status anyway.
          // Let's emit userDeleted just to be safe for UI listeners if any
          emit(state.copyWith(status: AttendanceStatus.userDeleted));
        },
      );
    });
  }
}
