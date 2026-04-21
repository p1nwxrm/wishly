import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/user_models.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// Bloc responsible for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final Talker _talker;

  // We inject AuthRepository into the BLoC and set the initial state
  AuthBloc(this._authRepository, this._talker) : super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);
  }

  // Handler for the AuthCheckRequested event
  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      // 1. Fast local check: do we even have a token string?
      final hasToken = await _authRepository.hasValidToken();

      if (!hasToken) {
        // If storage is completely empty, don't even bother the server
        emit(const AuthUnauthenticated());
        return;
      }

      // 2. Strict network check: ping the server to validate/refresh tokens
      final currentUser = await _authRepository.verifySession();

      // 3. Tokens are 100% valid. Pass the user data to the success state.
      emit(AuthSuccess(user: currentUser));

    } catch (e, st) {
      _talker.handle(e, st);
      // If verifySession() throws an error (e.g., interceptor failed to refresh),
      // we catch it here and send the user to the WelcomeScreen
      emit(const AuthUnauthenticated());
    }
  }

  // Handler for the LoginRequested event
  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    // Tell UI to show a loading indicator
    emit(const AuthLoading());

    try {
      // 1. Call the repository to perform the login request and save tokens
      await _authRepository.login(event.email, event.password);

      // 2. Fetch the user profile immediately using the fresh tokens
      final currentUser = await _authRepository.verifySession();

      // 3. Emit success WITH the user to trigger preloading in the UI
      emit(AuthSuccess(user: currentUser));

    } on DioException catch (e, st) {
      // Log the structured network error
      _talker.handle(e, st);

      // Extract error message using our global parser utility
      final errorMsg = ApiErrorParser.extractMessage(
        e,
        defaultMsg: 'Login failed. Please check your credentials and try again.',
      );

      // Emit the extracted error message
      emit(AuthFailure(errorMessage: errorMsg));
    } catch (e, st) {
      // Log and handle any other unexpected non-network errors
      _talker.handle(e, st);
      emit(const AuthFailure(errorMessage: 'An unexpected error occurred.'));
    }
  }

  // Handler for the RegisterRequested event
  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      // 1. Register the user
      await _authRepository.register(event.userModel);

      // 2. Immediately log in to get the JWT tokens
      // We use the email and password from the registration model
      await _authRepository.login(
        event.userModel.email,
        event.userModel.password,
      );

      // 3. If the user selected a photo, upload it now that we have tokens
      if (event.photoFile != null) {
        await _authRepository.uploadProfilePhoto(event.photoFile!);
      }

      // 4. Fetch the full user profile to ensure a seamless UI transition
      final currentUser = await _authRepository.verifySession();

      // 5. Everything succeeded, navigate to home screen with preloaded data
      emit(AuthSuccess(user: currentUser));

    } on DioException catch (e, st) {
      _talker.handle(e, st);

      // Extract error message using our global parser utility
      final errorMsg = ApiErrorParser.extractMessage(
        e,
        defaultMsg: 'Registration failed. Please try again.',
      );

      emit(AuthFailure(errorMessage: errorMsg));

    } catch (e, st) {
      _talker.handle(e, st);
      emit(const AuthFailure(errorMessage: 'An unexpected error occurred.'));
    }
  }

  // Handler for the LogoutRequested event
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.logout();
      // Reset to initial state after logout
      emit(const AuthInitial());
    } catch (e, st) {
      _talker.handle(e, st);
      // Even if the network logout fails, local storage is cleared,
      // so we still reset the state
      emit(const AuthInitial());
    }
  }

  // Handler for when the interceptor kills the session
  Future<void> _onSessionExpired(
      SessionExpired event,
      Emitter<AuthState> emit,
      ) async {
    // 1. Wipe the invalid tokens from local storage
    await _authRepository.clearLocalSession();

    // 2. Just emit unauthenticated immediately.
    // Do NOT call _authRepository.logout() here to avoid infinite loops!
    emit(const AuthUnauthenticated());
  }
}