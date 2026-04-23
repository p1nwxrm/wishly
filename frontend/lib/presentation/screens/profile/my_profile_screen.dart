import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/wishlist_models.dart';
import '../../blocs/blocs.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/profile/profile.dart';
import '../../widgets/bottom_sheets/bottom_sheets.dart';

@RoutePage()
class MyProfileScreen extends StatefulWidget implements AutoRouteWrapper {
  const MyProfileScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    final username = userState is UserLoaded ? userState.user.username : '';

    context.read<BookingBloc>().add(LoadMyBookings());

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) {
            final bloc = getIt<ProfileBloc>();
            if (username.isNotEmpty) {
              bloc.add(LoadProfile(username: username));
            }
            return bloc;
          },
        ),
        BlocProvider<WishlistBloc>(
          create: (context) => getIt<WishlistBloc>()..add(const LoadMyWishlists()),
        ),
      ],
      child: this,
    );
  }

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> with AutoRouteAwareStateMixin<MyProfileScreen> {

  void _refreshData() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<ProfileBloc>().add(LoadProfile(username: userState.user.username));
    }
  }

  @override
  void didPopNext() {
    _refreshData();
  }

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;

    // If user data is not loaded yet, show a loading indicator
    if (userState is! UserLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = userState.user;
    final currentUserId = currentUser.id;

    // BlocListener listens to global navigation events (e.g., double tap on a tab)
    return BlocListener<TabRefreshCubit, int?>(
      bloc: getIt<TabRefreshCubit>(),
      listener: (context, state) {
        // If the tab index is 2 (our profile), forcefully refresh all screen data
        if (state == 2) {
          context.read<ProfileBloc>().add(LoadProfile(username: currentUser.username));
          context.read<WishlistBloc>().add(const LoadMyWishlists(isRefresh: true));
          context.read<BookingBloc>().add(LoadMyBookings(isRefresh: true));
        }
      },
      // Controller for two tabs: "My Wishlists" and "Booked Gifts"
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: Builder(
              builder: (ctx) {
                return FloatingActionButton(
                  onPressed: () {
                    // Show the bottom sheet to create a new wishlist
                    showModalBottomSheet(
                      context: ctx,
                      isScrollControlled: true,
                      // Pass the current WishlistBloc into the bottom sheet so it can dispatch events
                      builder: (_) => BlocProvider.value(
                        value: ctx.read<WishlistBloc>(),
                        child: const AddWishlistBottomSheet(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                );
              }
          ),
          // Render content based on the ProfileBloc state
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Handle profile loading error with a retry button
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
                          context.read<ProfileBloc>().add(LoadProfile(username: currentUser.username));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Successful load: build the profile header and tabs
              if (state is ProfileLoaded) {
                final theme = Theme.of(context);
                final profile = state.profile;

                return Column(
                  children: [
                    // Header component (avatar, statistics)
                    ProfileHeaderWidget(
                      profile: profile,
                      currentUserId: currentUserId,
                      // Navigation to the followers list
                      onFollowersTap: () async {
                        await context.router.push(ConnectionsRoute(
                            userId: currentUserId,
                            username: profile.user.username,
                            initialTab: 0
                        ));

                        // Refresh profile on return in case data has changed
                        if (context.mounted) {
                          context.read<ProfileBloc>().add(LoadProfile(username: currentUser.username));
                        }
                      },
                      // Navigation to the following list
                      onFollowingTap: () async {
                        await context.router.push(ConnectionsRoute(
                            userId: currentUserId,
                            username: profile.user.username,
                            initialTab: 1
                        ));

                        if (context.mounted) {
                          context.read<ProfileBloc>().add(LoadProfile(username: currentUser.username));
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: logic for transition to EditProfileScreen
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.secondarySurfaceColor,
                                    foregroundColor: theme.colorScheme.onSurface,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Edit profile',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Copy username and show a success snackbar
                                    Clipboard.setData(ClipboardData(text: '@${currentUser.username}'));
                                    AppSnackbars.showSuccess(context, 'Username copied to clipboard!');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.secondarySurfaceColor,
                                    foregroundColor: theme.colorScheme.onSurface,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Share profile',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Dialog to confirm logging out of the account
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Log out'),
                                      content: const Text('Are you sure you want to log out of your account?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                            // Dispatch session expired event to AuthBloc
                                            getIt<AuthBloc>().add(SessionExpired());
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: theme.colorScheme.error,
                                          ),
                                          child: const Text('Log out'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Log out',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tab bar switches
                    TabBar(
                      indicatorColor: theme.colorScheme.primary,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'My Wishlists'),
                        Tab(text: 'Booked Gifts'),
                      ],
                    ),
                    // Tab contents (passing currentUserId)
                    Expanded(
                      child: TabBarView(
                        children: [
                          _WishlistsTab(currentUserId: currentUserId),
                          _BookedGiftsTab(currentUserId: currentUserId),
                        ],
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

// ============================================================================
// StatelessWidget for the My Wishlist Tab
// ============================================================================
class _WishlistsTab extends StatelessWidget {
  final int currentUserId;

  const _WishlistsTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WishlistBloc, WishlistState>(
      listener: (context, state) {
        if (state is WishlistActionSuccess) {
          AppSnackbars.showSuccess(context, state.message);
          context.read<WishlistBloc>().add(const LoadMyWishlists(isRefresh: true));
        } else if (state is WishlistError) {
          AppSnackbars.showError(context, state.message);
        }
      },
      buildWhen: (previous, current) =>
      current is WishlistLoading ||
          current is WishlistsListLoaded ||
          current is WishlistError,
      builder: (context, state) {
        if (state is WishlistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WishlistsListLoaded) {
          return WishlistsListWidget(
            wishlists: state.wishlists,
            currentUserId: currentUserId,
            onRefresh: () async {
              context.read<WishlistBloc>().add(const LoadMyWishlists(isRefresh: true));
            },
            onWishlistTap: (wishlist) {
              // TODO: context.router.push(WishlistDetailsRoute(wishlistId: wishlist.id));
            },
            onToggleVisibility: (wishlist) {
              final updatedModel = WishlistUpdateModel(isVisible: !wishlist.isVisible);
              context.read<WishlistBloc>().add(
                  UpdateWishlist(wishlistId: wishlist.id, updateModel: updatedModel)
              );
            },
            onDelete: (wishlist) {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Delete Wishlist'),
                    content: Text('Are you sure you want to delete "${wishlist.title}"? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<WishlistBloc>().add(DeleteWishlist(wishlistId: wishlist.id));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }

        if (state is WishlistError) {
          return Center(
            child: Text(
              'Failed to load wishlists.\nPull down to retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ============================================================================
// Stateful Widget for the Booked Gifts Tab
// ============================================================================
// ============================================================================
// StatelessWidget for the Booked Gifts Tab
// ============================================================================
class _BookedGiftsTab extends StatelessWidget {
  final int currentUserId;

  const _BookedGiftsTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingActionSuccess) {
          AppSnackbars.showSuccess(context, state.message);
          context.read<BookingBloc>().add(LoadMyBookings(isRefresh: true));
        } else if (state is BookingError) {
          AppSnackbars.showError(context, state.message);
        }
      },
      buildWhen: (previous, current) =>
      current is BookingsListLoading ||
          current is BookingsListLoaded ||
          current is BookingError,
      builder: (context, state) {
        if (state is BookingsListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BookingsListLoaded) {
          return BookedGiftsListWidget(
            bookedGifts: state.bookings,
            currentUserId: currentUserId,
            onRefresh: () async {
              context.read<BookingBloc>().add(LoadMyBookings(isRefresh: true));
            },
            onDetailsTap: (sharedGift) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) {
                  return BlocProvider.value(
                    value: context.read<BookingBloc>(),
                    child: DetailedGiftBottomSheet(
                      sharedGift: sharedGift,
                      currentUserId: currentUserId,
                      onBookToggle: () {
                        showDialog(
                          context: ctx,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Cancel Booking'),
                              content: Text('Are you sure you want to cancel your booking for "${sharedGift.gift.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                  child: const Text('Keep'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                    Navigator.of(ctx).pop();
                                    context.read<BookingBloc>().add(UnbookGift(giftId: sharedGift.gift.id));
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                  child: const Text('Cancel Booking'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onOpenLink: () async {
                        final link = sharedGift.gift.linkUrl;
                        if (link != null && link.isNotEmpty) {
                          final url = Uri.parse(link);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            if (ctx.mounted) {
                              AppSnackbars.showError(ctx, 'Could not launch link');
                            }
                          }
                        }
                      },
                    ),
                  );
                },
              );
            },
            onUnbook: (sharedGift) {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Cancel Booking'),
                    content: Text('Are you sure you want to cancel your booking for "${sharedGift.gift.name}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Keep'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<BookingBloc>().add(UnbookGift(giftId: sharedGift.gift.id));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }

        if (state is BookingError) {
          return Center(
            child: Text(
              'Failed to load booked gifts.\nPull down to retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}