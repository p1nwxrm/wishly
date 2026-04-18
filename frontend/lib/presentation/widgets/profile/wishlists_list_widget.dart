import 'package:flutter/material.dart';
import '../../../data/models/wishlist_models.dart';
import '../cards/wishlist_card.dart';

// A reusable widget to display a list of wishlists.
// It handles the empty state, pull-to-refresh, and rendering the list.
class WishlistsListWidget extends StatelessWidget {
  // The data to display
  final List<WishlistModel> wishlists;

  // Needed to determine if the current user owns the wishlist (for edit/delete buttons)
  final int currentUserId;

  // Callback triggered when the user pulls the list down to refresh
  final Future<void> Function() onRefresh;

  // Callbacks for individual card actions
  final void Function(WishlistModel wishlist) onWishlistTap;
  final void Function(WishlistModel wishlist)? onToggleVisibility;
  final void Function(WishlistModel wishlist)? onDelete;

  const WishlistsListWidget({
    super.key,
    required this.wishlists,
    required this.currentUserId,
    required this.onRefresh,
    required this.onWishlistTap,
    this.onToggleVisibility,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Handle Empty State
    if (wishlists.isEmpty) {
      // We still wrap the empty state in a scrollable view with a RefreshIndicator
      // so the user can pull to refresh even if the list is empty.
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No wishlists found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // 2. Render the populated list
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        // AlwaysScrollableScrollPhysics ensures pull-to-refresh works even if
        // the list is too short to scroll normally.
        physics: const AlwaysScrollableScrollPhysics(),
        // Add some padding to the top and bottom of the list
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        itemCount: wishlists.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final wishlist = wishlists[index];

          return WishlistCard(
            wishlist: wishlist,
            currentUserId: currentUserId,
            // Pass the callbacks up to the parent screen
            onTap: () => onWishlistTap(wishlist),
            onToggleVisibility: onToggleVisibility != null
                ? () => onToggleVisibility!(wishlist)
                : null,
            onDelete: onDelete != null
                ? () => onDelete!(wishlist)
                : null,
          );
        },
      ),
    );
  }
}