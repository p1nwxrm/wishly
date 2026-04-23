import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/blocs.dart';
import '../../widgets/cards/user_card.dart';
import '../../utils/app_snackbars.dart';

@RoutePage()
class SearchScreen extends StatefulWidget implements AutoRouteWrapper {
  const SearchScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    // Standardizing on AutoRouteWrapper for dependency injection on a route level
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SearchBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<SubscriptionBloc>(),
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

  final Set<int> _loadingUserIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get the current user ID from UserBloc so the card knows where "You" is
    final userState = context.read<UserBloc>().state;
    final currentUserId = userState is UserLoaded ? userState.user.id : 0;

    return MultiBlocListener(
      listeners: [
        // 1. Listen for tab refresh events to scroll up
        BlocListener<TabRefreshCubit, int?>(
          bloc: getIt<TabRefreshCubit>(),
          listener: (context, state) {
            // Triggered when the search tab is tapped again (assuming index is 1)
            if (state == 1) {
              final query = _searchController.text;
              if (query.trim().isEmpty) {
                context.read<SearchBloc>().add(ClearSearch());
              } else {
                context.read<SearchBloc>().add(RefreshSearch(query: query));
              }
              _scrollToTop();
            }
          },
        ),

        BlocListener<SearchBloc, SearchState>(
          listener: (context, state) {
            if (state is SearchLoaded || state is SearchError || state is SearchInitial) {
              setState(() {
                _loadingUserIds.clear();
              });
            }
          },
        ),

        // 2. Listen for subscription actions (success or error) to show snackbars
        BlocListener<SubscriptionBloc, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionError) {
              setState(() {
                _loadingUserIds.clear();
              });
            }

            if (state is SubscriptionActionSuccess) {
              setState(() {
                _loadingUserIds.remove(state.targetUserId);
              });
            }

            if (state is SubscriptionActionSuccess) {
              AppSnackbars.showSuccess(context, state.message);

              // Refresh the current search query to update "isFollowedByMe" statuses
              final currentQuery = _searchController.text;
              if (currentQuery.trim().isNotEmpty) {
                context.read<SearchBloc>().add(RefreshSearch(query: currentQuery));
              }
            } else if (state is SubscriptionError) {
              AppSnackbars.showError(context, state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
        ),
        body: Column(
          children: [
            // 1. Search field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _loadingUserIds.clear();
                  });

                  // Reset the search if the field is cleared
                  if (query.trim().isEmpty) {
                    context.read<SearchBloc>().add(ClearSearch());
                  } else {
                    context.read<SearchBloc>().add(SearchUsers(query: query));
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchBloc>().add(ClearSearch());
                    },
                  ),
                ),
              ),
            ),

            // 2. Search results list
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return Center(
                      child: Text(
                        'Start typing to find users...',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is SearchError) {
                    return SearchErrorView(
                      message: state.message,
                      onRetry: () {
                        final currentQuery = _searchController.text;
                        if (currentQuery.trim().isNotEmpty) {
                          context.read<SearchBloc>().add(SearchUsers(query: currentQuery));
                        } else {
                          context.read<SearchBloc>().add(ClearSearch());
                        }
                      },
                    );
                  }

                  if (state is SearchLoaded) {
                    final users = state.users;

                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          'No users found.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: _scrollController, // Attach controller here
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      // Add bottom padding for better scroll appearance
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        final userConnection = users[index];
                        final isMe = currentUserId == userConnection.user.id;

                        return UserCard(
                          connection: userConnection,
                          currentUserId: currentUserId,
                          isLoading: _loadingUserIds.contains(userConnection.user.id),
                          onTap: () async {
                            // Navigate to profile on tap and wait for it to return
                            await context.pushRoute(
                              OtherUserProfileRoute(username: userConnection.user.username),
                            );

                            if (context.mounted) {
                              final currentQuery = _searchController.text;
                              if (currentQuery.trim().isNotEmpty) {
                                context.read<SearchBloc>().add(RefreshSearch(query: currentQuery));
                              }
                            }
                          },
                          // 3. Implemented Follow/Unfollow toggle directly (no dialog)
                          onFollowToggle: isMe
                              ? null // Disable button if it's the current user
                              : () {
                            final subBloc = context.read<SubscriptionBloc>();

                            if (_loadingUserIds.contains(userConnection.user.id)) return;

                            setState(() {
                              _loadingUserIds.add(userConnection.user.id);
                            });

                            if (userConnection.isFollowedByMe) {
                              subBloc.add(UnfollowUser(
                                targetUserId: userConnection.user.id,
                                currentUserId: currentUserId,
                              ));
                            } else {
                              subBloc.add(FollowUser(
                                targetUserId: userConnection.user.id,
                                currentUserId: currentUserId,
                              ));
                            }

                            /*
                            if (mounted && _loadingUserIds.contains(userConnection.user.id)) {
                              setState(() {
                                _loadingUserIds.remove(userConnection.user.id);
                              });
                              final currentQuery = _searchController.text;
                              if (currentQuery.trim().isNotEmpty) {
                                context.read<SearchBloc>().add(RefreshSearch(query: currentQuery));
                              }
                            }

                             */
                          },
                        );
                      },
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