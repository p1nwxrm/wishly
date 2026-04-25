import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../data/models/gift_models.dart';
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
    context.read<WishlistBloc>().add(LoadWishlistDetails(wishlistId: wishlistId, isRefresh: true));
  }

  /// Retries loading the wishlist details when an error occurs.
  void _onRetry(BuildContext context) {
    context.read<WishlistBloc>().add(LoadWishlistDetails(wishlistId: wishlistId));
  }

  /// Toggles the booking status of a gift.
  void _handleBookToggle(BuildContext context, int giftId, int? bookedById, int currentUserId) {
    final isBookedByMe = bookedById == currentUserId;

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
  void _confirmDeleteGift(BuildContext context, SharedGiftModel sharedGift) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Gift'),
          content: Text('Are you sure you want to delete "${sharedGift.gift.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<GiftBloc>().add(DeleteGift(giftId: sharedGift.gift.id));
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
            builder: (context, wishlistState) {
              SharedGiftModel latestGift = initialGift;

              // Extract the latest gift data from the Wishlist details state
              if (wishlistState is WishlistDetailsLoaded) {
                try {
                  latestGift = wishlistState.gifts.firstWhere(
                        (g) => g.gift.id == initialGift.gift.id,
                  );
                } catch (_) {}
              }

              return BlocBuilder<GiftBloc, GiftState>(
                builder: (context, giftState) {
                  // If the gift is being updated/loaded via GiftBloc, override the local model
                  if (giftState is GiftLoaded && giftState.gift.id == latestGift.gift.id) {
                    latestGift = SharedGiftModel(
                      gift: giftState.gift,
                      owner: latestGift.owner,
                      bookedBy: latestGift.bookedBy,
                      isMutualSubscription: latestGift.isMutualSubscription,
                    );
                  }

                  // Wrap DetailedGiftBottomSheet in BookingBloc Builder to react to loading states
                  return BlocBuilder<BookingBloc, BookingState>(
                    builder: (context, detailedBookingState) {
                      // Determine the loading state based purely on BookingBloc matching this gift ID
                      final isBookingLoading = detailedBookingState is BookingLoading &&
                          detailedBookingState.giftId == latestGift.gift.id;

                      return DetailedGiftBottomSheet(
                        sharedGift: latestGift,
                        currentUserId: currentUserId,
                        isLoading: isBookingLoading,
                        onToggleVisibility: isOwner
                            ? () => _handleToggleVisibility(context, latestGift.gift.id, latestGift.gift.isVisible)
                            : null,
                        onDelete: isOwner
                            ? () {
                          Navigator.of(context).pop();
                          _confirmDeleteGift(context, latestGift);
                        }
                            : null,
                        onOpenLink: () => _handleOpenExternalLink(context, latestGift.gift.linkUrl),
                        onBookToggle: !isOwner
                            ? () => _handleBookToggle(context, latestGift.gift.id, latestGift.bookedBy, currentUserId)
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
            final wishlist = state.wishlist;
            final gifts = state.gifts;

            // Wait for user state to load to establish ownership permissions
            final userState = context.read<UserBloc>().state;
            if (userState is! UserLoaded) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final int currentUserId = userState.user.id;
            final String currentUsername = userState.user.username;
            final isOwner = wishlist.ownerId == currentUserId;

            // Get the username for the AppBar
            final ownerUsername = isOwner
                ? currentUsername
                : (gifts.isNotEmpty ? gifts.first.owner.username : 'owner');

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
                          '"${wishlist.title}',
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
                child: gifts.isEmpty
                    ? Center(
                  child: Text(
                    isOwner ? 'Your wishlist is empty.\nAdd some gifts!' : 'This wishlist is empty.',
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final sharedGift = gifts[index];

                    // Wrap the card in a BlocBuilder to listen to BookingBloc state changes
                    return BlocBuilder<BookingBloc, BookingState>(
                      builder: (context, bookingState) {
                        // Check if the current booking action is loading and matches this specific gift ID
                        final isBookingLoading = bookingState is BookingLoading && bookingState.giftId == sharedGift.gift.id;

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
                              ? () => _handleBookToggle(context, sharedGift.gift.id, sharedGift.bookedBy, currentUserId)
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