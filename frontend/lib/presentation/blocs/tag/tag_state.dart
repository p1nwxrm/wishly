part of 'tag_bloc.dart';

// Base class for all tag states
abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object?> get props => [];
}

// Initial state before any actions
class TagInitial extends TagState {}

// State showing a loading indicator
class TagLoading extends TagState {}

// State showing the successfully loaded list of tags
class TagsLoaded extends TagState {
  final List<TagModel> tags;

  const TagsLoaded({required this.tags});

  @override
  List<Object?> get props => [tags];
}

// State showing the successfully loaded single tag details
class TagDetailsLoaded extends TagState {
  final TagModel tag;

  const TagDetailsLoaded({required this.tag});

  @override
  List<Object?> get props => [tag];
}

// State indicating a successful one-time mutation (create, update, delete)
class TagActionSuccess extends TagState {
  final String message;

  const TagActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// State showing an error message
class TagError extends TagState {
  final String message;

  const TagError({required this.message});

  @override
  List<Object?> get props => [message];
}