part of 'subscription_bloc.dart';

// Base class for all subscription states
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class SubscriptionInitial extends SubscriptionState {}

// State showing a loading indicator
class SubscriptionLoading extends SubscriptionState {}

// State showing the successfully loaded followers
class FollowersLoaded extends SubscriptionState {
  final List<UserSubscriptionModel> followers;

  const FollowersLoaded({required this.followers});

  @override
  List<Object?> get props => [followers];
}

// State showing the successfully loaded following list
class FollowingLoaded extends SubscriptionState {
  final List<UserSubscriptionModel> following;

  const FollowingLoaded({required this.following});

  @override
  List<Object?> get props => [following];
}

// State indicating a successful one-time mutation (follow/unfollow)
class SubscriptionActionSuccess extends SubscriptionState {
  final String message;

  const SubscriptionActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// State showing an error message
class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}