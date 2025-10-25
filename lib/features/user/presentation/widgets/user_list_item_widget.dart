import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entites/user_entity.dart';
import 'user_avatar_widget.dart';

class UserListItemWidget extends StatelessWidget {
  final UserEntity user;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool isSelected;

  const UserListItemWidget({
    super.key,
    required this.user,
    this.onTap,
    this.showDivider = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Material(
          color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  // User Avatar
                  UserAvatarWidget(
                    imageUrl: user.avatar,
                    heroTag: 'user_avatar_${user.id}',
                    onTap: onTap,
                  ),
                  
                  const SizedBox(width: AppConstants.defaultPadding),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text(
                          user.fullName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Email
                        Text(
                          user.email,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 2),
                        
                        // User ID
                        Text(
                          'ID: ${user.id}',
                          style: textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer.withOpacity(0.6)
                                : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Trailing Icon
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer.withOpacity(0.6)
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Divider
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: AppConstants.avatarSize + AppConstants.defaultPadding * 2,
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
      ],
    );
  }
}

/// Compact variant for dense lists
class CompactUserListItemWidget extends StatelessWidget {
  final UserEntity user;
  final VoidCallback? onTap;
  final bool showDivider;

  const CompactUserListItemWidget({
    super.key,
    required this.user,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              child: Row(
                children: [
                  // Small Avatar
                  SmallUserAvatarWidget(
                    imageUrl: user.avatar,
                    heroTag: 'compact_user_avatar_${user.id}',
                    onTap: onTap,
                  ),
                  
                  const SizedBox(width: AppConstants.defaultPadding),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text(
                          user.fullName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Email (smaller)
                        Text(
                          user.email,
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // ID Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${user.id}',
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Divider
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 32 + AppConstants.defaultPadding * 2,
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
      ],
    );
  }
}

/// Grid variant for grid layouts
class UserGridItemWidget extends StatelessWidget {
  final UserEntity user;
  final VoidCallback? onTap;

  const UserGridItemWidget({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              UserAvatarWidget(
                imageUrl: user.avatar,
                size: 60,
                heroTag: 'grid_user_avatar_${user.id}',
                onTap: onTap,
              ),
              
              const SizedBox(height: AppConstants.smallPadding),
              
              // Name
              Text(
                user.fullName,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Email
              Text(
                user.email,
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}