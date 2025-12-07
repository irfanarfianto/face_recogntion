part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class RegisterEvent extends AttendanceEvent {
  final String name;
  final XFile image;

  const RegisterEvent(this.name, this.image);
}

class AuthenticateEvent extends AttendanceEvent {
  final XFile image;

  const AuthenticateEvent(this.image);
}

class UpdateThresholdEvent extends AttendanceEvent {
  final double newThreshold;

  const UpdateThresholdEvent(this.newThreshold);
}

class LoadThresholdEvent extends AttendanceEvent {}

class LoadLogsEvent extends AttendanceEvent {}

class LoadUsersEvent extends AttendanceEvent {}

class DeleteUserEvent extends AttendanceEvent {
  final String userId;
  const DeleteUserEvent(this.userId);
}
