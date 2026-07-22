import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.inputMinHeight,
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          errorText: errorText,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
