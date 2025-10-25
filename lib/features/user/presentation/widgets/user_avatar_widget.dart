import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';

class UserAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final String? heroTag;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatarWidget({
    super.key,
    required this.imageUrl,
    this.size = AppConstants.avatarSize,
    this.heroTag,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor = borderColor ?? theme.primaryColor;

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(context),
          errorWidget: (context, url, error) => _buildErrorWidget(context),
          fadeInDuration: AppConstants.shortAnimationDuration,
          fadeOutDuration: AppConstants.shortAnimationDuration,
        ),
      ),
    );

    // Wrap with Hero widget if heroTag is provided
    if (heroTag != null) {
      avatarWidget = Hero(
        tag: heroTag!,
        child: avatarWidget,
      );
    }

    // Wrap with GestureDetector if onTap is provided
    if (onTap != null) {
      avatarWidget = GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceVariant,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.errorContainer,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: theme.colorScheme.onErrorContainer,
      ),
    );
  }
}

/// Large avatar variant for detail screens
class LargeUserAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final VoidCallback? onTap;

  const LargeUserAvatarWidget({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatarWidget(
      imageUrl: imageUrl,
      size: AppConstants.largeAvatarSize,
      heroTag: heroTag,
      onTap: onTap,
      showBorder: true,
      borderWidth: 3.0,
    );
  }
}

/// Small avatar variant for compact displays
class SmallUserAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final VoidCallback? onTap;

  const SmallUserAvatarWidget({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatarWidget(
      imageUrl: imageUrl,
      size: 32.0,
      heroTag: heroTag,
      onTap: onTap,
    );
  }
}