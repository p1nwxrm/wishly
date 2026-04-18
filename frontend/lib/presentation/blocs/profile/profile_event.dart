part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// Event to load a profile by username
class LoadProfile extends ProfileEvent {
  final String username;

  const LoadProfile({required this.username});

  @override
  List<Object?> get props => [username];
}