import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const SearchBarWidget({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onClear,
    this.hintText = AppConstants.searchHintText,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get _hasText => _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: AppConstants.shortAnimationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    if (_hasText) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    _animationController.reverse();
    widget.onClear?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: _focusNode.hasFocus
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.2),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          prefixIcon: widget.prefixIcon ?? 
              Icon(
                Icons.search,
                color: _focusNode.hasFocus
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
          suffixIcon: widget.suffixIcon ?? _buildSuffixIcon(),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          widget.onChanged?.call(value);
          _focusNode.unfocus();
        },
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (!_hasText) return null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          Icons.clear,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: _clearSearch,
        tooltip: 'Clear search',
        splashRadius: 20,
      ),
    );
  }
}

/// Compact search bar for smaller spaces
class CompactSearchBarWidget extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool enabled;

  const CompactSearchBarWidget({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search...',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: SearchBarWidget(
        initialValue: initialValue,
        onChanged: onChanged,
        onClear: onClear,
        hintText: hintText,
        enabled: enabled,
      ),
    );
  }
}

/// Search bar with animated background
class AnimatedSearchBarWidget extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;
  final bool enabled;

  const AnimatedSearchBarWidget({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onClear,
    this.hintText = AppConstants.searchHintText,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  State<AnimatedSearchBarWidget> createState() => _AnimatedSearchBarWidgetState();
}

class _AnimatedSearchBarWidgetState extends State<AnimatedSearchBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _backgroundController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _backgroundController.forward();
    } else {
      _backgroundController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    _backgroundAnimation = ColorTween(
      begin: colorScheme.surfaceVariant.withOpacity(0.3),
      end: colorScheme.primaryContainer.withOpacity(0.2),
    ).animate(_backgroundController);

    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          decoration: BoxDecoration(
            color: _backgroundAnimation.value,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.2),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: SearchBarWidget(
            initialValue: widget.initialValue,
            onChanged: widget.onChanged,
            onClear: widget.onClear,
            hintText: widget.hintText,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
          ),
        );
      },
    );
  }
}