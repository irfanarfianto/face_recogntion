part of 'attendance_bloc.dart';

enum AttendanceStatus {
  initial,
  loading,
  authenticated,
  registered,
  failure,
  thresholdUpdated,
  logsLoaded,
  usersLoaded,
  userDeleted,
}

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final double threshold;
  final double? lastDistance;
  final List<AttendanceLogEntity> logs;
  final List<UserEntity> allUsers;
  final String? capturedImagePath;
  final FaceAttributes? faceAttributes;
  final List<double>? capturedEmbedding;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.user,
    this.errorMessage,
    this.threshold = 1.0,
    this.lastDistance,
    this.logs = const [],
    this.allUsers = const [],
    this.capturedImagePath,
    this.faceAttributes,
    this.capturedEmbedding,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    UserEntity? user,
    String? errorMessage,
    double? threshold,
    double? lastDistance,
    List<AttendanceLogEntity>? logs,
    List<UserEntity>? allUsers,
    String? capturedImagePath,
    FaceAttributes? faceAttributes,
    List<double>? capturedEmbedding,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      threshold: threshold ?? this.threshold,
      lastDistance: lastDistance ?? this.lastDistance,
      logs: logs ?? this.logs,
      allUsers: allUsers ?? this.allUsers,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      faceAttributes: faceAttributes ?? this.faceAttributes,
      capturedEmbedding: capturedEmbedding ?? this.capturedEmbedding,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    threshold,
    lastDistance,
    logs,
    allUsers,
    capturedImagePath,
    faceAttributes,
    capturedEmbedding,
  ];
}
