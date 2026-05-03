part of 'connection_bloc.dart';

// Base class for all connection events
abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

// Event to load the complete network summary (followers + following)
class LoadConnectionSummary extends ConnectionEvent {
  final String targetUsername;

  const LoadConnectionSummary({required this.targetUsername});

  @override
  List<Object?> get props => [targetUsername];
}

// Event to silently refresh the complete network summary
class RefreshConnectionSummary extends ConnectionEvent {
  final String targetUsername;

  const RefreshConnectionSummary({required this.targetUsername});

  @override
  List<Object?> get props => [targetUsername];
}

// Event to load ONLY the list of users following a specific user
class LoadUserFollowers extends ConnectionEvent {
  final String targetUsername;

  const LoadUserFollowers({required this.targetUsername});

  @override
  List<Object?> get props => [targetUsername];
}

// Event to silently refresh ONLY the list of users following a specific user
class RefreshUserFollowers extends ConnectionEvent {
  final String targetUsername;

  const RefreshUserFollowers({required this.targetUsername});

  @override
  List<Object?> get props => [targetUsername];
}

// Event to load ONLY the list of users a specific user is following
class LoadUserFollowing extends ConnectionEvent {
  final String targetUsername;

  const LoadUserFollowing({required this.targetUsername});

  @override
  List<Object?> get props => [targetUsername];
}

// Event to silently refresh ONLY the list of users a specific user is following
class RefreshUserFollowing extends ConnectionEvent {
  final String targetUsername;

  const RefreshUserFollowing({required this.targetUsername});

  @override
  List<Object?> get props => [targetUsername];
}

// Event to subscribe to a user
class FollowUser extends ConnectionEvent {
  final String targetUsername;

  const FollowUser({required this.targetUsername});

  @override
  List<Object?> get props => [targetUsername];
}

// Event to unsubscribe from a user
class UnfollowUser extends ConnectionEvent {
  final String targetUsername;

  const UnfollowUser({required this.targetUsername});

  @override
  List<Object?> get props => [targetUsername];
}