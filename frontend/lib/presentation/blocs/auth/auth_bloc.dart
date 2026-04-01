import 'dart:io';
import 'package:dio/dio.dart';
import '../../../data/models/user_models.dart';
import '../../../data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// Bloc responsible for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  // We inject AuthRepository into the BLoC and set the initial state
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    // Register event handlers
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // Handler for the LoginRequested event
  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    // Tell UI to show a loading indicator
    emit(AuthLoading());

    try {
      // Call the repository to perform the login request
      await _authRepository.login(event.email, event.password);

      // If successful, tell UI to navigate to the main screen
      emit(AuthSuccess());

    } on DioException catch (e) {
      // Handle network errors specifically
      String errorMsg = 'Network error occurred. Please try again.';

      // Try to extract the specific error message from FastAPI (usually in "detail" field)
      if (e.response != null && e.response?.data != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('detail')) {
          errorMsg = responseData['detail'].toString();
        } else {
          // Fallback if the server returns an unexpected format
          errorMsg = 'Server error: ${e.response?.statusCode}';
        }
      }

      // Emit the extracted error message
      emit(AuthFailure(errorMessage: errorMsg));

    } catch (e) {
      // Handle any other unexpected non-network errors
      emit(AuthFailure(errorMessage: 'An unexpected error occurred.'));
    }
  }

  // Handler for the RegisterRequested event
  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

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

      // 4. Everything succeeded, navigate to home screen
      emit(AuthSuccess());

    } on DioException catch (e) {
      String errorMsg = 'Registration failed. Please try again.';

      if (e.response != null && e.response?.data != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('detail')) {
          errorMsg = responseData['detail'].toString();
        }
      }

      emit(AuthFailure(errorMessage: errorMsg));
    } catch (e) {
      emit(AuthFailure(errorMessage: 'An unexpected error occurred.'));
    }
  }

  // Handler for the LogoutRequested event
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      await _authRepository.logout();
      // Reset to initial state after logout
      emit(AuthInitial());
    } catch (e) {
      // Even if the network logout fails, local storage is cleared,
      // so we still reset the state
      emit(AuthInitial());
    }
  }
}