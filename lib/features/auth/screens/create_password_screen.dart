import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/router/app_router.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/user_controller.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/app/shared/storage_keys.dart';
import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  // Live password rule state, updated as the user types.
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evaluatePasswordRules);
  }

  void _evaluatePasswordRules() {
    final value = _passwordController.text;
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (!_hasMinLength || !_hasUppercase || !_hasNumber) {
      return 'Password doesn\'t meet the requirements below';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submitPassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        Endpoints.createPassword,
        data: {
          'password': _passwordController.text,
          'confirmPassword': _confirmController.text,
        },
      );

      final body = response.data;

      if (body['success'] == true) {
        final message = body['data']?['message']?.toString() ?? 'Password set';
        ref.read(appToastProvider.notifier).showSuccess(message);

        await ref.read(currentUserProvider.notifier).refreshUser();
        if (!mounted) return;

        final role = await secureStorage.read(key: StorageKeys.userRole);
        if (!mounted) return;

        if (role == 'DRIVER') {
          context.go(RouteNames.driverhomescreen);
        } else {
          context.go(RouteNames.rider);
        }
      } else {
        ref
            .read(appToastProvider.notifier)
            .showError(body['message']?.toString() ?? 'Something went wrong');
      }
    } catch (e) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_evaluatePasswordRules);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _buildRequirementRow(BuildContext context, String label, bool met) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              met ? Icons.check_circle_rounded : Icons.circle_outlined,
              key: ValueKey(met),
              size: 16,
              color: met
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: met
                  ? colorScheme.onSurface.withValues(alpha: 0.8)
                  : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required BuildContext context,
    required String hint,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      suffixIcon: IconButton(
        onPressed: onToggleObscure,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // Back button
                          // const AppBackButton()
                          //     .animate()
                          //     .fadeIn(duration: 350.ms)
                          //     .slideX(
                          //       begin: -0.2,
                          //       end: 0,
                          //       curve: Curves.easeOutCubic,
                          //     ),
                          const SizedBox(height: 35),

                          // Title
                          Text(
                                'Create your\npassword',
                                style: GoogleFonts.syne(
                                  fontSize: 30,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 100.ms, duration: 400.ms)
                              .slideY(
                                begin: 0.15,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),

                          const SizedBox(height: 12),

                          Flexible(
                            child:
                                Text(
                                      'Choose a strong password to secure your account',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 180.ms, duration: 400.ms)
                                    .slideY(
                                      begin: 0.15,
                                      end: 0,
                                      curve: Curves.easeOutCubic,
                                    ),
                          ),

                          const SizedBox(height: 42),

                          // Form
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Password field
                                TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: colorScheme.onSurface,
                                      ),
                                      decoration: _fieldDecoration(
                                        context: context,
                                        hint: 'Password',
                                        obscure: _obscurePassword,
                                        onToggleObscure: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                      validator: _validatePassword,
                                    )
                                    .animate()
                                    .fadeIn(delay: 260.ms, duration: 400.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutCubic,
                                    ),

                                const SizedBox(height: 16),

                                // Requirements checklist
                                _buildRequirementRow(
                                  context,
                                  'At least 8 characters',
                                  _hasMinLength,
                                ).animate().fadeIn(
                                  delay: 320.ms,
                                  duration: 350.ms,
                                ),
                                _buildRequirementRow(
                                  context,
                                  'One uppercase letter',
                                  _hasUppercase,
                                ).animate().fadeIn(
                                  delay: 360.ms,
                                  duration: 350.ms,
                                ),
                                _buildRequirementRow(
                                  context,
                                  'One number',
                                  _hasNumber,
                                ).animate().fadeIn(
                                  delay: 400.ms,
                                  duration: 350.ms,
                                ),

                                const SizedBox(height: 16),

                                // Confirm password field
                                TextFormField(
                                      controller: _confirmController,
                                      obscureText: _obscureConfirm,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: colorScheme.onSurface,
                                      ),
                                      decoration: _fieldDecoration(
                                        context: context,
                                        hint: 'Confirm password',
                                        obscure: _obscureConfirm,
                                        onToggleObscure: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                      ),
                                      validator: _validateConfirm,
                                    )
                                    .animate()
                                    .fadeIn(delay: 440.ms, duration: 400.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutCubic,
                                    ),

                                const SizedBox(height: 30),

                                // SUBMIT BUTTON
                                SizedBox(
                                      width: double.infinity,
                                      child: PrimaryButton(
                                        label: _isSubmitting
                                            ? 'Creating account...'
                                            : 'Create Account',
                                        onPressed: _isSubmitting
                                            ? () {}
                                            : _submitPassword,
                                        backgroundColor: isDark
                                            ? colorScheme.primary
                                            : colorScheme.secondary,
                                        textColor: isDark
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSecondary,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 520.ms, duration: 400.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutCubic,
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // FOOTER
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 30),
                      child: SizedBox(
                        width: 260,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              height: 1.5,
                              letterSpacing: 0.5,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "BY CONTINUING, YOU AGREE TO EASY RIDE'S ",
                              ),
                              TextSpan(
                                text: 'TERMS OF SERVICE',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: 'PRIVACY POLICY',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
