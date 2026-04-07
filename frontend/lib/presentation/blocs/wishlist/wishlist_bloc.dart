import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../data/models/wishlist_models.dart';
import '../../../core/api/api_error_parser.dart';
import '../../../data/models/gift_models.dart';
import '../../../data/repositories/wishlist_repository.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

// Bloc responsible for managing wishlist logic and state
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

  // Handle fetching the user's wishlists
  Future<void> _onLoadMyWishlists(
      LoadMyWishlists event,
      Emitter<WishlistState> emit,
      ) async {
    emit(WishlistLoading());
    try {
      final wishlists = await _wishlistRepository.getMyWishlists();
      emit(WishlistsLoaded(wishlists: wishlists));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle fetching another user's wishlists
  Future<void> _onLoadUserWishlists(
      LoadUserWishlists event,
      Emitter<WishlistState> emit,
      ) async {
    emit(WishlistLoading());
    try {
      final wishlists = await _wishlistRepository.getUserWishlists(event.userId);
      emit(WishlistsLoaded(wishlists: wishlists));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle fetching a specific wishlist and its associated gifts
  Future<void> _onLoadWishlistDetails(
      LoadWishlistDetails event,
      Emitter<WishlistState> emit,
      ) async {
    emit(WishlistLoading());
    try {
      // Execute both network requests simultaneously for better performance
      final results = await Future.wait([
        _wishlistRepository.getWishlistById(event.wishlistId),
        _wishlistRepository.getWishlistGifts(event.wishlistId),
      ]);

      // Safely cast the results from the Future.wait array
      final wishlist = results[0] as WishlistModel;
      final gifts = results[1] as List<GiftModel>;

      emit(WishlistDetailsLoaded(wishlist: wishlist, gifts: gifts));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle creating a new wishlist
  Future<void> _onCreateWishlist(
      CreateWishlist event,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _wishlistRepository.createWishlist(event.createModel);
      // Notify UI to close the creation screen or show a success snackbar
      emit(const WishlistActionSuccess(message: 'Wishlist successfully created!'));
      // Reload the list after successful creation
      add(LoadMyWishlists());
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle updating an existing wishlist
  Future<void> _onUpdateWishlist(
      UpdateWishlist event,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _wishlistRepository.updateWishlist(event.wishlistId, event.updateModel);
      // Notify UI about the successful update
      emit(const WishlistActionSuccess(message: 'Wishlist successfully updated!'));
      // Reload the list after successful update
      add(LoadMyWishlists());
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(WishlistError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const WishlistError(message: 'An unexpected error occurred.'));
    }
  }

  // Handle deleting a wishlist
  Future<void> _onDeleteWishlist(
      DeleteWishlist event,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _wishlistRepository.deleteWishlist(event.wishlistId);
      // Notify UI about the successful deletion
      emit(const WishlistActionSuccess(message: 'Wishlist successfully deleted!'));
      // Reload the list after successful deletion
      add(LoadMyWishlists());
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