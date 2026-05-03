part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

// 1. Initial load (shows full-screen spinner)
class LoadInitialFeed extends FeedEvent {}

// 2. Pull-to-refresh (silent reload, resets pagination)
class RefreshFeed extends FeedEvent {}

// 3. Pagination (loads next page and appends to existing list)
class LoadMoreFeed extends FeedEvent {}