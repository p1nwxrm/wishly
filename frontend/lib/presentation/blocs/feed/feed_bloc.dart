import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/gift_models.dart';
import '../../../data/repositories/discover_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

// Bloc responsible for managing the personalized feed of gifts from followed users
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final DiscoverRepository _discoverRepository;
  final Talker _talker;

  // Define how many items to fetch per page
  static const int _limit = 5;

  bool _isFetchingMore = false;

  FeedBloc(this._discoverRepository, this._talker) : super(FeedInitial()) {
    on<LoadInitialFeed>(_onLoadInitialFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<LoadMoreFeed>(_onLoadMoreFeed);
  }

  // ==========================================
  // 1. INITIAL LOAD
  // ==========================================
  Future<void> _onLoadInitialFeed(
      LoadInitialFeed event,
      Emitter<FeedState> emit,
      ) async {
    // Show full-screen loading ONLY on initial load
    emit(FeedLoading());

    try {
      final feedItems = await _discoverRepository.getUserFeed(skip: 0, limit: _limit);

      emit(FeedLoaded(
        feedItems: feedItems,
        hasReachedMax: feedItems.length < _limit,
      ));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(FeedError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const FeedError(message: 'An unexpected error occurred while loading the feed.'));
    }
  }

  // ==========================================
  // 2. PULL-TO-REFRESH
  // ==========================================
  Future<void> _onRefreshFeed(
      RefreshFeed event,
      Emitter<FeedState> emit,
      ) async {
    try {
      // Determine how many items to fetch to maintain the current list length.
      // This prevents the UI from breaking the scroll state.
      int fetchLimit = _limit;
      bool previousHasReachedMax = false;

      if (state is FeedLoaded) {
        final currentState = state as FeedLoaded;
        final currentItemsCount = currentState.feedItems.length;
        if (currentItemsCount > 0) {
          fetchLimit = currentItemsCount;
        }
        previousHasReachedMax = currentState.hasReachedMax;
      }

      // Fetch fresh data from the beginning using the dynamic limit
      final feedItems = await _discoverRepository.getUserFeed(
        skip: 0,
        limit: fetchLimit,
      );

      emit(FeedLoaded(
        feedItems: feedItems,
        hasReachedMax: feedItems.length < fetchLimit ? true : previousHasReachedMax,
      ));
    } catch (e, st) {
      _talker.handle(e, st);
      // For refresh we don't emit a full FeedError so we don't destroy the loaded UI.
    }
  }

  // ==========================================
  // 3. PAGINATION (LOAD MORE)
  // ==========================================
  Future<void> _onLoadMoreFeed(
      LoadMoreFeed event,
      Emitter<FeedState> emit,
      ) async {
    // We only paginate if the current state is FeedLoaded
    if (state is! FeedLoaded) return;

    final currentState = state as FeedLoaded;

    // Prevent duplicate requests if we already reached the end
    if (currentState.hasReachedMax || _isFetchingMore) return;

    _isFetchingMore = true;

    try {
      // Skip is exactly the number of items we currently have
      final feedItems = await _discoverRepository.getUserFeed(
        skip: currentState.feedItems.length,
        limit: _limit,
      );

      // Append new items to the existing list
      emit(currentState.copyWith(
        feedItems: List.of(currentState.feedItems)..addAll(feedItems),
        hasReachedMax: feedItems.length < _limit, // If backend returned less than limit, it's the end
      ));
    } catch (e, st) {
      _talker.handle(e, st);
      // Do nothing on pagination error so we don't destroy the existing list.
      // The user can just scroll again to trigger it.
    } finally {
      _isFetchingMore = false;
    }
  }
}