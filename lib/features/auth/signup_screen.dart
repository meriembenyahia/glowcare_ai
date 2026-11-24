import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
import '../../core/theme/widgets/app_text_field.dart';
import '../../core/theme/widgets/primary_button.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) return 'Enter a valid email address';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _confirmValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final error = await ref.read(authProvider.notifier).signUpWithEmail(
          _emailController.text,
          _passwordController.text,
          name: _nameController.text,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const AppLogo(size: 88),
                      const SizedBox(height: 8),
                      Text(
                        'Create your account',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Save your routine, wishlist, and orders',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nameController,
                  hint: 'Full name',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) => _required(v, 'Full name'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emailController,
                  hint: 'Email address',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _emailValidator,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _confirmController,
                  hint: 'Confirm password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: _confirmValidator,
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Already have an account? Log In',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
