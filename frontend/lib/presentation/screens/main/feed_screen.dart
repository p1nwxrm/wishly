import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/cards/feed_gift_card.dart';
import '../../widgets/bottom_sheets/detailed_gift_bottom_sheet.dart';

@RoutePage()
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Controller to manage the scroll position of the feed list
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Trigger initial data load for the feed
    context.read<FeedBloc>().add(const LoadFeed());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _scrollController.dispose();
    super.dispose();
  }

  // Smoothly animates the scroll position back to the top of the list
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Helper method to retrieve the currently authenticated user's ID
  int _getCurrentUserId() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      return userState.user.id;
    }
    return 0; // Default fallback if user is not loaded
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = _getCurrentUserId();

    // Listen for tab refresh events to scroll up and reload data
    return BlocListener<TabRefreshCubit, int?>(
      bloc: getIt<TabRefreshCubit>(),
      listener: (context, state) {
        // Triggered when the feed tab is tapped again
        if (state == 0) {
          context.read<FeedBloc>().add(const LoadFeed(isRefresh: true));
          _scrollToTop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wishly'),
          centerTitle: true,
        ),

        // Listen for booking actions (success or error) to show snackbars
        body: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingActionSuccess) {
              AppSnackbars.showSuccess(context, state.message);
              // Refresh the feed to reflect the new booking status
              context.read<FeedBloc>().add(const LoadFeed(isRefresh: true));
            } else if (state is BookingError) {
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
                return _buildFeedList(state, currentUserId, theme);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // UI for empty feed state
  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            ElevatedButton.icon(
              onPressed: () {
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

  // UI for error state with retry functionality
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
                // Retry loading the feed
                context.read<FeedBloc>().add(const LoadFeed());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the main list of feed items
  Widget _buildFeedList(FeedLoaded state, int currentUserId, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        // Trigger pull-to-refresh
        context.read<FeedBloc>().add(const LoadFeed(isRefresh: true));
      },
      child: ListView.separated(
        key: const PageStorageKey<String>('feed_list_key'),
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: state.feedItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final feedItem = state.feedItems[index];

          // Determine booking constraints
          final isBookedByMe = feedItem.bookedBy == currentUserId;
          final requiresMutualSubscription = !feedItem.isMutualSubscription && !isBookedByMe;

          return BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {
              // Check if this specific card is currently processing a booking action
              final isThisCardLoading = bookingState is BookingLoading && bookingState.giftId == feedItem.gift.id;

              return FeedGiftCard(
                feedItem: feedItem,
                currentUserId: currentUserId,
                isLoading: isThisCardLoading,

                // Show bottom sheet with detailed info when card is tapped
                onDetailsTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: theme.colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (ctx) {
                      // Provide existing BookingBloc to the bottom sheet
                      return BlocProvider.value(
                        value: context.read<BookingBloc>(),
                        child: DetailedGiftBottomSheet(
                          sharedGift: feedItem,
                          currentUserId: currentUserId,

                          // Handle book/unbook toggle inside bottom sheet
                          onBookToggle: () {
                            if (isBookedByMe) {
                              context.read<BookingBloc>().add(UnbookGift(giftId: feedItem.gift.id));
                              Navigator.of(ctx).pop();
                            } else {
                              if (requiresMutualSubscription) {
                                AppSnackbars.showError(
                                    ctx,
                                    'You and the owner must follow each other to book gifts!'
                                );
                                return;
                              }
                              context.read<BookingBloc>().add(BookGift(giftId: feedItem.gift.id));
                              Navigator.of(ctx).pop();
                            }
                          },

                          // Handle external link opening
                          onOpenLink: () async {
                            final link = feedItem.gift.linkUrl;
                            if (link != null && link.isNotEmpty) {
                              final url = Uri.parse(link);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                if (ctx.mounted) {
                                  AppSnackbars.showError(ctx, 'Could not launch link');
                                }
                              }
                            }
                          },
                        ),
                      );
                    },
                  );
                },

                // Handle book/unbook toggle directly from the card
                onBookToggle: () {
                  if (requiresMutualSubscription) {
                    AppSnackbars.showError(
                        context,
                        'You and the owner must follow each other to book gifts!'
                    );
                    return;
                  }

                  if (isBookedByMe) {
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