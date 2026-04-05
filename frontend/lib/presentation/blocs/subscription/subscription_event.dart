part of 'subscription_bloc.dart';

// Base class for all subscription events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

// Event to load the list of users following a specific user
class LoadUserFollowers extends SubscriptionEvent {
  final int userId;

  const LoadUserFollowers({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Event to load the list of users a specific user is following
class LoadUserFollowing extends SubscriptionEvent {
  final int userId;

  const LoadUserFollowing({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Event to subscribe to a user
class FollowUser extends SubscriptionEvent {
  final int targetUserId;
  final int currentUserId;

  const FollowUser({required this.targetUserId, required this.currentUserId});

  @override
  List<Object?> get props => [targetUserId, currentUserId];
}

// Event to unsubscribe from a user
class UnfollowUser extends SubscriptionEvent {
  final int targetUserId;
  final int currentUserId;

  const UnfollowUser({required this.targetUserId, required this.currentUserId});

  @override
  List<Object?> get props => [targetUserId, currentUserId];
}