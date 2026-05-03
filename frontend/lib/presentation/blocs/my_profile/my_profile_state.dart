part of 'my_profile_bloc.dart';

// Base class for all MyProfile states
abstract class MyProfileState extends Equatable {
  const MyProfileState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class MyProfileInitial extends MyProfileState {}

// State showing a loading indicator (e.g., full screen skeleton or spinner)
class MyProfileLoading extends MyProfileState {}

// State showing the successfully loaded profile of the current user
class MyProfileLoaded extends MyProfileState {
  final UserProfileModel profile;

  const MyProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

// State showing an error message
class MyProfileError extends MyProfileState {
  final String message;

  const MyProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}