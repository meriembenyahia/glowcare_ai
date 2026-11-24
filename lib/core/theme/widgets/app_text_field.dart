import 'package:flutter/material.dart';
import 'package:glowcare_ai/core/theme/widgets/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.textInputAction,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPassword && _obscure,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(color: colors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: colors.mutedText, fontSize: 14),
        fillColor: colors.inputFill,
        filled: true,
        prefixIcon: Icon(widget.icon, color: colors.mutedText, size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.mutedText,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
