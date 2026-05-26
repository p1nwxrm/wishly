import 'package:flutter/material.dart';
import '../../../data/models/composite_models.dart';
import '../../../data/models/wishlist_models.dart';
import '../cards/wishlist_card.dart';

// A reusable widget to display a list of wishlists.
class WishlistsListWidget extends StatelessWidget {
  final UserWishlistsModel userWishlistsData;
  final int currentUserId;

  // Callback triggered when the user pulls the list down to refresh
  final Future<void> Function() onRefresh;

  // Callbacks for individual card actions
  final ValueChanged<WishlistBaseModel> onWishlistTap;
  final ValueChanged<WishlistBaseModel>? onToggleVisibility;
  final ValueChanged<WishlistBaseModel>? onEdit;
  final ValueChanged<WishlistBaseModel>? onDelete;

  const WishlistsListWidget({
    super.key,
    required this.userWishlistsData,
    required this.currentUserId,
    required this.onRefresh,
    required this.onWishlistTap,
    this.onToggleVisibility,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final wishlists = userWishlistsData.wishlists;
    final owner = userWishlistsData.user;

    // 1. Handle Empty State
    if (wishlists.isEmpty) {
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
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        itemCount: wishlists.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final wishlistBase = wishlists[index];

          // Map WishlistBaseModel to SharedWishlistModel for the WishlistCard
          final sharedWishlist = SharedWishlistModel(
            id: wishlistBase.id,
            title: wishlistBase.title,
            giftsCount: wishlistBase.giftsCount,
            isVisible: wishlistBase.isVisible,
            owner: owner,
          );

          return WishlistCard(
            wishlist: sharedWishlist,
            currentUserId: currentUserId,
            onTap: () => onWishlistTap(wishlistBase),
            onToggleVisibility: onToggleVisibility != null
                ? () => onToggleVisibility!(wishlistBase)
                : null,
            onEdit: onEdit != null
                ? () => onEdit!(wishlistBase)
                : null,
            onDelete: onDelete != null
                ? () => onDelete!(wishlistBase)
                : null,
          );
        },
      ),
    );
  }
}