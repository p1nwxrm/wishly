import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../data/models/user_models.dart';
import '../../../core/api/api_error_parser.dart';
import '../../../data/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

// Bloc responsible for managing user profile logic and state
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final Talker _talker;

  UserBloc(this._userRepository, this._talker) : super(UserInitial()) {
    on<PreloadUser>(_onPreloadUser);
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<LoadUserById>(_onLoadUserById);
    on<UpdateCurrentUser>(_onUpdateCurrentUser);
  }

  // Handler to instantly emit the pre-loaded user state without network requests
  void _onPreloadUser(
      PreloadUser event,
      Emitter<UserState> emit,
      ) {
    emit(UserLoaded(user: event.user));
  }

  // Handle fetching the current user's profile
  Future<void> _onLoadCurrentUser(
      LoadCurrentUser event,
      Emitter<UserState> emit,
      ) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getCurrentUser();
      emit(UserLoaded(user: user));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(UserError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const UserError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle fetching a specific user's profile
  Future<void> _onLoadUserById(
      LoadUserById event,
      Emitter<UserState> emit,
      ) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getUserById(event.userId);
      emit(UserLoaded(user: user));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(UserError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const UserError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle updating the current user's profile
  Future<void> _onUpdateCurrentUser(
      UpdateCurrentUser event,
      Emitter<UserState> emit,
      ) async {
    try {
      final updatedUser = await _userRepository.updateCurrentUser(event.updateModel);

      // Notify UI about the successful update
      emit(const UserActionSuccess(message: 'Profile successfully updated!'));

      // Emit the updated user so the UI refreshes immediately
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