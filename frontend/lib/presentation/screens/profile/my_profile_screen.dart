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
      context.read<ProfileBloc>().add(LoadProfile(username: userState.user.username));
      context.read<WishlistBloc>().add(const LoadMyWishlists(isRefresh: true));
      context.read<BookingBloc>().add(LoadMyBookings(isRefresh: true));
    }
  }

  @override
  void didPopNext() {
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;

    // If user data is not loaded yet, show a loading indicator
    if (userState is! UserLoaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
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
          _refreshData();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Добавлена глобальная тема
        floatingActionButton: _tabController.index == 0
            ? Builder(
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
        )
            : null,
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
                        _refreshData();
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
                  // Tab contents (passing currentUserId)
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
// StatelessWidget for the My Wishlist Tab
// ============================================================================
class _WishlistsTab extends StatelessWidget {
  final int currentUserId;

  const _WishlistsTab({required this.currentUserId});

  // --------------------------------------------------------------------------
  // Extracted Action Methods
  // --------------------------------------------------------------------------

  /// Dispatches an event to refresh the wishlists data
  void _refreshWishlists(BuildContext context) {
    context.read<WishlistBloc>().add(const LoadMyWishlists(isRefresh: true));
  }

  /// Navigates to the detailed view of a specific wishlist
  Future<void> _navigateToDetails(BuildContext context, WishlistModel wishlist) async {
    // Wait for the details screen to pop
    await context.router.push(WishlistDetailsRoute(wishlistId: wishlist.id));

    // Refresh wishlists when coming back to the profile
    if (context.mounted) {
      _refreshWishlists(context);
    }
  }

  /// Toggles the visibility status (public/private) of a wishlist
  void _toggleVisibility(BuildContext context, WishlistModel wishlist) {
    final updatedModel = WishlistUpdateModel(isVisible: !wishlist.isVisible);
    context.read<WishlistBloc>().add(
      UpdateWishlist(wishlistId: wishlist.id, updateModel: updatedModel),
    );
  }

  /// Shows a confirmation dialog before deleting a wishlist
  void _showDeleteConfirmationDialog(BuildContext context, WishlistModel wishlist) {
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
                // Close the dialog first
                Navigator.of(dialogContext).pop();
                // Dispatch the delete event to the Bloc
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

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WishlistBloc, WishlistState>(
      listener: (context, state) {
        // Show success snackbar and refresh the list upon successful actions
        if (state is WishlistActionSuccess) {
          AppSnackbars.showSuccess(context, state.message);
          _refreshWishlists(context);
        }
        // Show error snackbar if an action fails
        else if (state is WishlistError) {
          AppSnackbars.showError(context, state.message);
        }
      },
      // Rebuild the UI strictly for states associated with displaying the list.
      buildWhen: (previous, current) {
        return current is WishlistLoading ||
            current is WishlistsListLoaded ||
            current is WishlistError;
      },
      builder: (context, state) {
        // 1. Loading State
        if (state is WishlistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Success State: Render the list of wishlists
        if (state is WishlistsListLoaded) {
          return WishlistsListWidget(
            wishlists: state.wishlists,
            currentUserId: currentUserId,
            // Using the extracted clean callbacks
            onRefresh: () async => _refreshWishlists(context),
            onWishlistTap: (wishlist) => _navigateToDetails(context, wishlist),
            onToggleVisibility: (wishlist) => _toggleVisibility(context, wishlist),
            onDelete: (wishlist) => _showDeleteConfirmationDialog(context, wishlist),
          );
        }

        // 3. Error State
        if (state is WishlistError) {
          return Center(
            child: Text(
              'Failed to load wishlists.\nPull down to retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        // 4. Fallback (Empty state)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// ============================================================================
// StatelessWidget for the Booked Gifts Tab
// ============================================================================
class _BookedGiftsTab extends StatelessWidget {
  final int currentUserId;

  const _BookedGiftsTab({required this.currentUserId});

  // --------------------------------------------------------------------------
  // Extracted Action Methods
  // --------------------------------------------------------------------------

  /// Dispatches an event to refresh the booked gifts data
  void _refreshBookings(BuildContext context) {
    context.read<BookingBloc>().add(LoadMyBookings(isRefresh: true));
  }

  /// Dispatches the event to cancel a booked gift
  void _unbookGift(BuildContext context, SharedGiftModel sharedGift) {
    context.read<BookingBloc>().add(UnbookGift(giftId: sharedGift.gift.id));
  }

  /// Attempts to open the external URL linked to the gift
  Future<void> _openExternalLink(BuildContext context, SharedGiftModel sharedGift) async {
    final link = sharedGift.gift.linkUrl;
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

  /// Shows a confirmation dialog before cancelling a booking
  void _showUnbookConfirmationDialog(BuildContext context, SharedGiftModel sharedGift, {VoidCallback? onConfirm}) {
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
                // Close the alert dialog
                Navigator.of(dialogContext).pop();

                // Execute optional additional confirmation logic (e.g., closing a bottom sheet)
                if (onConfirm != null) {
                  onConfirm();
                } else {
                  // If no additional logic, just unbook directly
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

  /// Shows a bottom sheet with detailed information about the booked gift
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
        // Provide the existing BookingBloc to the bottom sheet's context
        return BlocProvider.value(
          value: context.read<BookingBloc>(),
          child: DetailedGiftBottomSheet(
            sharedGift: sharedGift,
            currentUserId: currentUserId,
            // Action to unbook from inside the bottom sheet
            onBookToggle: () {
              _showUnbookConfirmationDialog(
                  ctx,
                  sharedGift,
                  onConfirm: () {
                    // Close the bottom sheet first, then dispatch the unbook event
                    Navigator.of(ctx).pop();
                    _unbookGift(context, sharedGift);
                  }
              );
            },
            // Action to open the gift link
            onOpenLink: () => _openExternalLink(ctx, sharedGift),
          ),
        );
      },
    );

    // Refresh bookings when the bottom sheet is closed
    if (context.mounted) {
      _refreshBookings(context);
    }
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        // Show success snackbar and refresh the list upon successful actions
        if (state is BookingActionSuccess) {
          AppSnackbars.showSuccess(context, state.message);
          _refreshBookings(context);
        }
        // Show error snackbar if an action fails
        else if (state is BookingError) {
          AppSnackbars.showError(context, state.message);
        }
      },
      // Filter states to prevent unnecessary rebuilds during action events.
      buildWhen: (previous, current) {
        return current is BookingsListLoading ||
            current is BookingsListLoaded ||
            current is BookingError;
      },
      builder: (context, state) {
        // 1. Loading State
        if (state is BookingsListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Success State: Render the list of booked gifts
        if (state is BookingsListLoaded) {
          if (state.bookings.isEmpty) {
            return const Center(
              child: Text(
                'No booked gifts found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return BookedGiftsListWidget(
            bookedGifts: state.bookings,
            currentUserId: currentUserId,
            onRefresh: () async => _refreshBookings(context),
            onDetailsTap: (sharedGift) => _showGiftDetailsBottomSheet(context, sharedGift),
            onUnbook: (sharedGift) => _showUnbookConfirmationDialog(context, sharedGift),
          );
        }

        // 3. Error State
        if (state is BookingError) {
          return Center(
            child: Text(
              'Failed to load booked gifts.\nPull down to retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        // 4. Fallback (Empty state)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}