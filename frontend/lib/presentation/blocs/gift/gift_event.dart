part of 'gift_bloc.dart';

// Base class for all gift events
abstract class GiftEvent extends Equatable {
  const GiftEvent();

  @override
  List<Object?> get props => [];
}

// Event to fetch details of a specific gift
class LoadGift extends GiftEvent {
  final int giftId;

  const LoadGift({required this.giftId});

  @override
  List<Object?> get props => [giftId];
}

// Event to create a new gift with an optional photo
class CreateGift extends GiftEvent {
  final GiftCreateModel createModel;
  final File? photoFile;

  const CreateGift({required this.createModel, this.photoFile});

  @override
  List<Object?> get props => [createModel, photoFile];
}

// Event to update existing gift text details
class UpdateGift extends GiftEvent {
  final int giftId;
  final GiftUpdateModel updateModel;

  const UpdateGift({required this.giftId, required this.updateModel});

  @override
  List<Object?> get props => [giftId, updateModel];
}

// Event to update ONLY the gift photo later on
class UploadGiftPhoto extends GiftEvent {
  final int giftId;
  final File photoFile;

  const UploadGiftPhoto({required this.giftId, required this.photoFile});

  @override
  List<Object?> get props => [giftId, photoFile];
}

// Event to delete a gift
class DeleteGift extends GiftEvent {
  final int giftId;

  const DeleteGift({required this.giftId});

  @override
  List<Object?> get props => [giftId];
}