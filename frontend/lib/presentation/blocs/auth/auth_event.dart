part of 'auth_bloc.dart';

// Base event class for authentication
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
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
  // Optional photo file
  final File? photoFile;

  const RegisterRequested({
    required this.userModel,
    this.photoFile,
  });

  @override
  List<Object?> get props => [userModel, photoFile];
}

// Event triggered when the user logs out
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// Event triggered when the app starts to check for existing session
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}