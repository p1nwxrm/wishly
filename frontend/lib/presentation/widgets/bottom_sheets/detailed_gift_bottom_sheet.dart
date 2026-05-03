import 'package:flutter/material.dart';
import '../../../data/models/gift_models.dart';
import '../common/button_loading_indicator.dart';
import '../common/app_cached_network_image.dart';

class DetailedGiftBottomSheet extends StatelessWidget {
  final SharedGiftModel sharedGift;
  final int currentUserId;
  final bool isLoading;

  final VoidCallback? onToggleVisibility;
  final VoidCallback? onDelete;
  final VoidCallback? onBookToggle;
  final VoidCallback? onOpenLink;

  const DetailedGiftBottomSheet({
    super.key,
    required this.sharedGift,
    required this.currentUserId,
    this.isLoading = false,
    this.onToggleVisibility,
    this.onDelete,
    this.onBookToggle,
    this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- BUTTON STATE LOGIC ---
    final isOwner = sharedGift.owner.id == currentUserId;
    final isAvailable = sharedGift.bookedByUserId == null;
    final isBookedByMe = sharedGift.bookedByUserId == currentUserId;
    final isBookedByOther = !isAvailable && !isBookedByMe;
    final hasLink = sharedGift.linkUrl != null && sharedGift.linkUrl!.isNotEmpty;

    // Wrap in SingleChildScrollView for scrolling long content
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // The window will take only the required height
        children: [
          // Drag Handle (slider at the top)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Image Section
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: AppCachedNetworkImage(
              imageUrl: sharedGift.photoUrl,
              fallbackWidget: Icon(
                Icons.card_giftcard,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              // SafeArea.bottom allows adding bottom padding for devices with a "home indicator" (iPhone)
              bottom: (hasLink ? 12.0 : 24.0) + MediaQuery.paddingOf(context).bottom,
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
                        sharedGift.name,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$${sharedGift.priceUsd.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description section
                if (sharedGift.description != null && sharedGift.description!.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sharedGift.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Action Buttons Section
                if (isOwner) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : onToggleVisibility,
                            icon: Icon(sharedGift.isVisible ? Icons.visibility : Icons.visibility_off, size: 18),
                            label: Text(
                              sharedGift.isVisible ? 'Hide' : 'Show',
                              textAlign: TextAlign.center,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: sharedGift.isVisible ? theme.colorScheme.primary : theme.colorScheme.error,
                              side: BorderSide(
                                color: sharedGift.isVisible ? theme.colorScheme.primary : theme.colorScheme.error,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : onDelete,
                            icon: isLoading ? const SizedBox.shrink() : const Icon(Icons.delete_outline, size: 18),
                            label: isLoading
                                ? const ButtonLoadingIndicator()
                                : const Text('Delete'),
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (isBookedByOther || isLoading) ? null : onBookToggle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBookedByMe ? theme.colorScheme.error : theme.colorScheme.primary,
                        foregroundColor: isBookedByMe ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                      ),
                      child: isLoading
                          ? const ButtonLoadingIndicator()
                          : Text(
                        isBookedByMe ? 'Unbook' :
                        isBookedByOther ? 'Booked' : 'Book',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],

                // Link Button
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