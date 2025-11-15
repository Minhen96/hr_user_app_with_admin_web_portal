import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_animations.dart';

/// Modern Button with multiple variants
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ModernButtonVariant variant;
  final ModernButtonSize size;
  final Color? color;
  final Gradient? gradient;
  final bool isLoading;
  final bool fullWidth;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = ModernButtonVariant.primary,
    this.size = ModernButtonSize.medium,
    this.color,
    this.gradient,
    this.isLoading = false,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.buttonPress,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.emphasized),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.5,
          duration: AppAnimations.fast,
          child: Container(
            height: _getHeight(),
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: _getPaddingHorizontal(),
              vertical: _getPaddingVertical(),
            ),
            decoration: _getDecoration(),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final textWidget = Text(
      widget.text,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
        color: _getTextColor(),
        letterSpacing: 0.5,
      ),
    );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: _getTextColor(),
          ),
          const SizedBox(width: AppSpacing.sm),
          textWidget,
        ],
      );
    }

    return Center(child: textWidget);
  }

  BoxDecoration _getDecoration() {
    switch (widget.variant) {
      case ModernButtonVariant.primary:
        return BoxDecoration(
          gradient: widget.gradient ?? AppDecorations.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: _isPressed
              ? []
              : AppDecorations.shadowColored(
                  widget.color ?? AppColors.darkPrimary),
        );

      case ModernButtonVariant.secondary:
        return BoxDecoration(
          color: widget.color ?? AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.darkBorder),
        );

      case ModernButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: widget.color ?? AppColors.darkPrimary,
            width: 2,
          ),
        );

      case ModernButtonVariant.text:
        return const BoxDecoration();

      case ModernButtonVariant.glass:
        return BoxDecoration(
          color: AppColors.darkSurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        );
    }
  }

  Color _getTextColor() {
    switch (widget.variant) {
      case ModernButtonVariant.primary:
        return Colors.white;
      case ModernButtonVariant.secondary:
        return AppColors.darkTextPrimary;
      case ModernButtonVariant.outlined:
        return widget.color ?? AppColors.darkPrimary;
      case ModernButtonVariant.text:
        return widget.color ?? AppColors.darkPrimary;
      case ModernButtonVariant.glass:
        return Colors.white;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case ModernButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case ModernButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  double _getPaddingHorizontal() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return AppSpacing.lg;
      case ModernButtonSize.medium:
        return AppSpacing.xl;
      case ModernButtonSize.large:
        return AppSpacing.xxl;
    }
  }

  double _getPaddingVertical() {
    return AppSpacing.sm;
  }

  double _getFontSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 12;
      case ModernButtonSize.medium:
        return 14;
      case ModernButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 16;
      case ModernButtonSize.medium:
        return 20;
      case ModernButtonSize.large:
        return 24;
    }
  }
}

enum ModernButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  glass,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}

/// Icon Button with modern styling
class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const ModernIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? AppColors.darkSurfaceVariant,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          width: size ?? 48,
          height: size ?? 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: iconColor ?? AppColors.darkTextPrimary,
            size: (size ?? 48) * 0.5,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
