import 'package:flutter/material.dart';

import '../../../data/models/user_models.dart';
import '../cards/user_card.dart';

/// A reusable list view for displaying a list of [SocialUserModel]s.
/// It handles its own scrolling physics, separators, and optional pull-to-refresh.
class UserListView extends StatelessWidget {
  final List<SocialUserModel> users;
  final int currentUserId;
  final Set<String> loadingUsernames;

  /// Callback triggered when a user taps on the whole card.
  final ValueChanged<SocialUserModel> onUserTap;

  /// Callback triggered when the follow/unfollow button is tapped.
  final ValueChanged<SocialUserModel> onFollowToggle;

  /// Optional callback for pull-to-refresh functionality.
  /// If provided, the list will be wrapped in a [RefreshIndicator].
  final Future<void> Function()? onRefresh;

  /// Optional scroll controller for custom scroll behaviors (like scrolling to top).
  final ScrollController? scrollController;

  /// Custom padding for the list.
  final EdgeInsetsGeometry padding;

  const UserListView({
    super.key,
    required this.users,
    required this.currentUserId,
    required this.loadingUsernames,
    required this.onUserTap,
    required this.onFollowToggle,
    this.onRefresh,
    this.scrollController,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.separated(
      controller: scrollController,
      // Always scrollable to ensure RefreshIndicator works even if the list is short
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        final isMe = user.id == currentUserId;
        final isItemLoading = loadingUsernames.contains(user.username);

        return UserCard(
          user: user,
          currentUserId: currentUserId,
          isLoading: isItemLoading,
          // The logic for isMe is now handled entirely inside the list view.
          // If the item is the current user, we disable the tap actions.
          onTap: isMe ? null : () => onUserTap(user),
          onFollowToggle: isMe ? null : () => onFollowToggle(user),
        );
      },
    );

    // Conditionally wrap with RefreshIndicator only if callback is provided
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}