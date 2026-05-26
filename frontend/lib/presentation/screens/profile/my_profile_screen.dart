import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/gift_models.dart';
import '../../../data/models/wishlist_models.dart';
import '../../blocs/blocs.dart';
import '../../widgets/common/app_snackbars.dart';
import '../../widgets/profile/profile.dart';
import '../../widgets/lists/lists.dart';
import '../../widgets/bottom_sheets/bottom_sheets.dart';

@RoutePage()
class MyProfileScreen extends StatefulWidget implements AutoRouteWrapper {
  const MyProfileScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    final username = userState is UserLoaded ? userState.user.username : '';

    // Trigger events on global Blocs that are already provided in main.dart
    context.read<BookingBloc>().add(LoadMyBookings());

    if (username.isNotEmpty) {
      // MyProfileBloc is a global singleton provided in main.dart.
      context.read<MyProfileBloc>().add(LoadMyProfile(username: username));
    }

    // WishlistBloc is registered as a Factory in injection.dart.
    return BlocProvider<WishlistBloc>(
      create: (context) {
        final bloc = getIt<WishlistBloc>();
        if (username.isNotEmpty) {
          bloc.add(LoadUserWishlists(username: username));
        }
        return bloc;
      },
      child: this,
    );
  }

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with AutoRouteAwareStateMixin<MyProfileScreen>, SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      final username = userState.user.username;
      context.read<UserBloc>().add(RefreshCurrentUser());
      context.read<MyProfileBloc>().add(RefreshMyProfile(username: username));
      context.read<WishlistBloc>().add(RefreshUserWishlists(username: username));
      context.read<BookingBloc>().add(RefreshMyBookings());
    }
  }

  @override
  void didPopNext() {
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;

    // Show a loading indicator if user data is not loaded yet
    if (userState is! UserLoaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = userState.user;
    final currentUserId = currentUser.id;

    // BlocListener for global navigation events (e.g., double tap on a tab)
    return BlocListener<TabRefreshCubit, int?>(
      bloc: getIt<TabRefreshCubit>(),
      listener: (context, state) {
        // If the tab index is 2 (profile tab), forcefully refresh all data
        if (state == 2) {
          _refreshData();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: _tabController.index == 0
            ? Builder(
          builder: (ctx) {
            return FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: ctx,
                  isScrollControlled: true,
                  // Pass the current WishlistBloc into the bottom sheet so it can dispatch events
                  builder: (_) => BlocProvider.value(
                    value: ctx.read<WishlistBloc>(),
                    child: const WishlistActionBottomSheet(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          },
        )
            : null,
        body: BlocBuilder<MyProfileBloc, MyProfileState>(
          builder: (context, state) {
            if (state is MyProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MyProfileError) {
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
                        context.read<MyProfileBloc>().add(LoadMyProfile(username: currentUser.username));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is MyProfileLoaded) {
              final theme = Theme.of(context);
              final profile = state.profile;

              return Column(
                children: [
                  ProfileHeaderWidget(
                    profile: profile,
                    currentUserId: currentUserId,
                    onFollowersTap: () async {
                      await context.router.push(ConnectionsRoute(
                        username: profile.username,
                        initialTab: 0,
                      ));

                      if (context.mounted) {
                        _refreshData();
                      }
                    },
                    onFollowingTap: () async {
                      await context.router.push(ConnectionsRoute(
                        username: profile.username,
                        initialTab: 1,
                      ));

                      if (context.mounted) {
                        _refreshData();
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
                                onPressed: () async {
                                  final latestUserState = context.read<UserBloc>().state;

                                  if (latestUserState is! UserLoaded) {
                                    AppSnackbars.showError(context, 'User data is not loaded yet.');
                                    return;
                                  }

                                  final result = await context.router.push<bool>(
                                    EditProfileRoute(user: latestUserState.user),
                                  );

                                  if (!context.mounted) return;

                                  if (result == true) {
                                    AppSnackbars.showSuccess(context, 'Profile successfully updated!');
                                    _refreshData();
                                  }
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
                  TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'My Wishlists'),
                      Tab(text: 'Booked Gifts'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
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
    );
  }
}

// ============================================================================
// _WishlistsTab
// ============================================================================
class _WishlistsTab extends StatelessWidget {
  final int currentUserId;

  const _WishlistsTab({required this.currentUserId});

  void _refreshWishlists(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<WishlistBloc>().add(RefreshUserWishlists(username: userState.user.username));
    }
  }

  Future<void> _navigateToDetails(BuildContext context, WishlistBaseModel wishlist) async {
    await context.router.push(WishlistDetailsRoute(wishlistId: wishlist.id));

    if (context.mounted) {
      _refreshWishlists(context);
    }
  }

  // Opens the universal sheet in Edit mode
  void _showEditBottomSheet(BuildContext context, WishlistBaseModel wishlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<WishlistBloc>(),
          child: WishlistActionBottomSheet(wishlist: wishlist),
        );
      },
    );
  }

  void _toggleVisibility(BuildContext context, WishlistBaseModel wishlist) {
    final updatedModel = WishlistUpdateModel(isVisible: !wishlist.isVisible);
    context.read<WishlistBloc>().add(
      UpdateWishlist(wishlistId: wishlist.id, updateModel: updatedModel),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WishlistBaseModel wishlist) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Wishlist'),
          content: Text(
            'Are you sure you want to delete "${wishlist.title}"? This action cannot be undone.',
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WishlistBloc, WishlistState>(
      listener: (context, state) {
        if (state is WishlistActionSuccess) {
          AppSnackbars.showSuccess(context, state.message);
          _refreshWishlists(context);
        } else if (state is WishlistError) {
          AppSnackbars.showError(context, state.message);
        }
      },
      buildWhen: (previous, current) {
        return current is WishlistLoading ||
            current is UserWishlistsLoaded ||
            current is WishlistError;
      },
      builder: (context, state) {
        if (state is WishlistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserWishlistsLoaded) {
          return WishlistsListWidget(
            userWishlistsData: state.data,
            currentUserId: currentUserId,
            onRefresh: () async => _refreshWishlists(context),
            onWishlistTap: (wishlist) => _navigateToDetails(context, wishlist),
            onToggleVisibility: (wishlist) => _toggleVisibility(context, wishlist),
            onDelete: (wishlist) => _showDeleteConfirmationDialog(context, wishlist),
            onEdit: (wishlist) => _showEditBottomSheet(context, wishlist),
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

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// ============================================================================
// _BookedGiftsTab
// ============================================================================
class _BookedGiftsTab extends StatefulWidget {
  final int currentUserId;

  const _BookedGiftsTab({required this.currentUserId});

  @override
  State<_BookedGiftsTab> createState() => _BookedGiftsTabState();
}

class _BookedGiftsTabState extends State<_BookedGiftsTab> {
  /// A set of gift IDs that are currently in a loading state (e.g., being unbooked).
  final Set<int> _loadingGiftIds = {};

  void _refreshBookings(BuildContext context) {
    context.read<BookingBloc>().add(RefreshMyBookings());
  }

  void _unbookGift(BuildContext context, SharedGiftModel sharedGift) {
    // Prevent duplicate requests if this specific gift is already processing
    if (_loadingGiftIds.contains(sharedGift.id)) return;
    context.read<BookingBloc>().add(UnbookGift(giftId: sharedGift.id));
  }

  Future<void> _openExternalLink(BuildContext context, SharedGiftModel sharedGift) async {
    final link = sharedGift.linkUrl;
    if (link != null && link.isNotEmpty) {
      final url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppSnackbars.showError(context, 'Could not launch link');
        }
      }
    }
  }

  void _showUnbookConfirmationDialog(
      BuildContext context,
      SharedGiftModel sharedGift,
      {VoidCallback? onConfirm}
      ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel your booking for "${sharedGift.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Keep'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                if (onConfirm != null) {
                  onConfirm();
                } else {
                  _unbookGift(context, sharedGift);
                }
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
  }

  Future<void> _showGiftDetailsBottomSheet(BuildContext context, SharedGiftModel sharedGift) async {
    await showModalBottomSheet(
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
            currentUserId: widget.currentUserId,
            onBookToggle: () {
              _showUnbookConfirmationDialog(
                ctx,
                sharedGift,
                onConfirm: () {
                  Navigator.of(ctx).pop();
                  _unbookGift(context, sharedGift);
                },
              );
            },
            onOpenLink: () => _openExternalLink(ctx, sharedGift),
          ),
        );
      },
    );

    if (context.mounted) {
      _refreshBookings(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        // Handle individual gift loading state
        if (state is BookingGiftLoading) {
          setState(() => _loadingGiftIds.add(state.giftId));
        }
        // Handle successful booking action
        else if (state is BookingActionSuccess) {
          setState(() => _loadingGiftIds.clear());
          AppSnackbars.showSuccess(context, state.message);
          _refreshBookings(context);
        }
        // Handle error and ensure loading state is cleared
        else if (state is BookingError) {
          setState(() => _loadingGiftIds.clear());
          AppSnackbars.showError(context, state.message);
        }
      },
      buildWhen: (previous, current) {
        return current is BookingsListLoading ||
            current is BookingsListLoaded ||
            current is BookingError;
      },
      builder: (context, state) {
        if (state is BookingsListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BookingsListLoaded) {
          return BookedGiftsListWidget(
            bookedGifts: state.bookings,
            currentUserId: widget.currentUserId,
            loadingGiftIds: _loadingGiftIds,
            onRefresh: () async => _refreshBookings(context),
            onDetailsTap: (sharedGift) => _showGiftDetailsBottomSheet(context, sharedGift),
            onBookToggle: (sharedGift) => _showUnbookConfirmationDialog(context, sharedGift),
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

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}