part of 'public_profile_bloc.dart';

abstract class PublicProfileEvent extends Equatable {
  const PublicProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadPublicProfile extends PublicProfileEvent {
  final String username;
  const LoadPublicProfile({required this.username});

  @override
  List<Object?> get props => [username];
}

class RefreshPublicProfile extends PublicProfileEvent {
  final String username;
  const RefreshPublicProfile({required this.username});

  @override
  List<Object?> get props => [username];
}

// Event to update the follow status locally without a network request
class UpdateProfileFollowStatus extends PublicProfileEvent {
  final bool isNowFollowing;

  const UpdateProfileFollowStatus({required this.isNowFollowing});

  @override
  List<Object?> get props => [isNowFollowing];
}