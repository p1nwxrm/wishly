part of 'my_profile_bloc.dart';

// Base class for all MyProfile events
abstract class MyProfileEvent extends Equatable {
  const MyProfileEvent();

  @override
  List<Object?> get props => [];
}

// Event to load the current user's full profile initially
class LoadMyProfile extends MyProfileEvent {
  final String username;

  const LoadMyProfile({required this.username});

  @override
  List<Object?> get props => [username];
}

// Event to silently refresh the current user's profile (e.g., Pull-to-Refresh)
class RefreshMyProfile extends MyProfileEvent {
  final String username;

  const RefreshMyProfile({required this.username});

  @override
  List<Object?> get props => [username];
}