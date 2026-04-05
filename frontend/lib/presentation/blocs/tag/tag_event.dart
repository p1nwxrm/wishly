part of 'tag_bloc.dart';

// Base class for all tag events
abstract class TagEvent extends Equatable {
  const TagEvent();

  @override
  List<Object?> get props => [];
}

// Event to load all tags created by the current user
class LoadMyTags extends TagEvent {}

// Event to load details of a specific tag
class LoadTagById extends TagEvent {
  final int tagId;

  const LoadTagById({required this.tagId});

  @override
  List<Object?> get props => [tagId];
}

// Event to create a new tag
class CreateTag extends TagEvent {
  final TagCreateModel createModel;

  const CreateTag({required this.createModel});

  @override
  List<Object?> get props => [createModel];
}

// Event to update an existing tag
class UpdateTag extends TagEvent {
  final int tagId;
  final TagUpdateModel updateModel;

  const UpdateTag({required this.tagId, required this.updateModel});

  @override
  List<Object?> get props => [tagId, updateModel];
}

// Event to delete a tag
class DeleteTag extends TagEvent {
  final int tagId;

  const DeleteTag({required this.tagId});

  @override
  List<Object?> get props => [tagId];
}