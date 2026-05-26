part of 'auth_bloc.dart';

// Base event class for authentication
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Event triggered when the app starts to check for existing session
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// Event triggered when the user attempts to log in
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// Event triggered when the user attempts to register a new account
class RegisterRequested extends AuthEvent {
  final UserCreateModel userModel;
  final File? avatarFile;

  const RegisterRequested({
    required this.userModel,
    this.avatarFile,
  });

  @override
  List<Object?> get props => [userModel, avatarFile];
}

// Event triggered when the user logs out
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// Event triggered when the interceptor detects a dead session.
// This does NOT attempt a network logout, it just kills the local session.
class SessionExpired extends AuthEvent {}
