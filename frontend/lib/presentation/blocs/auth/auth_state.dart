part of 'auth_bloc.dart';

// Base state class for authentication
abstract class AuthState {}

// Initial state when the app starts or the screen is opened
class AuthInitial extends AuthState {}

// State indicating that a network request is in progress (show loader)
class AuthLoading extends AuthState {}

// State indicating successful authentication (navigate to home)
class AuthSuccess extends AuthState {}

// State indicating an error occurred (show snackbar or error text)
class AuthFailure extends AuthState {
  final String errorMessage;

  AuthFailure({required this.errorMessage});
}