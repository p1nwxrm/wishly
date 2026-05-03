import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/user_models.dart';
import '../../../data/repositories/user_repository.dart';

part 'my_profile_event.dart';
part 'my_profile_state.dart';

// Bloc responsible for managing the current user's full profile screen (with stats)
class MyProfileBloc extends Bloc<MyProfileEvent, MyProfileState> {
  final UserRepository _userRepository;
  final Talker _talker;

  MyProfileBloc(this._userRepository, this._talker) : super(MyProfileInitial()) {
    on<LoadMyProfile>(_onLoadMyProfile);
    on<RefreshMyProfile>(_onRefreshMyProfile);
  }

  // Handle initial loading with a loading state
  Future<void> _onLoadMyProfile(
      LoadMyProfile event,
      Emitter<MyProfileState> emit,
      ) async {
    emit(MyProfileLoading());
    await _fetchProfile(event.username, emit);
  }

  // Handle background refresh without emitting a loading state
  Future<void> _onRefreshMyProfile(
      RefreshMyProfile event,
      Emitter<MyProfileState> emit,
      ) async {
    await _fetchProfile(event.username, emit);
  }

  // Extracted helper for fetching the profile data
  Future<void> _fetchProfile(String username, Emitter<MyProfileState> emit) async {
    try {
      final profile = await _userRepository.getUserProfile(username);
      emit(MyProfileLoaded(profile: profile));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(MyProfileError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const MyProfileError(message: 'An unexpected error occurred while loading the profile.'));
    }
  }
}