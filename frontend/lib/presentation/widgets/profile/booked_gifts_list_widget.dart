import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/gift_models.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../cards/compact_gift_card.dart';

class BookedGiftsListWidget extends StatelessWidget {
  final List<SharedGiftModel> bookedGifts;
  final int currentUserId;
  final Future<void> Function() onRefresh;

  // Коллбэки для передачи действий на основной экран
  final void Function(SharedGiftModel sharedGift) onDetailsTap;
  final void Function(SharedGiftModel sharedGift) onUnbook;

  const BookedGiftsListWidget({
    super.key,
    required this.bookedGifts,
    required this.currentUserId,
    required this.onRefresh,
    required this.onDetailsTap,
    required this.onUnbook,
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
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        itemCount: bookedGifts.length,
        itemBuilder: (context, index) {
          final sharedGift = bookedGifts[index];

          // Wrap each card in a BlocBuilder to listen to its specific booking state
          return BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {
              // Check if THIS specific gift is currently processing an unbook request
              final isThisCardLoading = bookingState is BookingLoading && bookingState.giftId == sharedGift.gift.id;

              return CompactFeedGiftCard(
                sharedGift: sharedGift,
                currentUserId: currentUserId,
                isLoading: isThisCardLoading,
                showOwnerInfo: true, // We want to see whose gift we booked
                onDetailsTap: () => onDetailsTap(sharedGift),
                onBookToggle: () => onUnbook(sharedGift),
              );
            },
          );
        },
      ),
    );
  }
}