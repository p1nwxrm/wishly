import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/user_models.dart';
import '../../../data/models/composite_models.dart';
import '../../../data/repositories/connections_repository.dart';

part 'connection_event.dart';
part 'connection_state.dart';

// Bloc responsible for managing followers and following logic
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final ConnectionsRepository _connectionsRepository;
  final Talker _talker;

  ConnectionBloc(this._connectionsRepository, this._talker) : super(ConnectionInitial()) {
    on<LoadConnectionSummary>(_onLoadConnectionSummary);
    on<RefreshConnectionSummary>(_onRefreshConnectionSummary);

    // Followers events
    on<LoadUserFollowers>(_onLoadUserFollowers);
    on<RefreshUserFollowers>(_onRefreshUserFollowers);

    // Following events
    on<LoadUserFollowing>(_onLoadUserFollowing);
    on<RefreshUserFollowing>(_onRefreshUserFollowing);

    // Action events
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
  }

  // --- Summary Methods ---

  Future<void> _onLoadConnectionSummary(LoadConnectionSummary event, Emitter<ConnectionState> emit) async {
    emit(ConnectionLoading());
    await _fetchConnectionSummary(event.targetUsername, emit);
  }

  Future<void> _onRefreshConnectionSummary(RefreshConnectionSummary event, Emitter<ConnectionState> emit) async {
    await _fetchConnectionSummary(event.targetUsername, emit);
  }

  Future<void> _fetchConnectionSummary(String username, Emitter<ConnectionState> emit) async {
    try {
      final summary = await _connectionsRepository.getConnectionSummary(username);
      emit(ConnectionSummaryLoaded(summary: summary));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(ConnectionError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const ConnectionError(message: 'An unexpected error occurred while loading connections.'));
    }
  }

  // --- Followers Methods ---

  // Emits loading state for initial fetch
  Future<void> _onLoadUserFollowers(LoadUserFollowers event, Emitter<ConnectionState> emit) async {
    emit(ConnectionLoading());
    await _fetchUserFollowers(event.targetUsername, emit);
  }

  // Silently fetches data without emitting loading state
  Future<void> _onRefreshUserFollowers(RefreshUserFollowers event, Emitter<ConnectionState> emit) async {
    await _fetchUserFollowers(event.targetUsername, emit);
  }

  // Extracted helper for followers loading
  Future<void> _fetchUserFollowers(String username, Emitter<ConnectionState> emit) async {
    try {
      final followers = await _connectionsRepository.getUserFollowers(username);
      emit(FollowersLoaded(followers: followers));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(ConnectionError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const ConnectionError(message: 'An unexpected error occurred while loading followers.'));
    }
  }

  // --- Following Methods ---

  // Emits loading state for initial fetch
  Future<void> _onLoadUserFollowing(LoadUserFollowing event, Emitter<ConnectionState> emit) async {
    emit(ConnectionLoading());
    await _fetchUserFollowing(event.targetUsername, emit);
  }

  // Silently fetches data without emitting loading state
  Future<void> _onRefreshUserFollowing(RefreshUserFollowing event, Emitter<ConnectionState> emit) async {
    await _fetchUserFollowing(event.targetUsername, emit);
  }

  // Extracted helper for following loading
  Future<void> _fetchUserFollowing(String username, Emitter<ConnectionState> emit) async {
    try {
      final following = await _connectionsRepository.getUserFollowing(username);
      emit(FollowingLoaded(following: following));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(ConnectionError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const ConnectionError(message: 'An unexpected error occurred while loading following list.'));
    }
  }

  // Handle following a user
  Future<void> _onFollowUser(
      FollowUser event,
      Emitter<ConnectionState> emit,
      ) async {
    emit(ConnectionLoading());
    try {
      await _connectionsRepository.followUser(event.targetUsername);
      emit(FollowUserSuccess(
        targetUsername: event.targetUsername,
        message: 'Successfully followed user!',
      ));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(ConnectionError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const ConnectionError(message: 'An unexpected error occurred while following user.'));
    }
  }

  // Handle unfollowing a user
  Future<void> _onUnfollowUser(
      UnfollowUser event,
      Emitter<ConnectionState> emit,
      ) async {
    emit(ConnectionLoading());
    try {
      await _connectionsRepository.unfollowUser(event.targetUsername);
      emit(UnfollowUserSuccess(
        targetUsername: event.targetUsername,
        message: 'Successfully unfollowed user.',
      ));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(ConnectionError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const ConnectionError(message: 'An unexpected error occurred while unfollowing user.'));
    }
  }
}