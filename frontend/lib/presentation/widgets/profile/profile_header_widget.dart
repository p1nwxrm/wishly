import 'package:flutter/material.dart';
import '../../../data/models/user_models.dart';
import '../photo/user_avatar.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfileModel profile;
  final int currentUserId;

  // Callbacks for navigating to the connections screen
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    required this.currentUserId,
    required this.onFollowersTap,
    required this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = profile.user;
    final isMyProfile = user.id == currentUserId;

    // SafeArea ensures the content doesn't overlap with the device's status bar
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Left-aligns the display name
          children: [
            // 1. Top Bar: Unique Username (Centered) - Shown only in the current user's profile
            if (isMyProfile) ...[
              Center(
                child: Text(
                  user.username,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. Avatar and Stats Row
            Row(
              children: [
                // Larger Avatar
                UserAvatar(
                  radius: 46,
                  photoUrl: user.photoUrl,
                ),
                const SizedBox(width: 24),

                // Stats
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ProfileStatColumn(
                        label: 'Followers',
                        count: profile.followersCount,
                        onTap: onFollowersTap,
                      ),
                      ProfileStatColumn(
                        label: 'Following',
                        count: profile.followingCount,
                        onTap: onFollowingTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3. Bio Section: Display Name (Left-aligned)
            Text(
              user.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Extracted as a StatelessWidget for better performance and widget tree optimization.
class ProfileStatColumn extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const ProfileStatColumn({
    super.key,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent, // Keeps the background transparent
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8), // Rounds the ripple effect edges
        child: Padding(
          // Expands the tappable area slightly for better accessibility and UX
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}