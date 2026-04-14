part of 'feed_bloc.dart';

// Base event class for the feed
abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

// Event to load or refresh the feed with optional pagination
class LoadFeed extends FeedEvent {
  final int skip;
  final int limit;

  // Flag for silent refresh (without showing the loading spinner)
  final bool isRefresh;

  const LoadFeed({
    this.skip = 0,
    this.limit = 20,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [skip, limit, isRefresh];
}