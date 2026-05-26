import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/gift_models.dart';
import '../../../data/repositories/gift_repository.dart';

part 'gift_event.dart';
part 'gift_state.dart';

// Bloc responsible for managing individual gift logic (create, read, update, delete)
class GiftBloc extends Bloc<GiftEvent, GiftState> {
  final GiftRepository _giftRepository;
  final Talker _talker;

  GiftBloc(this._giftRepository, this._talker) : super(GiftInitial()) {
    on<LoadGift>(_onLoadGift);
    on<CreateGift>(_onCreateGift);
    on<UpdateGift>(_onUpdateGift);
    on<UploadGiftPhoto>(_onUploadGiftPhoto);
    on<DeleteGift>(_onDeleteGift);
  }

  // Handle fetching details of a specific gift
  Future<void> _onLoadGift(
      LoadGift event,
      Emitter<GiftState> emit,
      ) async {
    emit(GiftLoading());
    try {
      final sharedGift = await _giftRepository.getSharedGiftById(event.giftId);
      emit(GiftLoaded(sharedGift: sharedGift));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(GiftError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const GiftError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle creating a new gift and optionally uploading its photo
  Future<void> _onCreateGift(
      CreateGift event,
      Emitter<GiftState> emit,
      ) async {
    emit(GiftLoading());
    try {
      var createdGift = await _giftRepository.createGift(event.createModel);

      // Upload the gift photo after the gift entity is created
      if (event.photoFile != null) {
        createdGift = await _giftRepository.uploadGiftPhoto(
          createdGift.id,
          event.photoFile!,
        );
      }

      emit(const GiftActionSuccess(message: 'Gift successfully created!'));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(GiftError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const GiftError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle updating text details of an existing gift
  Future<void> _onUpdateGift(
      UpdateGift event,
      Emitter<GiftState> emit,
      ) async {
    emit(GiftLoading());
    try {
      var updatedGift = await _giftRepository.updateGift(
        event.giftId,
        event.updateModel,
      );

      // Upload the new gift photo after updating text fields
      if (event.photoFile != null) {
        updatedGift = await _giftRepository.uploadGiftPhoto(
          event.giftId,
          event.photoFile!,
        );
      }

      emit(GiftLoaded(sharedGift: updatedGift));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(GiftError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const GiftError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle updating ONLY the photo of an existing gift
  Future<void> _onUploadGiftPhoto(
      UploadGiftPhoto event,
      Emitter<GiftState> emit,
      ) async {
    emit(GiftLoading());
    try {
      final updatedGift = await _giftRepository.uploadGiftPhoto(event.giftId, event.photoFile);
      // Emit the updated gift so the UI can refresh the image
      emit(GiftLoaded(sharedGift: updatedGift));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(GiftError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const GiftError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle deleting a gift
  Future<void> _onDeleteGift(
      DeleteGift event,
      Emitter<GiftState> emit,
      ) async {
    emit(GiftLoading());
    try {
      await _giftRepository.deleteGift(event.giftId);
      emit(const GiftActionSuccess(message: 'Gift successfully deleted.'));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(GiftError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const GiftError(message: 'An unexpected error occurred.'));
    }
  }
}