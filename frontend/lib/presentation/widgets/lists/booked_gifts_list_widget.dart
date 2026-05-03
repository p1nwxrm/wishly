import 'package:flutter/material.dart';

import '../../../data/models/gift_models.dart';
import '../cards/compact_gift_card.dart';

/// A reusable list view for displaying a list of booked [SharedGiftModel]s.
/// It handles empty states and individual loading states for items.
class BookedGiftsListWidget extends StatelessWidget {
  final List<SharedGiftModel> bookedGifts;
  final int currentUserId;

  /// A set of gift IDs that are currently in a loading state (e.g., being unbooked).
  final Set<int> loadingGiftIds;

  final Future<void> Function() onRefresh;
  final ValueChanged<SharedGiftModel> onDetailsTap;
  final ValueChanged<SharedGiftModel> onBookToggle;

  const BookedGiftsListWidget({
    super.key,
    required this.bookedGifts,
    required this.currentUserId,
    required this.loadingGiftIds,
    required this.onRefresh,
    required this.onDetailsTap,
    required this.onBookToggle,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Handle Empty State
    if (bookedGifts.isEmpty) {
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
                        Icons.bookmark_border,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No booked gifts yet',
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

    // 2. Render the list of booked gifts
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        itemCount: bookedGifts.length,
        // Added separatorBuilder for cleaner list spacing, similar to UserListView
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sharedGift = bookedGifts[index];

          // Check if this specific gift's ID is in the loading set
          final isThisCardLoading = loadingGiftIds.contains(sharedGift.id);

          return CompactFeedGiftCard(
            sharedGift: sharedGift,
            currentUserId: currentUserId,
            isLoading: isThisCardLoading,
            showOwnerInfo: true, // We want to see whose gift we booked
            onDetailsTap: () => onDetailsTap(sharedGift),
            onBookToggle: () => onBookToggle(sharedGift),
          );
        },
      ),
    );
  }
}