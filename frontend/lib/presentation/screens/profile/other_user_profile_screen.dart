import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/profile/profile.dart';
import '../../widgets/common/button_loading_indicator.dart';

@RoutePage()
class OtherUserProfileScreen extends StatelessWidget {
  final String username;

  const OtherUserProfileScreen({
    super.key,
    @PathParam('username') required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    final currentUserId = userState is UserLoaded ? userState.user.id : 0;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) => getIt<ProfileBloc>()..add(LoadProfile(username: username)),
        ),
        BlocProvider<WishlistBloc>(
          create: (context) => getIt<WishlistBloc>(),
        ),
        BlocProvider<SubscriptionBloc>(
          create: (context) => getIt<SubscriptionBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(username),
          leading: const AutoLeadingButton(),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ProfileBloc, ProfileState>(
              listenWhen: (previous, current) => current is ProfileLoaded && previous is! ProfileLoaded,
              listener: (context, state) {
                if (state is ProfileLoaded) {
                  context.read<WishlistBloc>().add(LoadUserWishlists(userId: state.profile.user.id));
                }
              },
            ),
            BlocListener<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (state is SubscriptionActionSuccess) {
                  AppSnackbars.showSuccess(context, state.message);
                  // Reload the profile to update the Followers count and the Follow button state
                  context.read<ProfileBloc>().add(LoadProfile(username: username));
                } else if (state is SubscriptionError) {
                  AppSnackbars.showError(context, state.message);
                }
              },
            ),
          ],
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProfileError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProfileBloc>().add(LoadProfile(username: username));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProfileLoaded) {
                final theme = Theme.of(context);
                final profile = state.profile;
                final targetUserId = profile.user.id;
                final bool isFollowing = profile.isFollowedByMe;

                return Column(
                  children: [
                    ProfileHeaderWidget(
                      profile: profile,
                      currentUserId: currentUserId,
                      onFollowersTap: () async {
                        await context.router.push(ConnectionsRoute(
                            userId: targetUserId,
                            username: profile.user.username,
                            initialTab: 0
                        ));

                        if (context.mounted) {
                          context.read<ProfileBloc>().add(LoadProfile(username: username));
                        }
                      },
                      onFollowingTap: () async {
                        await context.router.push(ConnectionsRoute(
                            userId: targetUserId,
                            username: profile.user.username,
                            initialTab: 1
                        ));

                        if (context.mounted) {
                          context.read<ProfileBloc>().add(LoadProfile(username: username));
                        }
                      },
                    ),

                    // Wrapped the button in BlocBuilder<SubscriptionBloc, ...>
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                          builder: (context, subState) {
                            // Check if a network request is currently in progress
                            final isSubmitting = subState is SubscriptionLoading;

                            return ElevatedButton(
                              // Disable presses (pass null) while the request is in progress
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                if (isFollowing) {
                                  context.read<SubscriptionBloc>().add(UnfollowUser(
                                    targetUserId: targetUserId,
                                    currentUserId: currentUserId,
                                  ));
                                } else {
                                  context.read<SubscriptionBloc>().add(FollowUser(
                                    targetUserId: targetUserId,
                                    currentUserId: currentUserId,
                                  ));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                foregroundColor: isFollowing
                                    ? theme.colorScheme.onError
                                    : theme.colorScheme.onPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              // Show a loader instead of text if loading is in progress
                              child: isSubmitting
                                  ? const ButtonLoadingIndicator()
                                  : Text(
                                isFollowing ? 'Unfollow' : 'Follow',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Divider(height: 1),

                    Expanded(
                      child: BlocBuilder<WishlistBloc, WishlistState>(
                        builder: (context, wishlistState) {
                          if (wishlistState is WishlistLoading || wishlistState is WishlistInitial) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (wishlistState is WishlistsListLoaded) {
                            return WishlistsListWidget(
                              wishlists: wishlistState.wishlists,
                              currentUserId: currentUserId,
                              onRefresh: () async {
                                context.read<WishlistBloc>().add(LoadUserWishlists(userId: targetUserId));
                              },
                              onWishlistTap: (wishlist) {
                                // context.router.push(WishlistDetailsRoute(wishlistId: wishlist.id));
                              },
                            );
                          }

                          if (wishlistState is WishlistError) {
                            return Center(
                              child: Text(
                                'Failed to load wishlists.',
                                style: TextStyle(color: theme.colorScheme.error),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}