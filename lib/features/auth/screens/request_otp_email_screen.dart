import 'dart:async';
import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class RequestOtpEmailScreen extends ConsumerStatefulWidget {
  const RequestOtpEmailScreen({super.key});

  @override
  ConsumerState<RequestOtpEmailScreen> createState() =>
      _RequestOtpEmailScreenState();
}

class _RequestOtpEmailScreenState extends ConsumerState<RequestOtpEmailScreen>
    with SingleTickerProviderStateMixin {
  // ------------------------------------------------------------
  // STYLES
  // ------------------------------------------------------------

  final interBaseStyle = GoogleFonts.inter();
  final syneBaseStyle = GoogleFonts.syne(
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // ------------------------------------------------------------
  // FORM
  // ------------------------------------------------------------

  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _resetPasswordFormKey = GlobalKey<FormState>();

  Timer? _otpTimer;

  int _remainingSeconds = 300;
  late final TextEditingController _emailController;
  late final TextEditingController _otpController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late AnimationController _otpAnimationController;
  late Animation<double> _otpFadeAnimation;
  late Animation<Offset> _otpSlideAnimation;
  // ------------------------------------------------------------
  // STEPS
  // ------------------------------------------------------------

  int step = 1;

  final int maxStep = 3;
  // ------------------------------------------------------------
  // LIFECYCLE
  // ------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _otpController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _otpAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _otpFadeAnimation = CurvedAnimation(
      parent: _otpAnimationController,
      curve: Curves.easeOut,
    );

    _otpSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _otpAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _otpAnimationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _otpTimer?.cancel();
    _otpAnimationController.dispose();

    super.dispose();
  }
  // ------------------------------------------------------------
  // NAVIGATION
  // ------------------------------------------------------------

  void goBack() {
    if (step > 1) {
      setState(() {
        step--;
      });

      return;
    }

    if (context.canPop()) {
      context.pop();
    }
  }

  // ------------------------------------------------------------
  // EMAIL SUBMISSION
  // ------------------------------------------------------------

  Future<void> _handleEmailSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final apiClient = ref.read(apiClientProvider);
    final email = _emailController.text.trim();

    try {
      final response = await apiClient.post(
        Endpoints.requestResetPassword,
        data: {'email': email},
      );

      developer.log('EMAIL RESPONSE: $response');

      final data = response.data;

      if (data['success'] != true) {
        return;
      }

      if (!mounted) return;
      ref.read(appToastProvider.notifier).showSuccess("OTP SENT");

      setState(() {
        step = 2;
      });

      startOtpTimer();
    } catch (e) {
      if (!mounted) return;
    }
  }
  // ------------------------------------------------------------
  // STEP NAVIGATION
  // ------------------------------------------------------------

  void _tapCircle(int targetStep) {
    // Don't allow moving forward by tapping the indicator.
    if (targetStep >= step) {
      return;
    }

    setState(() {
      step = targetStep;
    });
  }

  Future<void> _handleResendOtp() async {
    if (_remainingSeconds > 0) {
      return;
    }

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      return;
    }

    final apiClient = ref.read(apiClientProvider);

    try {
      final response = await apiClient.post(
        Endpoints.resendOtp,
        data: {'email': email},
      );

      developer.log('RESEND OTP RESPONSE: $response');

      final data = response.data;

      if (data['success'] != true) {
        return;
      }

      if (!mounted) return;

      _otpController.clear();

      startOtpTimer();

      ref
          .read(appToastProvider.notifier)
          .showSuccess('OTP resent successfully');
    } catch (e, stackTrace) {}
  }

  Future<void> _handleVerifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    final apiClient = ref.read(apiClientProvider);

    try {
      developer.log("verifying with $email and $otp");
      final response = await apiClient.post(
        Endpoints.verifyPasswordResetOtp,
        data: {'email': email, 'code': otp},
      );

      developer.log('VERIFY OTP RESPONSE: $response');

      final data = response.data;

      developer.log('VERIFY OTP DATA: $data');

      if (data['success'] != true) {
        return;
      }

      if (!mounted) return;

      // OTP has been successfully verified
      _otpTimer?.cancel();

      setState(() {
        step = 3;
      });
    } catch (e, stackTrace) {
      developer.log('VERIFY OTP ERROR: $e', error: e, stackTrace: stackTrace);

      if (!mounted) return;
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_resetPasswordFormKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final apiClient = ref.read(apiClientProvider);

    try {
      final response = await apiClient.post(
        Endpoints.resetPassword,
        data: {
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      developer.log('RESET PASSWORD RESPONSE: $response');

      final data = response.data;

      developer.log('RESET PASSWORD DATA: $data');

      if (data['success'] != true) {
        return;
      }

      if (!mounted) return;
      // show toast
      ref
          .read(appToastProvider.notifier)
          .showSuccess("PASSOWRD RESET SUCCESSFUL");
      // Password successfully changed
      context.go(RouteNames.login);
    } catch (e) {
      developer.log('RESET PASSWORD ERROR: $e', error: e);

      if (!mounted) return;

      // Show your error toast/snackbar here
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  void startOtpTimer() {
    _otpTimer?.cancel();

    setState(() {
      _remainingSeconds = 300;
    });

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // ------------------------------------------------
              // BACK BUTTON
              // ------------------------------------------------
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child:
                      IconButton(
                        onPressed: goBack,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: colorScheme.onSurface,
                          size: 22,
                        ),
                      ).animate().slideY(
                        begin: 0.15,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ),

              const SizedBox(height: 40),

              // ------------------------------------------------
              // STEP INDICATOR
              // ------------------------------------------------
              _buildStepIndicator(context, colorScheme),

              const SizedBox(height: 40),

              // ------------------------------------------------
              // FORM STEPS
              // ------------------------------------------------
              Expanded(
                child: SingleChildScrollView(
                  child: _formSteps(
                    colorScheme: colorScheme,
                    inputBorder: inputBorder,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FORM STEPS
  // ------------------------------------------------------------

  Widget _formSteps({
    required ColorScheme colorScheme,
    required OutlineInputBorder inputBorder,
    required bool isDark,
  }) {
    switch (step) {
      case 1:
        return EmailStep(
          colorScheme: colorScheme,
          inputBorder: inputBorder,
          isDark: isDark,
        );

      case 2:
        return OtpStep(colorScheme: colorScheme, isDark: isDark);

      case 3:
        return ResetPasswordStep(
          colorScheme: colorScheme,
          inputBorder: inputBorder,
          isDark: isDark,
        );

      default:
        return const SizedBox.shrink();
    }
  }
  // ------------------------------------------------------------
  // EMAIL STEP
  // ------------------------------------------------------------

  Widget EmailStep({
    required ColorScheme colorScheme,
    required OutlineInputBorder inputBorder,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // TITLE
        // ------------------------------------------------------
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: syneBaseStyle,
              children: [
                TextSpan(
                  text: 'Enter Your Email',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                TextSpan(
                  text: 'Address',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        ),

        const SizedBox(height: 48),

        // ------------------------------------------------------
        // LABEL
        // ------------------------------------------------------
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'EMAIL ADDRESS',
            style: interBaseStyle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ------------------------------------------------------
        // EMAIL FORM
        // ------------------------------------------------------
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            style: interBaseStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'yourEmail@gmail.com',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 1.5),
              ),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Please enter your email address';
              }

              final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');

              if (!emailRegex.hasMatch(email)) {
                return 'Please enter a valid email address';
              }

              return null;
            },
            onFieldSubmitted: (_) {
              _handleEmailSubmit();
            },
          ),
        ),

        const SizedBox(height: 30),

        // ------------------------------------------------------
        // CONTINUE BUTTON
        // ------------------------------------------------------
        PrimaryButton(
          label: 'Continue',
          onPressed: _handleEmailSubmit,
          backgroundColor: isDark ? colorScheme.primary : colorScheme.secondary,
          textColor: isDark ? colorScheme.onPrimary : colorScheme.onSecondary,
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // OTP STEP
  // ------------------------------------------------------------

  Widget OtpStep({required ColorScheme colorScheme, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // TITLE
        // ------------------------------------------------------
        RichText(
          text: TextSpan(
            style: syneBaseStyle,
            children: [
              TextSpan(
                text: 'Enter ',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              TextSpan(
                text: 'OTP',
                style: TextStyle(color: colorScheme.primary),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 12),

        // ------------------------------------------------------
        // EMAIL DESCRIPTION
        // ------------------------------------------------------
        Text(
          'Enter the OTP sent to',
          style: interBaseStyle.copyWith(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          _emailController.text.trim(),
          style: interBaseStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 42),

        // ------------------------------------------------------
        // OTP INPUT
        // ------------------------------------------------------
        Form(
          key: _otpFormKey,
          child: Column(
            children: [
              FadeTransition(
                opacity: _otpFadeAnimation,
                child: SlideTransition(
                  position: _otpSlideAnimation,
                  child: Center(
                    child: Pinput(
                      controller: _otpController,
                      length: 4,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      hapticFeedbackType: HapticFeedbackType.vibrate,

                      defaultPinTheme: PinTheme(
                        width: 72,
                        height: 72,
                        textStyle: interBaseStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                      ),

                      focusedPinTheme: PinTheme(
                        width: 72,
                        height: 72,
                        textStyle: interBaseStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),

                      errorPinTheme: PinTheme(
                        width: 72,
                        height: 72,
                        textStyle: interBaseStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.error,
                            width: 1.5,
                          ),
                        ),
                      ),

                      separatorBuilder: (index) => const SizedBox(width: 12),

                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'Please enter the 4-digit OTP';
                        }

                        return null;
                      },

                      onCompleted: (value) {
                        _handleVerifyOtp();
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------
              // RESEND TEXT
              // ------------------------------------------------
              Text(
                "Didn't receive the code?",
                textAlign: TextAlign.center,
                style: interBaseStyle.copyWith(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // RESEND OTP
              // ------------------------------------------------
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _remainingSeconds == 0 ? _handleResendOtp : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _remainingSeconds == 0
                            ? 'Resend OTP'
                            : 'Resend OTP in 00:${_remainingSeconds.toString().padLeft(2, '0')}',
                        key: ValueKey(_remainingSeconds == 0),
                        style: interBaseStyle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _remainingSeconds == 0
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------
              // VERIFY BUTTON
              // ------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Verify OTP',
                  onPressed: _handleVerifyOtp,
                  backgroundColor: isDark
                      ? colorScheme.primary
                      : colorScheme.secondary,
                  textColor: isDark
                      ? colorScheme.onPrimary
                      : colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // ------------------------------------------------------------
  // STEP INDICATOR
  // ------------------------------------------------------------

  // ------------------------------------------------------------
  // RESET PASSWORD STEP
  // ------------------------------------------------------------

  Widget ResetPasswordStep({
    required ColorScheme colorScheme,
    required OutlineInputBorder inputBorder,
    required bool isDark,
  }) {
    return Form(
      key: _resetPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------
          RichText(
            text: TextSpan(
              style: syneBaseStyle,
              children: [
                TextSpan(
                  text: 'Create New ',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                TextSpan(
                  text: 'Password',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 12),

          Text(
            'Create a new password for your account.',
            style: interBaseStyle.copyWith(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 42),

          // ------------------------------------------------------
          // PASSWORD LABEL
          // ------------------------------------------------------
          Text(
            'NEW PASSWORD',
            style: interBaseStyle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 8),

          // ------------------------------------------------------
          // PASSWORD
          // ------------------------------------------------------
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            style: interBaseStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter new password',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 1.5),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            validator: (value) {
              final password = value ?? '';

              if (password.isEmpty) {
                return 'Please enter a new password';
              }

              if (password.length < 8) {
                return 'Password must be at least 8 characters';
              }

              return null;
            },
          ),

          const SizedBox(height: 24),

          // ------------------------------------------------------
          // CONFIRM PASSWORD LABEL
          // ------------------------------------------------------
          Text(
            'CONFIRM PASSWORD',
            style: interBaseStyle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 8),

          // ------------------------------------------------------
          // CONFIRM PASSWORD
          // ------------------------------------------------------
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            style: interBaseStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Confirm new password',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 1.5),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            validator: (value) {
              final confirmPassword = value ?? '';

              if (confirmPassword.isEmpty) {
                return 'Please confirm your password';
              }
              if (confirmPassword != _passwordController.text) {
                return 'Passwords do not match';
              }

              return null;
            },
            onFieldSubmitted: (_) {
              _handleResetPassword();
            },
          ),

          const SizedBox(height: 32),

          // ------------------------------------------------------
          // RESET PASSWORD BUTTON
          // ------------------------------------------------------
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Reset Password',
              onPressed: _handleResetPassword,
              backgroundColor: isDark
                  ? colorScheme.primary
                  : colorScheme.secondary,
              textColor: isDark
                  ? colorScheme.onPrimary
                  : colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        _stepCircle(number: 1, active: step >= 1, colorScheme: colorScheme),

        Expanded(
          child: _stepLine(active: step >= 2, colorScheme: colorScheme),
        ),

        _stepCircle(number: 2, active: step >= 2, colorScheme: colorScheme),

        Expanded(
          child: _stepLine(active: step >= 3, colorScheme: colorScheme),
        ),

        _stepCircle(number: 3, active: step >= 3, colorScheme: colorScheme),
      ],
    );
  }

  // ------------------------------------------------------------
  // STEP CIRCLE
  // ------------------------------------------------------------

  Widget _stepCircle({
    required int number,
    required bool active,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: () {
        _tapCircle(number);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? colorScheme.primary : colorScheme.surface,
          border: Border.all(
            color: active
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP LINE
  // ------------------------------------------------------------

  Widget _stepLine({required bool active, required ColorScheme colorScheme}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: active
          ? colorScheme.primary
          : colorScheme.onSurface.withValues(alpha: 0.1),
    );
  }
}
