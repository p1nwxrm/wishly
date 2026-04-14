import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/data/models/gift_models.dart';
import '../avatar/user_avatar.dart';
import '../common/button_loading_indicator.dart';

class FeedGiftCard extends StatelessWidget {
  final SharedGiftModel feedItem;

  final int currentUserId;
  final bool isLoading;

  final VoidCallback onDetailsTap;
  final VoidCallback onBookToggle;

  const FeedGiftCard({
    super.key,
    required this.feedItem,
    required this.currentUserId,
    required this.isLoading,
    required this.onDetailsTap,
    required this.onBookToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gift = feedItem.gift;

    // --- BUTTON STATE LOGIC ---
    final isAvailable = feedItem.bookedBy == null;
    final isBookedByMe = feedItem.bookedBy == currentUserId;
    final isBookedByOther = !isAvailable && !isBookedByMe;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with username and avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                UserAvatar(
                  radius: 16,
                  photoUrl: feedItem.ownerPhotoUrl,
                ),
                const SizedBox(width: 12),
                Text(
                  '@${feedItem.ownerUsername}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Image section
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                image: gift.photoUrl != null
                    ? DecorationImage(
                  image: CachedNetworkImageProvider(gift.photoUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: gift.photoUrl == null
                  ? Icon(Icons.card_giftcard, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5))
                  : null,
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
                        gift.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${gift.priceUsd.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // Spacing between title and buttons
                Row(
                  mainAxisSize: MainAxisSize.min, // Prevents buttons from taking full width
                  children: [
                    // Setting equal height for buttons
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
                        // Disable the button if booked by someone else
                        onPressed: isBookedByOther ? null : onBookToggle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBookedByMe ? theme.colorScheme.error : theme.colorScheme.primary,
                          foregroundColor: isBookedByMe ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                          padding: EdgeInsets.zero,
                        ),
                        child: isLoading
                            ? const ButtonLoadingIndicator()
                            : Text(
                            isBookedByMe
                                ? 'Unbook'
                                : isBookedByOther
                                  ? 'Booked'
                                  : 'Book',
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