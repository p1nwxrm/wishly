import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/user_subscription_models.dart';
import '../../../data/repositories/subscription_repository.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

// Bloc responsible for managing followers and following logic
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;
  final Talker _talker;

  SubscriptionBloc(this._subscriptionRepository, this._talker) : super(SubscriptionInitial()) {
    on<LoadUserFollowers>(_onLoadUserFollowers);
    on<LoadUserFollowing>(_onLoadUserFollowing);
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
  }

  // Handle fetching the list of followers for a specific user
  Future<void> _onLoadUserFollowers(
      LoadUserFollowers event,
      Emitter<SubscriptionState> emit,
      ) async {

    // Only emit loading state if it's NOT a silent refresh
    if (!event.isRefresh) {
      emit(SubscriptionLoading());
    }

    try {
      final followers = await _subscriptionRepository.getUserFollowers(event.userId);
      emit(FollowersLoaded(followers: followers));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(SubscriptionError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const SubscriptionError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle fetching the list of following for a specific user
  Future<void> _onLoadUserFollowing(
      LoadUserFollowing event,
      Emitter<SubscriptionState> emit,
      ) async {

    // Only emit loading state if it's NOT a silent refresh
    if (!event.isRefresh) {
      emit(SubscriptionLoading());
    }

    try {
      final following = await _subscriptionRepository.getUserFollowing(event.userId);
      emit(FollowingLoaded(following: following));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(SubscriptionError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const SubscriptionError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle following a user
  Future<void> _onFollowUser(
      FollowUser event,
      Emitter<SubscriptionState> emit,
      ) async {

    emit(SubscriptionLoading());

    try {
      await _subscriptionRepository.followUser(event.targetUserId);
      // Notify UI about the successful action
      emit(SubscriptionActionSuccess(targetUserId: event.targetUserId, message: 'Successfully followed user!'));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(SubscriptionError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const SubscriptionError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle unfollowing a user
  Future<void> _onUnfollowUser(
      UnfollowUser event,
      Emitter<SubscriptionState> emit,
      ) async {

    emit(SubscriptionLoading());

    try {
      await _subscriptionRepository.unfollowUser(event.targetUserId);
      // Notify UI about the successful action
      emit(SubscriptionActionSuccess(targetUserId: event.targetUserId, message: 'Successfully unfollowed user.'));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(SubscriptionError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const SubscriptionError(message: 'An unexpected error occurred.'));
    }
  }
}