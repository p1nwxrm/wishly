import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/gift_models.dart';

// A detailed view of a gift card, typically used in a modal bottom sheet or a separate screen.
class DetailedGiftCard extends StatelessWidget {
  final GiftModel gift;
  final bool isOwner;
  final bool isBooked;

  // Optional callbacks for actions available on this card.
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onDelete;
  final VoidCallback? onBookToggle;
  final VoidCallback? onOpenLink;

  const DetailedGiftCard({
    super.key,
    required this.gift,
    required this.isOwner,
    required this.isBooked,
    this.onToggleVisibility,
    this.onDelete,
    this.onBookToggle,
    this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check if a valid link exists to dynamically adjust layout spacing
    final hasLink = gift.linkUrl != null && gift.linkUrl!.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              image: gift.photoUrl != null
                  ? DecorationImage(
                image: CachedNetworkImageProvider(gift.photoUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: gift.photoUrl == null
                ? Icon(Icons.card_giftcard, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5))
                : null,
          ),

          Padding(
            // Dynamically adjust bottom padding: smaller if the link button is
            // present to compensate for the button's inherent vertical space.
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: hasLink ? 12.0 : 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row containing Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        gift.name,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$${gift.priceUsd.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description section - Renders only if description is not null and not empty
                if (gift.description != null && gift.description!.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gift.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Action Buttons Section
                // Displays different controls based on whether the user is the owner or a guest
                if (isOwner) ...[
                  IntrinsicHeight(
                    child: Row(
                      // Stretch buttons vertically to match heights
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onToggleVisibility,
                            icon: Icon(gift.isVisible ? Icons.visibility : Icons.visibility_off, size: 18),
                            label: Text(
                              gift.isVisible ? 'Hide' : 'Show',
                              textAlign: TextAlign.center,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: gift.isVisible ? theme.colorScheme.primary : theme.colorScheme.error,
                              side: BorderSide(
                                color: gift.isVisible ? theme.colorScheme.primary : theme.colorScheme.error,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Guest Actions - Book or unbook the gift
                  SizedBox(
                    width: double.infinity,
                    height: 56, // Taller button for details screen emphasis
                    child: ElevatedButton(
                      onPressed: onBookToggle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBooked ? theme.colorScheme.error : theme.colorScheme.primary,
                        foregroundColor: isBooked ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                      ),
                      child: Text(
                        isBooked ? 'Unbook' : 'Book',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],

                // Link Button - Renders only if linkUrl is not null and not empty
                if (hasLink) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onOpenLink,
                      icon: const Icon(Icons.open_in_new, size: 20),
                      label: const Text('View in store'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}