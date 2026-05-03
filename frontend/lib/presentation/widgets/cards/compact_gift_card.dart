import 'package:flutter/material.dart';
import '../../../data/models/gift_models.dart';
import '../photo/user_avatar.dart';
import '../common/common.dart';

class CompactFeedGiftCard extends StatelessWidget {
  final SharedGiftModel sharedGift;
  final int currentUserId;

  final bool isLoading;
  final bool showOwnerInfo;

  final VoidCallback onDetailsTap;
  final VoidCallback? onDelete;
  final VoidCallback? onBookToggle;

  const CompactFeedGiftCard({
    super.key,
    required this.sharedGift,
    required this.currentUserId,
    required this.isLoading,
    this.showOwnerInfo = true,
    required this.onDetailsTap,
    this.onDelete,
    this.onBookToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- BUTTON STATE LOGIC ---
    final isOwner = sharedGift.owner.id == currentUserId;
    final isAvailable = sharedGift.bookedByUserId == null;
    final isBookedByMe = sharedGift.bookedByUserId == currentUserId;
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
              // clipBehavior applies the border radius to the child image automatically
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              // We delegate all URL checking, loading, and error states to our wrapper
              child: AppCachedNetworkImage(
                imageUrl: sharedGift.photoUrl,
                fallbackWidget: Icon(
                  Icons.card_giftcard,
                  size: 32,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 2. Middle Section: Owner, Gift Name, and Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Conditionally render the owner info row
                  if (showOwnerInfo) ...[
                    Row(
                      children: [
                        UserAvatar(
                          radius: 10,
                          photoUrl: sharedGift.owner.photoUrl,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '@${sharedGift.owner.username}',
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
                  ],

                  // Gift name
                  Text(
                    sharedGift.name,
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
                    '\$${sharedGift.priceUsd.toStringAsFixed(2)}',
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
                // Details Button (Always visible)
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
                const SizedBox(height: 8),

                // Dynamic Secondary Button (Delete if owner, Book/Unbook if guest)
                if (isOwner) ...[
                  SizedBox(
                    height: 34,
                    width: 86,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const ButtonLoadingIndicator()
                          : const Text('Delete', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    height: 34,
                    width: 86,
                    child: ElevatedButton(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}