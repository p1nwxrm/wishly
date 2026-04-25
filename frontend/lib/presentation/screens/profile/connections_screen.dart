import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_subscription_models.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/cards/user_card.dart';

@RoutePage()
class ConnectionsScreen extends StatelessWidget implements AutoRouteWrapper {
  final int userId;
  final String username;
  final int initialTab;

  const ConnectionsScreen({
    super.key,
    required this.userId,
    required this.username,
    this.initialTab = 0,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SubscriptionBloc>(
      create: (context) => getIt<SubscriptionBloc>(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(username),
          centerTitle: true,
          leading: const AutoLeadingButton(),
          elevation: 0,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: theme.colorScheme.onPrimary,
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Followers Tab
            _ConnectionsListView(
              userId: userId,
              isFollowersTab: true,
            ),
            // Following Tab
            _ConnectionsListView(
              userId: userId,
              isFollowersTab: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionsListView extends StatefulWidget {
  final int userId;
  final bool isFollowersTab;

  const _ConnectionsListView({
    super.key,
    required this.userId,
    required this.isFollowersTab,
  });

  @override
  State<_ConnectionsListView> createState() => _ConnectionsListViewState();
}

class _ConnectionsListViewState extends State<_ConnectionsListView> {
  final Set<int> _loadingUserIds = {};
  List<UserConnectionModel>? _cachedConnections;

  @override
  void initState() {
    super.initState();
    // Initialize the initial data load
    _loadData();
  }

  // --------------------------------------------------------------------------
  // Extracted Methods (Actions & Callbacks)
  // --------------------------------------------------------------------------

  /// Loads the list of followers or following depending on the current tab.
  /// The [isRefresh] flag is used for pull-to-refresh or silent list updates.
  void _loadData({bool isRefresh = false}) {
    final bloc = context.read<SubscriptionBloc>();
    if (widget.isFollowersTab) {
      bloc.add(LoadUserFollowers(userId: widget.userId, isRefresh: isRefresh));
    } else {
      bloc.add(LoadUserFollowing(userId: widget.userId, isRefresh: isRefresh));
    }
  }

  /// Handles taps on a user card.
  /// Navigates to the user's profile and silently refreshes the current list upon return.
  Future<void> _handleUserTap(UserConnectionModel item) async {
    await context.router.push(OtherUserProfileRoute(username: item.user.username));

    // Check if the widget is mounted after returning from the screen
    if (!mounted) return;

    _loadData(isRefresh: true);
  }

  /// Handles taps on the Follow/Unfollow button.
  /// Includes validation logic (to prevent double clicks) and shows a confirmation dialog.
  void _handleFollowToggle(UserConnectionModel item, int currentUserId, bool isMyProfile) {
    final isItemLoading = _loadingUserIds.contains(item.user.id);
    if (isItemLoading) return; // Protection against spam clicks

    if (item.isFollowedByMe) {
      // If this is our own profile and the "Following" tab is active,
      // request confirmation before unfollowing.
      if (isMyProfile && !widget.isFollowersTab) {
        _showUnfollowConfirmationDialog(item, currentUserId);
      } else {
        _dispatchUnfollow(item.user.id, currentUserId);
      }
    } else {
      _dispatchFollow(item.user.id, currentUserId);
    }
  }

  /// Shows an AlertDialog to confirm unfollowing a user.
  void _showUnfollowConfirmationDialog(UserConnectionModel item, int currentUserId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Unfollow'),
          content: Text('Are you sure you want to unfollow @${item.user.username}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _dispatchUnfollow(item.user.id, currentUserId);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Unfollow'),
            ),
          ],
        );
      },
    );
  }

  /// Dispatches an unfollow event and adds the user to the loading state.
  void _dispatchUnfollow(int targetUserId, int currentUserId) {
    setState(() => _loadingUserIds.add(targetUserId));
    context.read<SubscriptionBloc>().add(UnfollowUser(
      targetUserId: targetUserId,
      currentUserId: currentUserId,
    ));
  }

  /// Dispatches a follow event and adds the user to the loading state.
  void _dispatchFollow(int targetUserId, int currentUserId) {
    setState(() => _loadingUserIds.add(targetUserId));
    context.read<SubscriptionBloc>().add(FollowUser(
      targetUserId: targetUserId,
      currentUserId: currentUserId,
    ));
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentUserState = context.read<UserBloc>().state;
    final currentUserId = currentUserState is UserLoaded ? currentUserState.user.id : 0;
    final bool isMyProfile = widget.userId == currentUserId;

    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        // Successful follow/unfollow action
        if (state is SubscriptionActionSuccess) {
          setState(() => _loadingUserIds.remove(state.targetUserId));
          AppSnackbars.showSuccess(context, state.message);

          // Silently refresh the list after a successful action
          _loadData(isRefresh: true);
        }
        // Follow/unfollow error
        else if (state is SubscriptionError) {
          setState(() => _loadingUserIds.clear());
          AppSnackbars.showError(context, state.message);
        }
      },
      builder: (context, state) {
        // Update the cache only if real list data arrived
        if (widget.isFollowersTab && state is FollowersLoaded) {
          _cachedConnections = state.followers;
        } else if (!widget.isFollowersTab && state is FollowingLoaded) {
          _cachedConnections = state.following;
        }

        // Show the main loader ONLY if there is no data at all yet
        if (_cachedConnections == null) {
          if (state is SubscriptionError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        }

        final connections = _cachedConnections!;

        // Empty list state
        if (connections.isEmpty) {
          return Center(
            child: Text(
              widget.isFollowersTab ? 'No followers yet.' : 'Not following anyone yet.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        // Main list with Pull-to-refresh
        return RefreshIndicator(
          onRefresh: () async => _loadData(isRefresh: true),
          child: ListView.separated(
            // Allows pull-to-refresh even with a short list
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: connections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = connections[index];
              final isMe = item.user.id == currentUserId;
              final isItemLoading = _loadingUserIds.contains(item.user.id);

              return UserCard(
                connection: item,
                currentUserId: currentUserId,
                isLoading: isItemLoading,
                // Block tap and follow logic if the card belongs to the current user
                onTap: isMe ? null : () => _handleUserTap(item),
                onFollowToggle: isMe ? null : () => _handleFollowToggle(item, currentUserId, isMyProfile),
              );
            },
          ),
        );
      },
    );
  }
}