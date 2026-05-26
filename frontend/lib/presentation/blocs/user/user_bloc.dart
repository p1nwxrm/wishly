import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/user_models.dart';
import '../../../data/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

// Global Bloc responsible for holding and updating the current authenticated user's state
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final Talker _talker;

  UserBloc(this._userRepository, this._talker) : super(UserInitial()) {
    on<PreloadUser>(_onPreloadUser);
    on<RefreshCurrentUser>(_onRefreshCurrentUser);
    on<UpdateCurrentUser>(_onUpdateCurrentUser);
  }

  // Handler to instantly emit the pre-loaded user state from AuthBloc
  void _onPreloadUser(
      PreloadUser event,
      Emitter<UserState> emit,
      ) {
    emit(UserLoaded(user: event.user));
  }

  // Handle silent refresh of the current user's profile
  Future<void> _onRefreshCurrentUser(
      RefreshCurrentUser event,
      Emitter<UserState> emit,
      ) async {
    try {
      // Fetch the latest current user data from the backend
      final currentUser = await _userRepository.getCurrentUser();

      // Emit the updated user state silently (without triggering UserLoading)
      // This prevents the UI from showing loading spinners during background updates
      emit(UserLoaded(user: currentUser));
    } catch (e, st) {
      // Silently handle the error so it doesn't disrupt the user's current view
      _talker.handle(e, st);
    }
  }

  // Handle updating the current user's profile
  Future<void> _onUpdateCurrentUser(
      UpdateCurrentUser event,
      Emitter<UserState> emit,
      ) async {

    emit(UserLoading());

    try {
      var updatedUser = await _userRepository.updateCurrentUser(event.updateModel);

      // Upload the new avatar after updating text profile data
      if (event.avatarFile != null) {
        updatedUser = await _userRepository.uploadProfilePhoto(event.avatarFile!);
      }

      emit(const UserActionSuccess(message: 'Profile successfully updated!'));
      emit(UserLoaded(user: updatedUser));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(UserError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const UserError(message: 'An unexpected error occurred.'));
    }
  }
}