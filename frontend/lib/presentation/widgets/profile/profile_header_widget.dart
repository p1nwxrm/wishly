import 'package:flutter/material.dart';
import '../../../data/models/user_models.dart';
import '../avatar/user_avatar.dart';

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
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Left-aligns the display name
          children: [
            // 1. Top Bar: Unique Username (Centered) - Показываем только в СВОЕМ профиле
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
                      _buildStatColumn(
                        context: context,
                        label: 'Followers',
                        count: profile.followersCount,
                        onTap: onFollowersTap,
                      ),
                      _buildStatColumn(
                        context: context,
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

  // Helper method to build the statistics column with InkWell animation
  Widget _buildStatColumn({
    required BuildContext context,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent, // Keeps the background transparent
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8), // Rounds the ripple effect edges
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Expands the tappable area slightly
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