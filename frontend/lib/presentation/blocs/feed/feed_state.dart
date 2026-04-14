part of 'feed_bloc.dart';

// Base class for all feed states
abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

// Initial state
class FeedInitial extends FeedState {}

// State showing a loading indicator
class FeedLoading extends FeedState {}

// State showing the successfully loaded feed items
class FeedLoaded extends FeedState {
  final List<SharedGiftModel> feedItems;

  const FeedLoaded({required this.feedItems});

  @override
  List<Object?> get props => [feedItems];
}

// State showing an error message
class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});

  @override
  List<Object?> get props => [message];
}