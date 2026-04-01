part of 'auth_bloc.dart';

// Base event class for authentication
abstract class AuthEvent {}

// Event triggered when the user attempts to log in
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

// Event triggered when the user attempts to register a new account
class RegisterRequested extends AuthEvent {
  final UserCreateModel userModel;
  // Optional photo file
  final File? photoFile;

  RegisterRequested({
    required this.userModel,
    this.photoFile,
  });
}

// Event triggered when the user logs out
class LogoutRequested extends AuthEvent {}