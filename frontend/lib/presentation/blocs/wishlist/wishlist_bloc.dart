import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/wishlist_models.dart';
import '../../../data/models/gift_models.dart';
import '../../../data/repositories/wishlist_repository.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _wishlistRepository;
  final Talker _talker;

  WishlistBloc(this._wishlistRepository, this._talker) : super(WishlistInitial()) {
    on<LoadMyWishlists>(_onLoadMyWishlists);
    on<LoadUserWishlists>(_onLoadUserWishlists);
    on<LoadWishlistDetails>(_onLoadWishlistDetails);
    on<CreateWishlist>(_onCreateWishlist);
    on<UpdateWishlist>(_onUpdateWishlist);
    on<DeleteWishlist>(_onDeleteWishlist);
  }

  Future<void> _onLoadMyWishlists(
      LoadMyWishlists event,
      Emitter<WishlistState> emit,
      ) async {
    // Only emit loading state if it's NOT a silent refresh
    if (!event.isRefresh) {
      emit(WishlistLoading());
    }

    try {
      final wishlists = await _wishlistRepository.getMyWishlists();
      emit(WishlistsListLoaded(wishlists: wishlists));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onLoadUserWishlists(
      LoadUserWishlists event,
      Emitter<WishlistState> emit,
      ) async {
    emit(WishlistLoading());
    try {
      final wishlists = await _wishlistRepository.getUserWishlists(event.userId);
      emit(WishlistsListLoaded(wishlists: wishlists));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onLoadWishlistDetails(
      LoadWishlistDetails event,
      Emitter<WishlistState> emit,
      ) async {
    if (!event.isRefresh) {
      emit(WishlistLoading());
    }

    try {
      final results = await Future.wait([
        _wishlistRepository.getWishlistById(event.wishlistId),
        _wishlistRepository.getWishlistGifts(event.wishlistId),
      ]);

      final wishlist = results[0] as WishlistModel;
      final sharedGifts = results[1] as List<SharedGiftModel>;

      emit(WishlistDetailsLoaded(wishlist: wishlist, gifts: sharedGifts));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onCreateWishlist(
      CreateWishlist event,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _wishlistRepository.createWishlist(event.createModel);
      emit(const WishlistActionSuccess(message: 'Wishlist successfully created!'));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onUpdateWishlist(
      UpdateWishlist event,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _wishlistRepository.updateWishlist(event.wishlistId, event.updateModel);
      emit(const WishlistActionSuccess(message: 'Wishlist successfully updated!'));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onDeleteWishlist(
      DeleteWishlist event,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _wishlistRepository.deleteWishlist(event.wishlistId);
      emit(const WishlistActionSuccess(message: 'Wishlist successfully deleted!'));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }
}