import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/gift_models.dart';

// A card widget displaying individual gift details in a wishlist.
// It adapts its UI based on whether the viewer is the owner or a guest.
class WishlistGiftCard extends StatelessWidget {
  final GiftModel gift;

  // Flags to determine the state and permissions for the card UI.
  final bool isOwner;
  final bool isBooked;

  // Callbacks for user interactions.
  final VoidCallback onDetailsTap;
  final VoidCallback? onToggleVisibility; // Used only if isOwner is true
  final VoidCallback? onDelete; // Used only if isOwner is true
  final VoidCallback? onBookToggle; // Used only if isOwner is false

  const WishlistGiftCard({
    super.key,
    required this.gift,
    required this.isOwner,
    required this.isBooked,
    required this.onDetailsTap,
    this.onToggleVisibility,
    this.onDelete,
    this.onBookToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Gift Image Section
            // Displays a placeholder icon if the photoUrl is null.
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                image: gift.photoUrl != null
                    ? DecorationImage(
                  // Replaced NetworkImage with CachedNetworkImageProvider
                  image: CachedNetworkImageProvider(gift.photoUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: gift.photoUrl == null
                  ? Icon(Icons.card_giftcard, color: theme.colorScheme.primary)
                  : null,
            ),
            const SizedBox(width: 16),

            // Gift Info Section - Title and Price
            // Expanded is used to prevent text overflow issues.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gift.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${gift.priceUsd.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action Buttons Section
            // Renders different controls depending on the user's role.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOwner) ...[
                  // Owner controls - Toggle visibility and delete.
                  IconButton(
                    icon: Icon(
                      gift.isVisible ? Icons.visibility : Icons.visibility_off,
                      color: gift.isVisible ? theme.colorScheme.primary : theme.colorScheme.error,
                    ),
                    onPressed: onToggleVisibility,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ] else ...[
                  // Guest controls - Book or unbook the gift.
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onBookToggle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBooked ? theme.colorScheme.error : theme.colorScheme.primary,
                        foregroundColor: isBooked ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        elevation: 0,
                      ),
                      child: Text(isBooked ? 'Unbook' : 'Book'),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                // Details button is available to everyone.
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: onDetailsTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}