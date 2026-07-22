import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

enum AppButtonVariant { primary, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : variant = AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final child = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
      isPrimary: variant == AppButtonVariant.primary,
    );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };

    return SizedBox(
      width: width,
      height: AppDimensions.buttonHeight,
      child: button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.isPrimary,
    this.icon,
  });

  final String label;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: AppDimensions.iconMedium,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(
            isPrimary
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (icon == null) {
      return Text(label, overflow: TextOverflow.ellipsis);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppDimensions.iconSmall),
        const SizedBox(width: AppDimensions.spacing8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
