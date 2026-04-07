part of 'user_bloc.dart';

// Base class for all user events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

// Event to load the currently authenticated user's profile
class LoadCurrentUser extends UserEvent {}

// Event to instantly load the user profile using pre-fetched data
class PreloadUser extends UserEvent {
  final UserModel user;

  const PreloadUser({required this.user});

  @override
  List<Object> get props => [user];
}

// Event to load a specific user's profile by their ID
class LoadUserById extends UserEvent {
  final int userId;

  const LoadUserById({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Event to update the current user's profile
class UpdateCurrentUser extends UserEvent {
  final UserUpdateModel updateModel;

  const UpdateCurrentUser({required this.updateModel});

  @override
  List<Object?> get props => [updateModel];
}