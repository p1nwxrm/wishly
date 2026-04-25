import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/wishlist_models.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/profile/profile.dart';
import '../../widgets/common/button_loading_indicator.dart';

@RoutePage()
class OtherUserProfileScreen extends StatelessWidget implements AutoRouteWrapper {
  final String username;

  const OtherUserProfileScreen({
    super.key,
    @PathParam('username') required this.username,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
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
      child: this,
    );
  }

  // --------------------------------------------------------------------------
  // Extracted Action Methods
  // --------------------------------------------------------------------------

  /// Retries loading the user profile
  void _retryLoadProfile(BuildContext context) {
    context.read<ProfileBloc>().add(LoadProfile(username: username));
  }

  /// Navigates to the Followers tab and refreshes profile data upon return
  Future<void> _navigateToFollowers(BuildContext context, int targetUserId, String targetUsername) async {
    await context.router.push(ConnectionsRoute(
      userId: targetUserId,
      username: targetUsername,
      initialTab: 0,
    ));

    if (context.mounted) {
      _retryLoadProfile(context);
    }
  }

  /// Navigates to the Following tab and refreshes profile data upon return
  Future<void> _navigateToFollowing(BuildContext context, int targetUserId, String targetUsername) async {
    await context.router.push(ConnectionsRoute(
      userId: targetUserId,
      username: targetUsername,
      initialTab: 1,
    ));

    if (context.mounted) {
      _retryLoadProfile(context);
    }
  }

  /// Dispatches the appropriate follow or unfollow event based on current status
  void _toggleFollowStatus(BuildContext context, bool isFollowing, int targetUserId, int currentUserId) {
    final bloc = context.read<SubscriptionBloc>();
    if (isFollowing) {
      bloc.add(UnfollowUser(targetUserId: targetUserId, currentUserId: currentUserId));
    } else {
      bloc.add(FollowUser(targetUserId: targetUserId, currentUserId: currentUserId));
    }
  }

  /// Dispatches an event to reload the target user's wishlists
  void _refreshWishlists(BuildContext context, int targetUserId) {
    context.read<WishlistBloc>().add(LoadUserWishlists(userId: targetUserId));
  }

  /// Navigates to the detailed view of a selected wishlist
  void _navigateToWishlistDetails(BuildContext context, WishlistModel wishlist) {
    context.router.push(WishlistDetailsRoute(wishlistId: wishlist.id));
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    final currentUserId = userState is UserLoaded ? userState.user.id : 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Added global theme background
      appBar: AppBar(
        title: Text(username),
        leading: const AutoLeadingButton(),
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen for profile loading to trigger wishlist fetching
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) => current is ProfileLoaded && previous is! ProfileLoaded,
            listener: (context, state) {
              if (state is ProfileLoaded) {
                final wishlistState = context.read<WishlistBloc>().state;
                // Only load wishlists if they aren't already loaded or loading
                if (wishlistState is! WishlistsListLoaded && wishlistState is! WishlistLoading) {
                  _refreshWishlists(context, state.profile.user.id);
                }
              }
            },
          ),
          // Listen for follow/unfollow actions to show snackbars and refresh profile
          BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionActionSuccess) {
                AppSnackbars.showSuccess(context, state.message);
                _retryLoadProfile(context);
              } else if (state is SubscriptionError) {
                AppSnackbars.showError(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // 1. Loading State
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error State
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
                      onPressed: () => _retryLoadProfile(context),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // 3. Success State (Profile Loaded)
            if (state is ProfileLoaded) {
              final theme = Theme.of(context);
              final profile = state.profile;
              final targetUserId = profile.user.id;
              final bool isFollowing = profile.isFollowedByMe;

              return Column(
                children: [
                  // Profile Header Component
                  ProfileHeaderWidget(
                    profile: profile,
                    currentUserId: currentUserId,
                    onFollowersTap: () => _navigateToFollowers(context, targetUserId, profile.user.username),
                    onFollowingTap: () => _navigateToFollowing(context, targetUserId, profile.user.username),
                  ),

                  // Follow / Unfollow Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                        builder: (context, subState) {
                          final isSubmitting = subState is SubscriptionLoading;

                          return ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => _toggleFollowStatus(context, isFollowing, targetUserId, currentUserId),
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

                  // User's Wishlists Area
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
                            onRefresh: () async => _refreshWishlists(context, targetUserId),
                            onWishlistTap: (wishlist) => _navigateToWishlistDetails(context, wishlist),
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

            // 4. Fallback (Empty state)
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}