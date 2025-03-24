import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../theme/app_dimensions.dart';

class AppTextField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool autovalidate;
  final bool readOnly;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final EdgeInsets? contentPadding;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.labelText,
    this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.autovalidate = false,
    this.readOnly = false,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.contentPadding,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.labelText, style: AppStyles.labelText),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: (value) {
            if (widget.validator != null) {
              final error = widget.validator!(value);
              setState(() {
                _hasError = error != null;
              });
              return error;
            }
            return null;
          },
          inputFormatters: widget.inputFormatters,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          focusNode: widget.focusNode,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          enabled: widget.enabled,
          autovalidateMode:
              widget.autovalidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppStyles.hintText,
            filled: true,
            fillColor: widget.enabled ? Colors.white : AppColors.lightGrey,
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon:
                widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
                    : null,
            suffixIcon: widget.suffixIcon ?? _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
          ),
          style: AppStyles.bodyText,
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }
    return null;
  }
}
