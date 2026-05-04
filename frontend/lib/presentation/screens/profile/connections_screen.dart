import 'package:flutter/material.dart' hide ConnectionState;
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_models.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/lists/user_list_view.dart';

@RoutePage()
class ConnectionsScreen extends StatelessWidget implements AutoRouteWrapper {
  final String username;
  final int initialTab;

  const ConnectionsScreen({
    super.key,
    required this.username,
    this.initialTab = 0,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ConnectionBloc>(
      create: (context) => getIt<ConnectionBloc>(),
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
              targetUsername: username,
              isFollowersTab: true,
            ),
            // Following Tab
            _ConnectionsListView(
              targetUsername: username,
              isFollowersTab: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionsListView extends StatefulWidget {
  final String targetUsername;
  final bool isFollowersTab;

  const _ConnectionsListView({
    super.key,
    required this.targetUsername,
    required this.isFollowersTab,
  });

  @override
  State<_ConnectionsListView> createState() => _ConnectionsListViewState();
}

class _ConnectionsListViewState extends State<_ConnectionsListView> {
  final Set<String> _loadingUsernames = {};
  List<SocialUserModel>? _cachedConnections;

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
    final bloc = context.read<ConnectionBloc>();

    if (widget.isFollowersTab) {
      bloc.add(isRefresh
          ? RefreshUserFollowers(targetUsername: widget.targetUsername)
          : LoadUserFollowers(targetUsername: widget.targetUsername));
    } else {
      bloc.add(isRefresh
          ? RefreshUserFollowing(targetUsername: widget.targetUsername)
          : LoadUserFollowing(targetUsername: widget.targetUsername));
    }
  }

  /// Handles taps on a user card.
  Future<void> _handleUserTap(SocialUserModel item) async {
    await context.router.push(PublicProfileRoute(username: item.username));

    // Check if the widget is mounted after returning from the profile screen
    if (!mounted) return;

    _loadData(isRefresh: true);
  }

  /// Handles taps on the Follow/Unfollow button.
  void _handleFollowToggle(SocialUserModel item, bool isMyProfile) {
    final isItemLoading = _loadingUsernames.contains(item.username);
    if (isItemLoading) return; // Protection against spam clicks

    final isFollowedByMe = item.relationship?.isFollowing ?? false;

    if (isFollowedByMe) {
      // If this is our own profile and the "Following" tab is active,
      // request confirmation before unfollowing.
      if (isMyProfile && !widget.isFollowersTab) {
        _showUnfollowConfirmationDialog(item);
      } else {
        _dispatchUnfollow(item.username);
      }
    } else {
      _dispatchFollow(item.username);
    }
  }

  /// Shows an AlertDialog to confirm unfollowing a user.
  void _showUnfollowConfirmationDialog(SocialUserModel item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Unfollow'),
          content: Text('Are you sure you want to unfollow @${item.username}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _dispatchUnfollow(item.username);
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

  void _dispatchUnfollow(String targetUsername) {
    setState(() => _loadingUsernames.add(targetUsername));
    context.read<ConnectionBloc>().add(UnfollowUser(targetUsername: targetUsername));
  }

  void _dispatchFollow(String targetUsername) {
    setState(() => _loadingUsernames.add(targetUsername));
    context.read<ConnectionBloc>().add(FollowUser(targetUsername: targetUsername));
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentUserState = context.read<UserBloc>().state;
    final currentUserId = currentUserState is UserLoaded ? currentUserState.user.id : 0;

    final currentUsername = currentUserState is UserLoaded ? currentUserState.user.username : '';
    final bool isMyProfile = widget.targetUsername == currentUsername;

    return BlocConsumer<ConnectionBloc, ConnectionState>(
      listener: (context, state) {
        // Successful follow action
        if (state is FollowUserSuccess) {
          setState(() => _loadingUsernames.remove(state.targetUsername));
          AppSnackbars.showSuccess(context, state.message);
          _loadData(isRefresh: true);
        }
        // Successful unfollow action
        else if (state is UnfollowUserSuccess) {
          setState(() => _loadingUsernames.remove(state.targetUsername));
          AppSnackbars.showSuccess(context, state.message);
          _loadData(isRefresh: true);
        }
        // Error state
        else if (state is ConnectionError) {
          setState(() => _loadingUsernames.clear());
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
          if (state is ConnectionError) {
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
        return UserListView(
          users: connections,
          currentUserId: currentUserId,
          loadingUsernames: _loadingUsernames,
          onRefresh: () async => _loadData(isRefresh: true),
          onUserTap: (user) => _handleUserTap(user),
          onFollowToggle: (user) => _handleFollowToggle(user, isMyProfile),
        );
      },
    );
  }
}