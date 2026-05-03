import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/wishlist_models.dart';
import '../../../data/models/composite_models.dart';
import '../../../data/repositories/wishlist_repository.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

// Bloc responsible for managing wishlist collections and their contents
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _wishlistRepository;
  final Talker _talker;

  WishlistBloc(this._wishlistRepository, this._talker) : super(WishlistInitial()) {
    on<LoadUserWishlists>(_onLoadUserWishlists);
    on<RefreshUserWishlists>(_onRefreshUserWishlists);
    on<LoadWishlistDetails>(_onLoadWishlistDetails);
    on<RefreshWishlistDetails>(_onRefreshWishlistDetails);
    on<CreateWishlist>(_onCreateWishlist);
    on<UpdateWishlist>(_onUpdateWishlist);
    on<DeleteWishlist>(_onDeleteWishlist);
  }

  // ==========================================
  // READ OPERATIONS
  // ==========================================

  Future<void> _onLoadUserWishlists(
      LoadUserWishlists event,
      Emitter<WishlistState> emit,
      ) async {
    emit(WishlistLoading());
    await _fetchUserWishlists(event.username, emit);
  }

  Future<void> _onRefreshUserWishlists(
      RefreshUserWishlists event,
      Emitter<WishlistState> emit,
      ) async {
    // Silent refresh: no WishlistLoading() emitted
    await _fetchUserWishlists(event.username, emit);
  }

  Future<void> _fetchUserWishlists(String username, Emitter<WishlistState> emit) async {
    try {
      final userWishlists = await _wishlistRepository.getUserWishlists(username);
      emit(UserWishlistsLoaded(data: userWishlists));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(WishlistError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred while loading wishlists.'));
    }
  }

  Future<void> _onLoadWishlistDetails(
      LoadWishlistDetails event,
      Emitter<WishlistState> emit,
      ) async {
    emit(WishlistLoading());
    await _fetchWishlistDetails(event.wishlistId, emit);
  }

  Future<void> _onRefreshWishlistDetails(
      RefreshWishlistDetails event,
      Emitter<WishlistState> emit,
      ) async {
    // Silent refresh: no WishlistLoading() emitted
    await _fetchWishlistDetails(event.wishlistId, emit);
  }

  Future<void> _fetchWishlistDetails(int wishlistId, Emitter<WishlistState> emit) async {
    try {
      // Much cleaner now: single API call returns the combined model
      final details = await _wishlistRepository.getWishlistGifts(wishlistId);
      emit(WishlistDetailsLoaded(wishlistDetails: details));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(WishlistError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred while loading wishlist details.'));
    }
  }

  // ==========================================
  // MUTATION OPERATIONS (Create, Update, Delete)
  // ==========================================

  Future<void> _onCreateWishlist(
      CreateWishlist event,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _wishlistRepository.createWishlist(event.createModel);
      emit(const WishlistActionSuccess(message: 'Wishlist successfully created!'));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      emit(WishlistError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred while creating wishlist.'));
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
      emit(WishlistError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred while updating wishlist.'));
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
      emit(WishlistError(message: ApiErrorParser.extractMessage(e)));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred while deleting wishlist.'));
    }
  }
}