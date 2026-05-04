import 'package:flutter/material.dart' hide ConnectionState;
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/wishlist_models.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/profile/profile.dart';
import '../../widgets/lists/wishlists_list_widget.dart';
import '../../widgets/common/button_loading_indicator.dart';

@RoutePage()
class PublicProfileScreen extends StatelessWidget implements AutoRouteWrapper {
  final String username;

  const PublicProfileScreen({
    super.key,
    @PathParam('username') required this.username,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PublicProfileBloc>(
          create: (context) => getIt<PublicProfileBloc>()..add(LoadPublicProfile(username: username)),
        ),
        BlocProvider<WishlistBloc>(
          create: (context) => getIt<WishlistBloc>(),
        ),
        BlocProvider<ConnectionBloc>(
          create: (context) => getIt<ConnectionBloc>(),
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
    context.read<PublicProfileBloc>().add(LoadPublicProfile(username: username));
  }

  /// Navigates to the Followers tab and refreshes profile data upon return
  Future<void> _navigateToFollowers(BuildContext context, int targetUserId, String targetUsername) async {
    await context.router.push(ConnectionsRoute(
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
      username: targetUsername,
      initialTab: 1,
    ));

    if (context.mounted) {
      _retryLoadProfile(context);
    }
  }

  /// Dispatches the appropriate follow or unfollow event based on current status
  void _toggleFollowStatus(BuildContext context, bool isFollowing, String targetUsername) {
    final bloc = context.read<ConnectionBloc>();
    if (isFollowing) {
      bloc.add(UnfollowUser(targetUsername: targetUsername));
    } else {
      bloc.add(FollowUser(targetUsername: targetUsername));
    }
  }

  /// Dispatches an event to load the target user's wishlists initially
  void _loadWishlists(BuildContext context) {
    context.read<WishlistBloc>().add(LoadUserWishlists(username: username));
  }

  /// Dispatches a silent refresh for the user's wishlists
  Future<void> _refreshWishlists(BuildContext context) async {
    context.read<WishlistBloc>().add(RefreshUserWishlists(username: username));
  }

  /// Navigates to the detailed view of a selected wishlist
  void _navigateToWishlistDetails(BuildContext context, WishlistBaseModel wishlist) {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(username),
        leading: const AutoLeadingButton(),
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen for profile loading to trigger wishlist fetching
          BlocListener<PublicProfileBloc, PublicProfileState>(
            listenWhen: (previous, current) => current is PublicProfileLoaded && previous is! PublicProfileLoaded,
            listener: (context, state) {
              if (state is PublicProfileLoaded) {
                final wishlistState = context.read<WishlistBloc>().state;
                // Only load wishlists if they aren't already loaded or loading
                if (wishlistState is! UserWishlistsLoaded && wishlistState is! WishlistLoading) {
                  _loadWishlists(context);
                }
              }
            },
          ),
          // Listen for follow/unfollow actions to update UI and show snackbars
          BlocListener<ConnectionBloc, ConnectionState>(
            listener: (context, state) {
              if (state is FollowUserSuccess) {
                AppSnackbars.showSuccess(context, state.message);
                // Optimistically update the UI without an extra network call
                context.read<PublicProfileBloc>().add(const UpdateProfileFollowStatus(isNowFollowing: true));
              } else if (state is UnfollowUserSuccess) {
                AppSnackbars.showSuccess(context, state.message);
                // Optimistically update the UI without an extra network call
                context.read<PublicProfileBloc>().add(const UpdateProfileFollowStatus(isNowFollowing: false));
              } else if (state is ConnectionError) {
                AppSnackbars.showError(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<PublicProfileBloc, PublicProfileState>(
          builder: (context, state) {
            // 1. Loading State
            if (state is PublicProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error State
            if (state is PublicProfileError) {
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
            if (state is PublicProfileLoaded) {
              final theme = Theme.of(context);
              final profile = state.profile;

              final targetUserId = profile.id;
              final targetUsername = profile.username;
              // Extract follow status safely from relationship model
              final bool isFollowing = profile.relationship?.isFollowing ?? false;

              return Column(
                children: [
                  // Profile Header Component
                  ProfileHeaderWidget(
                    profile: profile,
                    currentUserId: currentUserId,
                    onFollowersTap: () => _navigateToFollowers(context, targetUserId, targetUsername),
                    onFollowingTap: () => _navigateToFollowing(context, targetUserId, targetUsername),
                  ),

                  // Follow / Unfollow Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ConnectionBloc, ConnectionState>(
                        builder: (context, connState) {
                          final isSubmitting = connState is ConnectionLoading;

                          return ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => _toggleFollowStatus(context, isFollowing, targetUsername),
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

                        if (wishlistState is UserWishlistsLoaded) {
                          return WishlistsListWidget(
                            userWishlistsData: wishlistState.data,
                            currentUserId: currentUserId,
                            onRefresh: () => _refreshWishlists(context),
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