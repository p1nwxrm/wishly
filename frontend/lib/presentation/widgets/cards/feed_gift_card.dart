import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/gift_models.dart';
import '../avatar/user_avatar.dart';

class FeedGiftCard extends StatelessWidget {
  final GiftModel gift;
  final String ownerUsername;
  final String? ownerPhotoUrl;

  final bool isBooked;

  final VoidCallback onDetailsTap;
  final VoidCallback onBookToggle;

  const FeedGiftCard({
    super.key,
    required this.gift,
    required this.ownerUsername,
    this.ownerPhotoUrl,
    required this.isBooked,
    required this.onDetailsTap,
    required this.onBookToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  photoUrl: ownerPhotoUrl,
                ),
                const SizedBox(width: 12),
                Text(
                  '@$ownerUsername added a new gift',
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
                      child: OutlinedButton(
                        onPressed: onDetailsTap,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: onBookToggle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBooked ? theme.colorScheme.error : theme.colorScheme.primary,
                          foregroundColor: isBooked ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(isBooked ? 'Unbook' : 'Book'),
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