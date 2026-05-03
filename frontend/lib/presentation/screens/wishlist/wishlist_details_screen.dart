import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../data/models/gift_models.dart';
import '../../../data/models/user_models.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/bottom_sheets/bottom_sheets.dart';
import '../../widgets/cards/compact_gift_card.dart';

@RoutePage()
class WishlistDetailsScreen extends StatelessWidget implements AutoRouteWrapper {
  final int wishlistId;

  const WishlistDetailsScreen({
    super.key,
    @PathParam('id') required this.wishlistId,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Initialize WishlistBloc and immediately trigger wishlist details loading
        BlocProvider(
          create: (_) => getIt<WishlistBloc>()
            ..add(LoadWishlistDetails(wishlistId: wishlistId)),
        ),
        // Initialize GiftBloc to handle the creation, update, and deletion of a gift
        BlocProvider(
          create: (_) => getIt<GiftBloc>(),
        ),
      ],
      child: this,
    );
  }

  // --------------------------------------------------------------------------
  // Extracted Methods (Actions & Callbacks)
  // --------------------------------------------------------------------------

  /// Refreshes the wishlist details.
  Future<void> _onRefresh(BuildContext context) async {
    context.read<WishlistBloc>().add(RefreshWishlistDetails(wishlistId: wishlistId));
  }

  /// Retries loading the wishlist details when an error occurs.
  void _onRetry(BuildContext context) {
    context.read<WishlistBloc>().add(LoadWishlistDetails(wishlistId: wishlistId));
  }

  /// Toggles the booking status of a gift.
  void _handleBookToggle(BuildContext context, int giftId, int? bookedByUserId, int currentUserId) {
    final isBookedByMe = bookedByUserId == currentUserId;

    if (isBookedByMe) {
      context.read<BookingBloc>().add(UnbookGift(giftId: giftId));
    } else {
      context.read<BookingBloc>().add(BookGift(giftId: giftId));
    }
  }

  /// Toggles the visibility status of a gift (Owner only).
  void _handleToggleVisibility(BuildContext context, int giftId, bool currentVisibility) {
    context.read<GiftBloc>().add(
      UpdateGift(
        giftId: giftId,
        updateModel: GiftUpdateModel(
          isVisible: !currentVisibility,
        ),
      ),
    );
  }

  /// Attempts to open the provided URL link in an external application.
  Future<void> _handleOpenExternalLink(BuildContext context, String? link) async {
    if (link != null && link.isNotEmpty) {
      final url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppSnackbars.showError(context, 'Could not launch link');
        }
      }
    }
  }

  /// Shows the bottom sheet to add a new gift to the current wishlist.
  void _showAddGiftBottomSheet(BuildContext context) {
    final giftBloc = context.read<GiftBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: giftBloc,
          child: AddGiftBottomSheet(wishlistId: wishlistId),
        );
      },
    );
  }

  /// Shows an AlertDialog to confirm the deletion of a gift.
  void _confirmDeleteGift(BuildContext context, SharedGiftModel sharedGift, {BuildContext? bottomSheetContext}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Gift'),
          content: Text('Are you sure you want to delete "${sharedGift.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (bottomSheetContext != null && bottomSheetContext.mounted) {
                  Navigator.of(bottomSheetContext).pop();
                }
                context.read<GiftBloc>().add(DeleteGift(giftId: sharedGift.id));
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Helper to convert a Base gift to a Shared gift by appending the owner
  SharedGiftModel _mapBaseToShared(GiftBaseModel baseGift, SocialUserModel owner) {
    return SharedGiftModel(
      id: baseGift.id,
      name: baseGift.name,
      priceUsd: baseGift.priceUsd,
      photoUrl: baseGift.photoUrl,
      linkUrl: baseGift.linkUrl,
      isVisible: baseGift.isVisible,
      bookedByUserId: baseGift.bookedByUserId,
      tags: baseGift.tags,
      description: baseGift.description,
      owner: owner,
    );
  }

  /// Opens the detailed bottom sheet for a specific gift.
  void _showDetailedGiftBottomSheet({
    required BuildContext context,
    required SharedGiftModel initialGift,
    required int currentUserId,
    required bool isOwner,
  }) {
    // Capture blocs from the current context to provide them to the bottom sheet
    final wishlistBloc = context.read<WishlistBloc>();
    final giftBloc = context.read<GiftBloc>();
    final bookingBloc = context.read<BookingBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: wishlistBloc),
            BlocProvider.value(value: giftBloc),
            BlocProvider.value(value: bookingBloc),
          ],
          child: BlocBuilder<WishlistBloc, WishlistState>(
            builder: (wishlistCtx, wishlistState) {
              SharedGiftModel latestGift = initialGift;

              if (wishlistState is WishlistDetailsLoaded) {
                try {
                  final updatedBaseGift = wishlistState.wishlistDetails.gifts.firstWhere(
                        (g) => g.id == initialGift.id,
                  );
                  latestGift = _mapBaseToShared(updatedBaseGift, latestGift.owner);
                } catch (_) {}
              }

              return BlocBuilder<GiftBloc, GiftState>(
                builder: (giftCtx, giftState) {
                  if (giftState is GiftLoaded && giftState.sharedGift.id == latestGift.id) {
                    latestGift = _mapBaseToShared(giftState.sharedGift, latestGift.owner);
                  }

                  return BlocBuilder<BookingBloc, BookingState>(
                    builder: (bookingCtx, detailedBookingState) {
                      final isBookingLoading = detailedBookingState is BookingGiftLoading &&
                          detailedBookingState.giftId == latestGift.id;

                      return DetailedGiftBottomSheet(
                        sharedGift: latestGift,
                        currentUserId: currentUserId,
                        isLoading: isBookingLoading,
                        // Use the outer 'context' for all Bloc events
                        onToggleVisibility: isOwner
                            ? () => _handleToggleVisibility(context, latestGift.id, latestGift.isVisible)
                            : null,
                        onDelete: isOwner
                            ? () {
                          // Pass the stable outer screen 'context' to the dialog
                          _confirmDeleteGift(context, latestGift, bottomSheetContext: bottomSheetContext);
                        }
                            : null,
                        onOpenLink: () => _handleOpenExternalLink(context, latestGift.linkUrl),
                        onBookToggle: !isOwner
                            ? () => _handleBookToggle(context, latestGift.id, latestGift.bookedByUserId, currentUserId)
                            : null,
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen to GiftBloc: if a gift is successfully created, updated, or deleted, reload the wishlist
        BlocListener<GiftBloc, GiftState>(
          listener: (context, state) {
            if (state is GiftActionSuccess) {
              AppSnackbars.showSuccess(context, state.message);
              _onRefresh(context);
            } else if (state is GiftError) {
              AppSnackbars.showError(context, state.message);
            }
          },
        ),
        // Listen to BookingBloc: refresh list on successful book/unbook
        BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingActionSuccess) {
              AppSnackbars.showSuccess(context, state.message);
              _onRefresh(context);
            } else if (state is BookingError) {
              AppSnackbars.showError(context, state.message);
            }
          },
        ),
      ],
      child: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          // Loading State
          if (state is WishlistLoading || state is WishlistInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Error State
          if (state is WishlistError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _onRetry(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Success Loaded State
          if (state is WishlistDetailsLoaded) {
            final details = state.wishlistDetails;
            final owner = details.owner;
            final baseGifts = details.gifts;

            // Wait for user state to load to establish ownership permissions
            final userState = context.read<UserBloc>().state;
            if (userState is! UserLoaded) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final int currentUserId = userState.user.id;
            final isOwner = owner.id == currentUserId;
            final ownerUsername = owner.username;

            // Map all GiftBaseModels to SharedGiftModels dynamically using the owner info
            final sharedGifts = baseGifts.map((bg) => _mapBaseToShared(bg, owner)).toList();

            return Scaffold(
              appBar: AppBar(
                title: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '"${details.title}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '" by @$ownerUsername',
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
              ),
              body: RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                child: sharedGifts.isEmpty
                    ? Center(
                  child: Text(
                    isOwner ? 'Your wishlist is empty.\nAdd some gifts!' : 'This wishlist is empty.',
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  itemCount: sharedGifts.length,
                  itemBuilder: (context, index) {
                    final sharedGift = sharedGifts[index];

                    // Wrap the card in a BlocBuilder to listen to BookingBloc state changes
                    return BlocBuilder<BookingBloc, BookingState>(
                      builder: (context, bookingState) {
                        // Check if the current booking action is loading and matches this specific gift ID
                        final isBookingLoading = bookingState is BookingGiftLoading && bookingState.giftId == sharedGift.id;

                        return CompactFeedGiftCard(
                          sharedGift: sharedGift,
                          currentUserId: currentUserId,
                          isLoading: isBookingLoading,
                          showOwnerInfo: false,
                          onDetailsTap: () => _showDetailedGiftBottomSheet(
                            context: context,
                            initialGift: sharedGift,
                            currentUserId: currentUserId,
                            isOwner: isOwner,
                          ),
                          onDelete: isOwner
                              ? () => _confirmDeleteGift(context, sharedGift)
                              : null,
                          onBookToggle: !isOwner
                              ? () => _handleBookToggle(context, sharedGift.id, sharedGift.bookedByUserId, currentUserId)
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              floatingActionButton: isOwner
                  ? FloatingActionButton(
                onPressed: () => _showAddGiftBottomSheet(context),
                child: const Icon(Icons.add),
              )
                  : null,
            );
          }

          // Fallback empty view
          return const Scaffold();
        },
      ),
    );
  }
}