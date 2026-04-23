import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
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
          title: Text(
            username,
          ),
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
    // Dispatch initial load events when the view is created
    if (widget.isFollowersTab) {
      context.read<SubscriptionBloc>().add(LoadUserFollowers(userId: widget.userId));
    } else {
      context.read<SubscriptionBloc>().add(LoadUserFollowing(userId: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserState = context.read<UserBloc>().state;
    final currentUserId = currentUserState is UserLoaded ? currentUserState.user.id : 0;
    final bool isMyProfile = widget.userId == currentUserId;

    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionActionSuccess) {
          setState(() {
            _loadingUserIds.remove(state.targetUserId);
          });
          AppSnackbars.showSuccess(context, state.message);
          // Refresh the current list silently after successful follow/unfollow action
          if (widget.isFollowersTab) {
            context.read<SubscriptionBloc>().add(LoadUserFollowers(userId: widget.userId, isRefresh: true));
          } else {
            context.read<SubscriptionBloc>().add(LoadUserFollowing(userId: widget.userId, isRefresh: true));
          }
        } else if (state is SubscriptionError) {
          setState(() {
            _loadingUserIds.clear();
          });
          AppSnackbars.showError(context, state.message);
        }
      },
      builder: (context, state) {
        // Update the cache only if real data arrived
        if (widget.isFollowersTab && state is FollowersLoaded) {
          _cachedConnections = state.followers;
        } else if (!widget.isFollowersTab && state is FollowingLoaded) {
          _cachedConnections = state.following;
        }

        // Show the main spinner ONLY if there is no data at all yet
        if (_cachedConnections == null) {
          if (state is SubscriptionError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        }

        final connections = _cachedConnections!;

        if (connections.isEmpty) {
          return Center(
            child: Text(
              widget.isFollowersTab ? 'No followers yet.' : 'Not following anyone yet.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (widget.isFollowersTab) {
              context.read<SubscriptionBloc>().add(LoadUserFollowers(userId: widget.userId, isRefresh: true));
            } else {
              context.read<SubscriptionBloc>().add(LoadUserFollowing(userId: widget.userId, isRefresh: true));
            }
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh at all times
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
                onTap: isMe
                    ? null
                    : () async {
                  await context.router.push(OtherUserProfileRoute(username: item.user.username));

                  if (!context.mounted) return;

                  if (widget.isFollowersTab) {
                    context.read<SubscriptionBloc>().add(LoadUserFollowers(userId: widget.userId, isRefresh: true));
                  } else {
                    context.read<SubscriptionBloc>().add(LoadUserFollowing(userId: widget.userId, isRefresh: true));
                  }
                },
                onFollowToggle: isMe
                    ? null
                    : () {
                  final bloc = context.read<SubscriptionBloc>();

                  if (isItemLoading) return; // Prevent double clicks

                  if (item.isFollowedByMe) {
                    if (isMyProfile && !widget.isFollowersTab) {
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
                                  setState(() {
                                    _loadingUserIds.add(item.user.id);
                                  });
                                  bloc.add(UnfollowUser(
                                    targetUserId: item.user.id,
                                    currentUserId: currentUserId,
                                  ));
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
                    } else {
                      setState(() {
                        _loadingUserIds.add(item.user.id);
                      });
                      bloc.add(UnfollowUser(
                        targetUserId: item.user.id,
                        currentUserId: currentUserId,
                      ));
                    }
                  } else {
                    setState(() {
                      _loadingUserIds.add(item.user.id);
                    });
                    bloc.add(FollowUser(
                      targetUserId: item.user.id,
                      currentUserId: currentUserId,
                    ));
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}