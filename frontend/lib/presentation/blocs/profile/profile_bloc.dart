import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/user_models.dart';
import '../../../data/repositories/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final Talker _talker;

  ProfileBloc(this._userRepository, this._talker) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());
    try {
      final profile = await _userRepository.getUserProfile(event.username);
      emit(ProfileLoaded(profile: profile));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(ProfileError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const ProfileError(message: 'An unexpected error occurred while loading the profile.'));
    }
  }
}