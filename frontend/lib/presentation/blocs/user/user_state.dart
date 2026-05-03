part of 'user_bloc.dart';

// Base class for all user states
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class UserInitial extends UserState {}

// State showing a loading indicator (e.g., during profile update)
class UserLoading extends UserState {}

// State showing the successfully loaded current user profile
class UserLoaded extends UserState {
  final PrivateUserModel user;

  const UserLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

// State indicating a successful one-time mutation (like profile update)
class UserActionSuccess extends UserState {
  final String message;

  const UserActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// State showing an error message
class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object?> get props => [message];
}