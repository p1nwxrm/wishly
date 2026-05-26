part of 'user_bloc.dart';

// Base class for all user events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

// Event to instantly load the user profile using pre-fetched data from AuthBloc
class PreloadUser extends UserEvent {
  final PrivateUserModel user;

  const PreloadUser({required this.user});

  @override
  List<Object> get props => [user];
}

// Event to refresh the current user info
class RefreshCurrentUser extends UserEvent {}

// Event to update the current user's profile
class UpdateCurrentUser extends UserEvent {
  final UserUpdateModel updateModel;
  final File? avatarFile;

  const UpdateCurrentUser({
    required this.updateModel,
    this.avatarFile,
  });

  @override
  List<Object?> get props => [updateModel, avatarFile];
}