import 'package:flutter/material.dart';
import '../../../data/models/wishlist_models.dart';

class WishlistCard extends StatelessWidget {
  final WishlistModel wishlist;
  final int currentUserId;

  final VoidCallback onTap;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onDelete;

  const WishlistCard({
    super.key,
    required this.wishlist,
    required this.currentUserId,
    required this.onTap,
    this.onToggleVisibility,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner = wishlist.ownerId == currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Decorative icon on the left side
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),

              // Main information block (Title and items count)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wishlist.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${wishlist.giftsCount} items',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Action buttons block: Visible only to the owner
              if (isOwner)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toggle visibility button
                    IconButton(
                      icon: Icon(
                        wishlist.isVisible ? Icons.visibility : Icons.visibility_off,
                        color: wishlist.isVisible ? theme.colorScheme.primary : theme.colorScheme.error,
                      ),
                      onPressed: onToggleVisibility,
                      // Removed extra padding and constraints for a tighter UI fit
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    // Delete wishlist button
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}