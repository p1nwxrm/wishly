part of 'connection_bloc.dart';

// Base class for all connection states
abstract class ConnectionState extends Equatable {
  const ConnectionState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class ConnectionInitial extends ConnectionState {}

// State showing a loading indicator
class ConnectionLoading extends ConnectionState {}

// State showing the complete summary (both followers and following)
class ConnectionSummaryLoaded extends ConnectionState {
  final UserConnectionsModel summary;

  const ConnectionSummaryLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

// State showing only the successfully loaded followers
class FollowersLoaded extends ConnectionState {
  final List<SocialUserModel> followers;

  const FollowersLoaded({required this.followers});

  @override
  List<Object?> get props => [followers];
}

// State showing only the successfully loaded following list
class FollowingLoaded extends ConnectionState {
  final List<SocialUserModel> following;

  const FollowingLoaded({required this.following});

  @override
  List<Object?> get props => [following];
}

// State emitted when the current user successfully follows the target user.
class FollowUserSuccess extends ConnectionState {
  final String targetUsername;
  final String message;
  const FollowUserSuccess({required this.targetUsername, required this.message});

  @override
  List<Object?> get props => [targetUsername];
}

// State emitted when the current user successfully unfollows the target user.
class UnfollowUserSuccess extends ConnectionState {
  final String targetUsername;
  final String message;
  const UnfollowUserSuccess({required this.targetUsername, required this.message});

  @override
  List<Object?> get props => [targetUsername];
}

// State showing an error message
class ConnectionError extends ConnectionState {
  final String message;

  const ConnectionError({required this.message});

  @override
  List<Object?> get props => [message];
}