import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/gift_models.dart';
import '../../blocs/blocs.dart';
import '../../widgets/common/app_snackbars.dart';
import '../../widgets/cards/feed_gift_card.dart';
import '../../widgets/bottom_sheets/detailed_gift_bottom_sheet.dart';

@RoutePage()
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Controller to manage the scroll position and pagination
  final ScrollController _scrollController = ScrollController();

  // Throttle timer to prevent spamming the Bloc with events
  DateTime? _lastLoadTime;

  @override
  void initState() {
    super.initState();
    // Add listener for pagination
    _scrollController.addListener(_onScroll);
    // Trigger initial data load for the feed
    context.read<FeedBloc>().add(LoadInitialFeed());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Extracted Methods (Actions & Callbacks)
  // --------------------------------------------------------------------------

  /// Detects when the user scrolls near the bottom to load more items
  void _onScroll() {
    // 1. Check if we are within 200 pixels of the bottom
    final isNearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    // 2. Check if the user is actually scrolling DOWN
    final isScrollingDown = _scrollController.position.userScrollDirection == ScrollDirection.reverse;

    if (isNearBottom && isScrollingDown) {
      final feedState = context.read<FeedBloc>().state;

      // 3. Check if the feed is loaded AND we have more items to fetch
      if (feedState is FeedLoaded && !feedState.hasReachedMax) {

        // 4. Debounce: Allow triggering pagination only once per second
        final now = DateTime.now();
        if (_lastLoadTime == null || now.difference(_lastLoadTime!) > const Duration(seconds: 1)) {
          _lastLoadTime = now;
          context.read<FeedBloc>().add(LoadMoreFeed());
        }
      }
    }
  }

  /// Smoothly animates the scroll position back to the top of the list
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Helper method to retrieve the currently authenticated user's ID
  int _getCurrentUserId() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      return userState.user.id;
    }
    return 0; // Default fallback if user is not loaded
  }

  /// Helper method to retrieve the currently authenticated user's username
  String _getCurrentUsername() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      return userState.user.username;
    }
    return '';
  }

  /// Triggers a silent pull-to-refresh
  Future<void> _handleRefreshFeed() async {
    context.read<FeedBloc>().add(RefreshFeed());
  }

  /// Retries loading the feed initially when an error has occurred
  void _handleRetryFeed() {
    context.read<FeedBloc>().add(LoadInitialFeed());
  }

  /// Navigates the user to the Search tab to find friends
  void _navigateToFindFriends() {
    AutoTabsRouter.of(context).navigate(const SearchRoute());
  }

  /// Handles the logic for booking or unbooking a gift
  void _handleBookToggle(SharedGiftModel feedItem, int currentUserId) {
    // Model flat structure: properties are directly on feedItem
    final isBookedByMe = feedItem.bookedByUserId == currentUserId;

    if (isBookedByMe) {
      context.read<BookingBloc>().add(UnbookGift(giftId: feedItem.id));
    } else {
      context.read<BookingBloc>().add(BookGift(giftId: feedItem.id));
    }
  }

  /// Navigates the user to the profile of the gift owner
  void _navigateToUserProfile(String currentUsername, String targetUsername) {
    if (currentUsername == targetUsername) {
      AutoTabsRouter.of(context).navigate(const MyProfileRoute());
    } else {
      AutoRouter.of(context).push(PublicProfileRoute(username: targetUsername));
    }
  }

  /// Attempts to open the provided URL link in an external browser
  Future<void> _handleOpenExternalLink(BuildContext context, String? link) async {
    if (link != null && link.isNotEmpty) {
      final url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppSnackbars.showError(context, 'Could not launch link');
        }
      }
    }
  }

  /// Displays a detailed bottom sheet for a specific gift item
  void _showDetailedGiftBottomSheet(SharedGiftModel feedItem, int currentUserId, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Provide the existing BookingBloc to the bottom sheet widget tree
        return BlocProvider.value(
          value: context.read<BookingBloc>(),
          child: DetailedGiftBottomSheet(
            sharedGift: feedItem,
            currentUserId: currentUserId,
            onBookToggle: () {
              _handleBookToggle(feedItem, currentUserId);
              // Close the bottom sheet immediately after dispatching the action
              Navigator.of(ctx).pop();
            },
            onOpenLink: () => _handleOpenExternalLink(ctx, feedItem.linkUrl),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = _getCurrentUserId();
    final currentUsername = _getCurrentUsername();

    // Listen for tab refresh events (e.g., user taps the active tab icon)
    return BlocListener<TabRefreshCubit, int?>(
      bloc: getIt<TabRefreshCubit>(),
      listener: (context, state) {
        // Index 0 assumes the Feed is the first tab
        if (state == 0) {
          _handleRefreshFeed();
          _scrollToTop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wishly'),
          centerTitle: true,
        ),
        // Listen for booking actions globally to show snackbars and refresh feed
        body: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingActionSuccess) {
              AppSnackbars.showSuccess(context, state.message);
              // Refresh the feed to reflect the new booking status accurately
              _handleRefreshFeed();
            } else if (state is BookingError) {
              AppSnackbars.showError(context, state.message);
            }
          },
          child: BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              // Loading state
              if (state is FeedLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (state is FeedError) {
                return FeedErrorView(
                  message: state.message,
                  onRetryPressed: _handleRetryFeed,
                );
              }

              // Success state
              if (state is FeedLoaded) {
                if (state.feedItems.isEmpty) {
                  return FeedEmptyView(
                    onFindFriendsPressed: _navigateToFindFriends,
                  );
                }

                return FeedListView(
                  feedItems: state.feedItems,
                  hasReachedMax: state.hasReachedMax,
                  currentUserId: currentUserId,
                  scrollController: _scrollController,
                  onRefresh: _handleRefreshFeed,
                  onDetailsTap: (feedItem) => _showDetailedGiftBottomSheet(feedItem, currentUserId, theme),
                  onBookToggle: (feedItem) => _handleBookToggle(feedItem, currentUserId),
                  onUserTap: (feedItem) => _navigateToUserProfile(currentUsername, feedItem.owner.username),
                );
              }

              // Fallback
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Standalone UI Components
// --------------------------------------------------------------------------

/// Widget representing the UI when the feed has no items
class FeedEmptyView extends StatelessWidget {
  final VoidCallback onFindFriendsPressed;

  const FeedEmptyView({
    super.key,
    required this.onFindFriendsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              onPressed: onFindFriendsPressed,
              icon: const Icon(Icons.search),
              label: const Text('Find Friends'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget representing the UI when an error occurs while loading the feed
class FeedErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetryPressed;

  const FeedErrorView({
    super.key,
    required this.message,
    required this.onRetryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              onPressed: onRetryPressed,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget representing the scrollable list of feed items
class FeedListView extends StatelessWidget {
  final List<SharedGiftModel> feedItems;
  final bool hasReachedMax;
  final int currentUserId;
  final ScrollController scrollController;

  final Future<void> Function() onRefresh;

  final ValueChanged<SharedGiftModel> onDetailsTap;
  final ValueChanged<SharedGiftModel> onBookToggle;
  final ValueChanged<SharedGiftModel> onUserTap;

  const FeedListView({
    super.key,
    required this.feedItems,
    required this.hasReachedMax,
    required this.currentUserId,
    required this.scrollController,
    required this.onRefresh,
    required this.onDetailsTap,
    required this.onBookToggle,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        key: const PageStorageKey<String>('feed_list_key'),
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: feedItems.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= feedItems.length) {
            // If there are no more items to load, show a completion message
            if (hasReachedMax) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    "You've viewed the entire feed 🎉",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            // If there are more items to load, show a spinner
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final feedItem = feedItems[index];

          // Rebuild only this specific card when its booking state changes
          return BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {
              // Updated to BookingGiftLoading to match the new BookingBloc state
              final isThisCardLoading = bookingState is BookingGiftLoading &&
                  bookingState.giftId == feedItem.id;

              return FeedGiftCard(
                feedItem: feedItem,
                currentUserId: currentUserId,
                isLoading: isThisCardLoading,
                onDetailsTap: () => onDetailsTap(feedItem),
                onBookToggle: () => onBookToggle(feedItem),
                onUserTap: () => onUserTap(feedItem),
              );
            },
          );
        },
      ),
    );
  }
}