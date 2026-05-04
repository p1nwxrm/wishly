import 'package:flutter/material.dart';
import '../../../data/models/gift_models.dart';
import '../photo/user_avatar.dart';
import '../common/common.dart';

class FeedGiftCard extends StatelessWidget {
  final SharedGiftModel feedItem;
  final int currentUserId;

  final bool isLoading;

  final VoidCallback onDetailsTap;
  final VoidCallback onBookToggle;
  final VoidCallback onUserTap;

  const FeedGiftCard({
    super.key,
    required this.feedItem,
    required this.currentUserId,
    required this.isLoading,
    required this.onDetailsTap,
    required this.onBookToggle,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- BUTTON STATE LOGIC ---
    final isAvailable = feedItem.bookedByUserId == null;
    final isBookedByMe = feedItem.bookedByUserId == currentUserId;
    final isBookedByOther = !isAvailable && !isBookedByMe;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with username and avatar
          InkWell(
            onTap: onUserTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  UserAvatar(
                    radius: 16,
                    photoUrl: feedItem.owner.photoUrl,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '@${feedItem.owner.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image section
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              // Delegate all image loading, caching, and fallback logic to our wrapper
              child: AppCachedNetworkImage(
                imageUrl: feedItem.photoUrl,
                fallbackWidget: Icon(
                  Icons.card_giftcard,
                  size: 64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),

          // Footer with details and actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedItem.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${feedItem.priceUsd.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 100,
                      child: OutlinedButton(
                        onPressed: onDetailsTap,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // --- DYNAMIC BOOKING BUTTON ---
                    SizedBox(
                      height: 40,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: (isBookedByOther || isLoading) ? null : onBookToggle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBookedByMe ? theme.colorScheme.error : theme.colorScheme.primary,
                          foregroundColor: isBookedByMe ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                          padding: EdgeInsets.zero,
                        ),
                        child: isLoading
                            ? const ButtonLoadingIndicator()
                            : Text(
                          isBookedByMe ? 'Unbook' :
                          isBookedByOther ? 'Booked' : 'Book',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}