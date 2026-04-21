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
class ConnectionsScreen extends StatelessWidget {
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

class _ConnectionsListView extends StatelessWidget {
  final int userId;
  final bool isFollowersTab;

  const _ConnectionsListView({
    required this.userId,
    required this.isFollowersTab,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch current user ID for follow/unfollow actions and self-check
    final currentUserState = context.read<UserBloc>().state;
    final currentUserId = currentUserState is UserLoaded ? currentUserState.user.id : 0;

    return BlocProvider<SubscriptionBloc>(
      create: (context) {
        final bloc = getIt<SubscriptionBloc>();
        if (isFollowersTab) {
          bloc.add(LoadUserFollowers(userId: userId));
        } else {
          bloc.add(LoadUserFollowing(userId: userId));
        }
        return bloc;
      },
      child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionActionSuccess) {
            AppSnackbars.showSuccess(context, state.message);
            // Refresh the current list silently after successful follow/unfollow action
            if (isFollowersTab) {
              context.read<SubscriptionBloc>().add(LoadUserFollowers(userId: userId, isRefresh: true));
            } else {
              context.read<SubscriptionBloc>().add(LoadUserFollowing(userId: userId, isRefresh: true));
            }
          } else if (state is SubscriptionError) {
            AppSnackbars.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          List<UserConnectionModel> connections = [];
          if (isFollowersTab && state is FollowersLoaded) {
            connections = state.followers;
          } else if (!isFollowersTab && state is FollowingLoaded) {
            connections = state.following;
          }

          if (connections.isEmpty && (state is FollowersLoaded || state is FollowingLoaded)) {
            return Center(
              child: Text(
                isFollowersTab ? 'No followers yet.' : 'Not following anyone yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (isFollowersTab) {
                context.read<SubscriptionBloc>().add(LoadUserFollowers(userId: userId, isRefresh: true));
              } else {
                context.read<SubscriptionBloc>().add(LoadUserFollowing(userId: userId, isRefresh: true));
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: connections.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = connections[index];
                final isMe = item.user.id == currentUserId;

                return UserCard(
                  connection: item,
                  currentUserId: currentUserId,
                  onTap: isMe
                      ? null
                      : () async {
                    await context.router.push(OtherUserProfileRoute(username: item.user.username));

                    if (!context.mounted) return;

                    if (isFollowersTab) {
                      context.read<SubscriptionBloc>().add(LoadUserFollowers(userId: userId, isRefresh: true));
                    } else {
                      context.read<SubscriptionBloc>().add(LoadUserFollowing(userId: userId, isRefresh: true));
                    }
                  },
                  onFollowToggle: isMe
                      ? null
                      : () {
                    final bloc = context.read<SubscriptionBloc>();
                    // Prevent spam clicking while already loading an action
                    if (bloc.state is SubscriptionLoading) return;

                    if (item.isFollowedByMe) {
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
      ),
    );
  }
}