import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../data/models/tag_models.dart';
import '../../../core/api/api_error_parser.dart';
import '../../../data/repositories/tag_repository.dart';

part 'tag_event.dart';
part 'tag_state.dart';

// Bloc responsible for managing custom tags
class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository _tagRepository;
  final Talker _talker;

  TagBloc(this._tagRepository, this._talker) : super(TagInitial()) {
    on<LoadMyTags>(_onLoadMyTags);
    on<LoadTagById>(_onLoadTagById);
    on<CreateTag>(_onCreateTag);
    on<UpdateTag>(_onUpdateTag);
    on<DeleteTag>(_onDeleteTag);
  }

  // Handle fetching all tags for the current user
  Future<void> _onLoadMyTags(
      LoadMyTags event,
      Emitter<TagState> emit,
      ) async {
    emit(TagLoading());
    try {
      final tags = await _tagRepository.getMyTags();
      emit(TagsLoaded(tags: tags));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(TagError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const TagError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle fetching a specific tag by ID
  Future<void> _onLoadTagById(
      LoadTagById event,
      Emitter<TagState> emit,
      ) async {
    emit(TagLoading());
    try {
      final tag = await _tagRepository.getTagById(event.tagId);
      emit(TagDetailsLoaded(tag: tag));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(TagError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const TagError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle creating a new tag
  Future<void> _onCreateTag(
      CreateTag event,
      Emitter<TagState> emit,
      ) async {
    try {
      await _tagRepository.createTag(event.createModel);

      // Notify UI about successful creation
      emit(const TagActionSuccess(message: 'Tag successfully created!'));

      // Reload the tags list
      add(LoadMyTags());
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(TagError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const TagError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle updating an existing tag
  Future<void> _onUpdateTag(
      UpdateTag event,
      Emitter<TagState> emit,
      ) async {
    try {
      await _tagRepository.updateTag(event.tagId, event.updateModel);

      // Notify UI about successful update
      emit(const TagActionSuccess(message: 'Tag successfully updated!'));

      // Reload the tags list
      add(LoadMyTags());
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(TagError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const TagError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle deleting a tag
  Future<void> _onDeleteTag(
      DeleteTag event,
      Emitter<TagState> emit,
      ) async {
    try {
      await _tagRepository.deleteTag(event.tagId);

      // Notify UI about successful deletion
      emit(const TagActionSuccess(message: 'Tag successfully deleted.'));

      // Reload the tags list
      add(LoadMyTags());
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(TagError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const TagError(message: 'An unexpected error occurred.'));
    }
  }
}