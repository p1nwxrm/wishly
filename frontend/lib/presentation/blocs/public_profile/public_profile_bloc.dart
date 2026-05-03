import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/user_models.dart';
import '../../../data/repositories/user_repository.dart';

part 'public_profile_event.dart';
part 'public_profile_state.dart';

// Bloc responsible for managing the state of another user's profile screen.
class PublicProfileBloc extends Bloc<PublicProfileEvent, PublicProfileState> {
  final UserRepository _userRepository;
  final Talker _talker;

  PublicProfileBloc(this._userRepository, this._talker) : super(PublicProfileInitial()) {
    on<LoadPublicProfile>(_onLoadOtherUserProfile);
    on<RefreshPublicProfile>(_onRefreshOtherUserProfile);
    on<UpdateProfileFollowStatus>(_onUpdateProfileFollowStatus);
  }

  // Handles the initial loading of a user's profile.
  Future<void> _onLoadOtherUserProfile(
      LoadPublicProfile event,
      Emitter<PublicProfileState> emit,
      ) async {
    emit(PublicProfileLoading());
    await _fetchProfile(event.username, emit);
  }

  // Handles silent background refreshing of a user's profile (e.g., Pull-to-Refresh).
  Future<void> _onRefreshOtherUserProfile(
      RefreshPublicProfile event,
      Emitter<PublicProfileState> emit,
      ) async {
    await _fetchProfile(event.username, emit);
  }

  // Reusable helper method to fetch profile data from the repository.
  Future<void> _fetchProfile(String username, Emitter<PublicProfileState> emit) async {
    try {
      final profile = await _userRepository.getUserProfile(username);
      emit(PublicProfileLoaded(profile: profile));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(PublicProfileError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const PublicProfileError(message: 'An unexpected error occurred while loading the profile.'));
    }
  }

  // Handle local, optimistic updates to the profile's follow status and follower count.
  void _onUpdateProfileFollowStatus(
      UpdateProfileFollowStatus event,
      Emitter<PublicProfileState> emit,
      ) {
    final currentState = state;

    // We can only update the profile data if it is currently loaded
    if (currentState is PublicProfileLoaded) {
      final currentProfile = currentState.profile;

      // Check the current status to prevent redundant updates
      final wasFollowing = currentProfile.relationship?.isFollowing ?? false;
      if (wasFollowing == event.isNowFollowing) return;

      // Calculate the new followers count
      final currentFollowersCount = currentProfile.stats.followersCount;
      final newFollowersCount = event.isNowFollowing
          ? currentFollowersCount + 1
          : (currentFollowersCount > 0 ? currentFollowersCount - 1 : 0);

      // Create updated nested models
      final updatedStats = UserStatsModel(
        followersCount: newFollowersCount,
        followingCount: currentProfile.stats.followingCount,
      );

      final updatedRelationship = UserRelationshipModel(
        isFollowing: event.isNowFollowing,
        isFollower: currentProfile.relationship?.isFollower ?? false,
      );

      // Rebuild the main profile model with the updated nested objects
      final updatedProfile = UserProfileModel(
        id: currentProfile.id,
        username: currentProfile.username,
        name: currentProfile.name,
        subscriptionType: currentProfile.subscriptionType,
        photoUrl: currentProfile.photoUrl,
        relationship: updatedRelationship,
        stats: updatedStats,
      );

      // Emit the new state to instantly update the UI without a network request
      emit(PublicProfileLoaded(profile: updatedProfile));
    }
  }
}