import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
import '../../core/theme/widgets/app_text_field.dart';
import '../../core/theme/widgets/primary_button.dart';
import 'auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value, AppStrings s) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return s.t('Email is required');
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) return s.t('Enter a valid email address');
    return null;
  }

  String? _passwordValidator(String? value, AppStrings s) {
    if (value == null || value.isEmpty) return s.t('Password is required');
    if (value.length < 6) return s.t('Password must be at least 6 characters');
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final error = await ref.read(authProvider.notifier).signInWithEmail(
          _emailController.text,
          _passwordController.text,
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

  Future<void> _forgotPassword() async {
    final s = AppStrings.of(context);
    final email = _emailController.text.trim();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.t('Enter your email first, then tap Forgot password.')),
        ),
      );
      return;
    }
    final error =
        await ref.read(authProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? s.t('If this email is registered, a reset link has been sent.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);

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
                    const AppLogo(size: 100),
                    const SizedBox(height: 8),
                    Text(
                      'GlowCare AI',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.t('Healthy Skin  ✦  Natural Beauty'),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: colors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                s.t('Welcome back'),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.t('Your glow journey continues'),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: colors.mutedText,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _emailController,
                hint: s.t('Email address'),
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => _emailValidator(v, s),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _passwordController,
                hint: s.t('Password'),
                icon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (v) => _passwordValidator(v, s),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _isLoading ? null : _forgotPassword,
                  child: Text(
                    s.t('Forgot password?'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colors.mutedText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: s.t('Log In'),
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: Text(
                    s.t('New here? Create an account'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).loginAsGuest();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    s.t('Continue as Guest'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
