part of 'auth_bloc.dart';

// Base state class for authentication
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state when the app starts or the screen is opened
class AuthInitial extends AuthState {
  const AuthInitial();
}

// State indicating that a network request is in progress (show loader)
class AuthLoading extends AuthState {
  const AuthLoading();
}

// State indicating successful authentication
class AuthSuccess extends AuthState {
  final UserModel? user; // Optional, because standard login might not return it right away

  const AuthSuccess({this.user});

  @override
  List<Object?> get props => [user];
}

// State indicating an error occurred (show snackbar or error text)
class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

// State indicating the user is not logged in (no valid token found)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}