part of 'public_profile_bloc.dart';

abstract class PublicProfileState extends Equatable {
  const PublicProfileState();

  @override
  List<Object?> get props => [];
}

class PublicProfileInitial extends PublicProfileState {}

class PublicProfileLoading extends PublicProfileState {}

class PublicProfileLoaded extends PublicProfileState {
  final UserProfileModel profile;

  const PublicProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class PublicProfileError extends PublicProfileState {
  final String message;

  const PublicProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}