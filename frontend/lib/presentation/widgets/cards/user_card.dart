import 'package:flutter/material.dart';
import '../../../data/models/user_models.dart';
import '../avatar/user_avatar.dart';
import '../common/button_loading_indicator.dart';

// A card widget displaying a user's brief profile information.
// Used in search results, followers, and following lists.
class UserCard extends StatelessWidget {
  final UserModel user;

  // Indicates whether the current user is already following this person.
  final bool isFollowing;

  // Disables the button and shows a loading indicator during API calls.
  final bool isLoading;

  // Action triggered when the entire card is tapped (e.g., to view full profile).
  final VoidCallback onTap;

  // Action triggered when the follow/unfollow button is tapped.
  final VoidCallback onFollowToggle;

  const UserCard({
    super.key,
    required this.user,
    required this.isFollowing,
    this.isLoading = false,
    required this.onTap,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // Exactly matches the wishlist card margins
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // User Avatar Section
              UserAvatar(
                radius: 24,
                photoUrl: user.photoUrl,
              ),
              const SizedBox(width: 16),

              // User Info Section (Name and @username)
              Expanded(
                child: Column(
                  // Forces the column to shrink-wrap its children, preventing it from
                  // expanding infinitely vertically when centered on a screen.
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action Button Section (Follow / Unfollow)
              // Fixed width ensures the layout doesn't shift when text changes length.
              SizedBox(
                width: 110,
                height: 36,
                child: isFollowing
                    ? ElevatedButton(
                  onPressed: isLoading ? null : onFollowToggle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // Padding is handled by the fixed width
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  child: isLoading
                      ? ButtonLoadingIndicator(color: theme.colorScheme.onError)
                      : const Text('Unfollow'),
                )
                    : ElevatedButton(
                  onPressed: isLoading ? null : onFollowToggle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: isLoading
                      ? const ButtonLoadingIndicator()
                      : const Text('Follow'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}