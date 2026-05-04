import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_models.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/lists/user_list_view.dart';

@RoutePage()
class SearchScreen extends StatefulWidget implements AutoRouteWrapper {
  const SearchScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SearchBloc>(),
        ),
        BlocProvider(
          // Replaced SubscriptionBloc with ConnectionBloc
          create: (context) => getIt<ConnectionBloc>(),
        ),
      ],
      child: this,
    );
  }

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Changed to track usernames since ConnectionBloc events use targetUsername
  final Set<String> _loadingUsernames = {};

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Extracted Methods (Actions & Callbacks)
  // --------------------------------------------------------------------------

  /// Scrolls the list back to the top seamlessly.
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Handles tap events from the bottom navigation bar to refresh the tab.
  void _handleTabRefresh(int? tabIndex) {
    // Triggered when the search tab is tapped again (assuming index is 1)
    if (tabIndex == 1) {
      final query = _searchController.text;
      if (query.trim().isEmpty) {
        context.read<SearchBloc>().add(ClearSearch());
      } else {
        context.read<SearchBloc>().add(RefreshSearch(query: query));
      }
      _scrollToTop();
    }
  }

  /// Handles changes in the search text field.
  void _handleSearchQueryChanged(String query) {
    setState(() {
      _loadingUsernames.clear();
    });

    // Reset the search if the field is cleared
    if (query.trim().isEmpty) {
      context.read<SearchBloc>().add(ClearSearch());
    } else {
      context.read<SearchBloc>().add(SearchUsers(query: query));
    }
  }

  /// Clears the search field and resets the state.
  void _handleClearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(ClearSearch());
  }

  /// Retries the search with the current query.
  void _handleRetrySearch() {
    final currentQuery = _searchController.text;
    if (currentQuery.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchUsers(query: currentQuery));
    } else {
      context.read<SearchBloc>().add(ClearSearch());
    }
  }

  /// Navigates to a user's profile and refreshes the search upon return.
  Future<void> _handleUserTap(SocialUserModel user) async {
    // Navigate to profile on tap and wait for it to return
    await context.pushRoute(
      PublicProfileRoute(username: user.username),
    );

    if (mounted) {
      _refreshCurrentSearch();
    }
  }

  /// Helper to refresh the current search query
  void _refreshCurrentSearch() {
    final currentQuery = _searchController.text;
    if (currentQuery.trim().isNotEmpty) {
      context.read<SearchBloc>().add(RefreshSearch(query: currentQuery));
    }
  }

  /// Toggles the follow/unfollow state for a specific user.
  void _handleFollowToggle(SocialUserModel user) {
    final targetUsername = user.username;

    // Prevent spamming the button while the action is loading
    if (_loadingUsernames.contains(targetUsername)) return;

    setState(() {
      _loadingUsernames.add(targetUsername);
    });

    final connectionBloc = context.read<ConnectionBloc>();
    final isFollowing = user.relationship?.isFollowing ?? false;

    if (isFollowing) {
      connectionBloc.add(UnfollowUser(targetUsername: targetUsername));
    } else {
      connectionBloc.add(FollowUser(targetUsername: targetUsername));
    }
  }

  /// Handles the connection state changes (success/error logic).
  void _handleConnectionStateChange(BuildContext context, ConnectionState state) {
    if (state is ConnectionError) {
      setState(() {
        _loadingUsernames.clear();
      });
      AppSnackbars.showError(context, state.message);
    } else if (state is FollowUserSuccess) {
      setState(() {
        _loadingUsernames.remove(state.targetUsername);
      });
      AppSnackbars.showSuccess(context, state.message);
      _refreshCurrentSearch();
    } else if (state is UnfollowUserSuccess) {
      setState(() {
        _loadingUsernames.remove(state.targetUsername);
      });
      AppSnackbars.showSuccess(context, state.message);
      _refreshCurrentSearch();
    }
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get the current user ID from UserBloc so the card knows where "You" is
    final userState = context.read<UserBloc>().state;
    final currentUserId = userState is UserLoaded ? userState.user.id : 0;

    return MultiBlocListener(
      listeners: [
        // Listen for tab refresh events to scroll up
        BlocListener<TabRefreshCubit, int?>(
          bloc: getIt<TabRefreshCubit>(),
          listener: (context, state) => _handleTabRefresh(state),
        ),

        // Clear loading usernames when the search state changes
        BlocListener<SearchBloc, SearchState>(
          listener: (context, state) {
            if (state is SearchLoaded || state is SearchError || state is SearchInitial) {
              setState(() {
                _loadingUsernames.clear();
              });
            }
          },
        ),

        // Listen for connection actions (success or error) to show snackbars
        BlocListener<ConnectionBloc, ConnectionState>(
          listener: _handleConnectionStateChange,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
        ),
        body: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearchQueryChanged,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _handleClearSearch,
                  ),
                ),
              ),
            ),

            // Search results list
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  // Initial state
                  if (state is SearchInitial) {
                    return Center(
                      child: Text(
                        'Start typing to find users...',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  // Loading state
                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Error state
                  if (state is SearchError) {
                    return SearchErrorView(
                      message: state.message,
                      onRetry: _handleRetrySearch,
                    );
                  }

                  // Loaded state
                  if (state is SearchLoaded) {
                    final users = state.users; // Assumed to be List<SocialUserModel>

                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          'No users found.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    }

                    return UserListView(
                      users: users,
                      currentUserId: currentUserId,
                      loadingUsernames: _loadingUsernames,
                      scrollController: _scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      onUserTap: _handleUserTap,
                      onFollowToggle: _handleFollowToggle,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SearchErrorView({
    super.key,
    required this.message,
    required this.onRetry,
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
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}