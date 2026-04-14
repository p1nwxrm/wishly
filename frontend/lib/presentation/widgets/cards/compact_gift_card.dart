import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/gift_models.dart';
import '../avatar/user_avatar.dart';
import '../common/button_loading_indicator.dart';

class CompactFeedGiftCard extends StatelessWidget {
  final SharedGiftModel sharedGift;
  final int currentUserId;
  final bool isLoading;

  final VoidCallback onDetailsTap;
  final VoidCallback onBookToggle;

  const CompactFeedGiftCard({
    super.key,
    required this.sharedGift,
    required this.currentUserId,
    required this.isLoading,
    required this.onDetailsTap,
    required this.onBookToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gift = sharedGift.gift;

    // --- BUTTON STATE LOGIC ---
    final isAvailable = sharedGift.bookedBy == null;
    final isBookedByMe = sharedGift.bookedBy == currentUserId;
    final isBookedByOther = !isAvailable && !isBookedByMe;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Left Section: Square Gift Image
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                image: gift.photoUrl != null
                    ? DecorationImage(
                  image: CachedNetworkImageProvider(gift.photoUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: gift.photoUrl == null
                  ? Icon(Icons.card_giftcard, size: 32, color: theme.colorScheme.primary.withValues(alpha: 0.5))
                  : null,
            ),
            const SizedBox(width: 16),

            // 2. Middle Section: Owner, Gift Name, and Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tiny owner info row
                  Row(
                    children: [
                      UserAvatar(
                        radius: 10, // Very small avatar
                        photoUrl: sharedGift.ownerPhotoUrl,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '@${sharedGift.ownerUsername}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Gift name
                  Text(
                    gift.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Gift price
                  Text(
                    '\$${gift.priceUsd.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. Right Section: Stacked Action Buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Details Button
                SizedBox(
                  height: 34,
                  width: 86,
                  child: OutlinedButton(
                    onPressed: onDetailsTap,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Details', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 8), // Spacing between buttons

                // Dynamic Booking Button
                SizedBox(
                  height: 34,
                  width: 86,
                  child: ElevatedButton(
                    // Disable the button if booked by someone else OR if it's currently loading
                    onPressed: (isBookedByOther || isLoading) ? null : onBookToggle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBookedByMe ? theme.colorScheme.error : theme.colorScheme.primary,
                      foregroundColor: isBookedByMe ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const ButtonLoadingIndicator()
                        : Text(
                      isBookedByMe ? 'Unbook' :
                      isBookedByOther ? 'Booked' : 'Book',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}