import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/cards/feed_gift_card.dart';
import '../../widgets/common/custom_app_bar.dart';

@RoutePage()
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Load the feed when the screen is initialized
    context.read<FeedBloc>().add(const LoadFeed());
  }

  // Helper method to get the current user's ID
  int _getCurrentUserId() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      return userState.user.id;
    }
    return 0; // Fallback, though ideally UserLoaded should always be active here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = _getCurrentUserId();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Feed',
      ),
      // Listen to BookingBloc to refresh the feed when a booking changes
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingActionSuccess) {
            // Show a custom success toast
            AppSnackbars.showSuccess(context, state.message);
            // Refresh the feed to show the updated button states (booked/unbooked)
            context.read<FeedBloc>().add(const LoadFeed(isRefresh: true));
          } else if (state is BookingError) {
            // Show a custom error toast
            AppSnackbars.showError(context, state.message);
          }
        },
        child: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            if (state is FeedLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FeedError) {
              return _buildErrorState(theme, state.message);
            }

            if (state is FeedLoaded) {
              if (state.feedItems.isEmpty) {
                return _buildEmptyState(theme, context);
              }
              return _buildFeedList(state, currentUserId);
            }

            // Fallback for FeedInitial or unexpected states
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Builds the empty state UI when there are no gifts or friends
  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Decorative icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Empty state message
            Text(
              'No new gifts yet.',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Find friends to see their wishlists!',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Navigation button to Search tab
            ElevatedButton.icon(
              onPressed: () {
                // Switches the bottom navigation bar to the Search tab
                AutoTabsRouter.of(context).navigate(const SearchRoute());
              },
              icon: const Icon(Icons.search),
              label: const Text('Find Friends'),
            ),
          ],
        ),
      ),
    );
  }

  // Builds an error state with a retry button
  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<FeedBloc>().add(const LoadFeed());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the scrollable list of gift cards with Pull-to-Refresh
  Widget _buildFeedList(FeedLoaded state, int currentUserId) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FeedBloc>().add(const LoadFeed(isRefresh: true));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.feedItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final feedItem = state.feedItems[index];

          // Wrap individual card in a BlocBuilder to listen to its specific booking state
          return BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {
              // Determine if this exact card is currently loading a request
              final isThisCardLoading = bookingState is BookingLoading && bookingState.giftId == feedItem.gift.id;

              return FeedGiftCard(
                feedItem: feedItem,
                currentUserId: currentUserId,
                isLoading: isThisCardLoading,
                onDetailsTap: () {
                  // Navigate to Gift Details Screen
                  // TODO: implement GiftDetailsRoute
                  // context.pushRoute(GiftDetailsRoute(giftId: feedItem.gift.id));
                },
                onBookToggle: () {
                  // Check for mutual subscription before requesting to block
                  if (!feedItem.isMutualSubscription && feedItem.bookedBy != currentUserId) {
                    AppSnackbars.showError(
                        context,
                        'You and the owner must follow each other to book gifts!'
                    );
                    return;
                  }

                  // Check current booking state and dispatch appropriate event
                  if (feedItem.bookedBy == currentUserId) {
                    context.read<BookingBloc>().add(UnbookGift(giftId: feedItem.gift.id));
                  } else {
                    context.read<BookingBloc>().add(BookGift(giftId: feedItem.gift.id));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}