import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/wishlist_models.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/wishlist/wishlist_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../../core/di/injection.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/profile/profile_header_widget.dart';
import '../../widgets/profile/wishlists_list_widget.dart';
import '../../widgets/profile/booked_gifts_list_widget.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/bottom_sheets/add_wishlist_bottom_sheet.dart';

@RoutePage()
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;

    if (userState is! UserLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = userState.user;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) => getIt<ProfileBloc>()
            ..add(LoadProfile(username: currentUser.username)),
        ),
        BlocProvider<WishlistBloc>(
          create: (context) => getIt<WishlistBloc>()
            ..add(const LoadMyWishlists()),
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: Builder(
              builder: (ctx) {
                return FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: ctx,
                      isScrollControlled: true,
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
          body: BlocBuilder<ProfileBloc, ProfileState>(
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
                          context.read<ProfileBloc>().add(LoadProfile(username: currentUser.username));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProfileLoaded) {
                final theme = Theme.of(context);

                return Column(
                  children: [
                    ProfileHeaderWidget(
                      profile: state.profile,
                      currentUserId: currentUser.id,
                      onFollowersTap: () {},
                      onFollowingTap: () {},
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
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
                                // Show Native Confirmation Dialog before logging out
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
                        children: [
                          _buildWishlistsTab(context, currentUser.id),
                          _BookedGiftsTab(currentUserId: currentUser.id),
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

// ============================================================================
// Widget for the My Wishlist Tab
// ============================================================================
  Widget _buildWishlistsTab(BuildContext context, int currentUserId) {
    return BlocConsumer<WishlistBloc, WishlistState>(
      listener: (context, state) {
        if (state is WishlistActionSuccess) {
          AppSnackbars.showSuccess(context, state.message);
        } else if (state is WishlistError) {
          AppSnackbars.showError(context, state.message);
        }
      },
      buildWhen: (previous, current) =>
      current is WishlistLoading ||
          current is WishlistsLoaded ||
          current is WishlistError,
      builder: (context, state) {
        if (state is WishlistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WishlistsLoaded) {
          return WishlistsListWidget(
            wishlists: state.wishlists,
            currentUserId: currentUserId,
            onRefresh: () async {
              context.read<WishlistBloc>().add(const LoadMyWishlists(isRefresh: true));
            },
            onWishlistTap: (wishlist) {
              // context.router.push(WishlistDetailsRoute(wishlistId: wishlist.id));
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
class _BookedGiftsTab extends StatefulWidget {
  final int currentUserId;

  const _BookedGiftsTab({required this.currentUserId});

  @override
  State<_BookedGiftsTab> createState() => _BookedGiftsTabState();
}

class _BookedGiftsTabState extends State<_BookedGiftsTab> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(LoadMyBookings());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingActionSuccess) {
          AppSnackbars.showSuccess(context, state.message);
          context.read<BookingBloc>().add(LoadMyBookings());
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
            currentUserId: widget.currentUserId,
            onRefresh: () async {
              context.read<BookingBloc>().add(LoadMyBookings());
            },
            onDetailsTap: (sharedGift) {
              // TODO: Navigate to gift details screen
              // context.router.push(GiftDetailsRoute(giftId: sharedGift.gift.id));
            },
            onUnbook: (sharedGift) {
              // Show native confirmation dialog before cancelling the booking
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
                          // Dispatch the unbook event to the Bloc after confirmation
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