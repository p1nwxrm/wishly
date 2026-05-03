part of 'feed_bloc.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

// Full-screen loading indicator for the very first load
class FeedLoading extends FeedState {}

// State showing the successfully loaded feed items
class FeedLoaded extends FeedState {
  final List<SharedGiftModel> feedItems;
  final bool hasReachedMax;

  const FeedLoaded({
    required this.feedItems,
    this.hasReachedMax = false,
  });

  FeedLoaded copyWith({
    List<SharedGiftModel>? feedItems,
    bool? hasReachedMax,
  }) {
    return FeedLoaded(
      feedItems: feedItems ?? this.feedItems,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [feedItems, hasReachedMax];
}

class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});

  @override
  List<Object?> get props => [message];
}