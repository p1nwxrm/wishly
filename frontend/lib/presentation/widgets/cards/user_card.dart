import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../avatar/user_avatar.dart';
import '../common/button_loading_indicator.dart';

class UserCard extends StatelessWidget {
  // Model containing user info and connection status
  final UserConnectionModel connection;

  // ID of the currently logged-in user to check if this card belongs to them
  final int currentUserId;

  // Disables the button and shows a loading indicator during API calls.
  final bool isLoading;

  // Action triggered when the entire card is tapped (e.g., to view full profile). Nullable if it's the current user.
  final VoidCallback? onTap;

  // Action triggered when the follow/unfollow button is tapped. Nullable if it's the current user.
  final VoidCallback? onFollowToggle;

  const UserCard({
    super.key,
    required this.connection,
    required this.currentUserId,
    this.isLoading = false,
    this.onTap,
    this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = connection.user;
    final isMe = user.id == currentUserId;

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

              // Action Button Section (Follow / Unfollow / You indicator)
              // Fixed width ensures the layout doesn't shift when text changes length.
              SizedBox(
                width: 110,
                height: 36,
                child: isMe
                    ? Center(
                  child: Text(
                    'You',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : (connection.isFollowedByMe
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
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}