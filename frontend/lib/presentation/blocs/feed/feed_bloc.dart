import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:frontend/data/models/gift_models.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/repositories/feed_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

// Bloc responsible for managing the user's personalized feed
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _feedRepository;
  final Talker _talker;

  FeedBloc(this._feedRepository, this._talker) : super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
  }

  // Handle fetching the feed of gifts from subscribed users
  Future<void> _onLoadFeed(
      LoadFeed event,
      Emitter<FeedState> emit,
      ) async {

    // Show the loading state (spinner) ONLY if it's not a "silent" refresh
    if (!event.isRefresh) {
      emit(FeedLoading());
    }

    try {
      final feedItems = await _feedRepository.getUserFeed(
        skip: event.skip,
        limit: event.limit,
      );
      emit(FeedLoaded(feedItems: feedItems));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(FeedError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const FeedError(message: 'An unexpected error occurred while loading the feed.'));
    }
  }
}