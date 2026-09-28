import 'dart:async';

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/app/shared/auth_form_provider.dart';
import 'package:easy_ride/app/shared/storage_keys.dart';
import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:easy_ride/core/widgets/back_button.dart';
import 'package:easy_ride/features/auth/controllers/login_controller.dart';
import 'package:easy_ride/features/auth/controllers/otp_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class SignupOtpScreen extends ConsumerStatefulWidget {
  const SignupOtpScreen({super.key, this.contactInfo, this.phone});
  final String? contactInfo;
  final String? phone;

  @override
  ConsumerState<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends ConsumerState<SignupOtpScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Timer? _timer;
  int _remainingSeconds = 60;
  late AnimationController _otpAnimationController;
  late Animation<double> _otpFadeAnimation;
  late Animation<Offset> _otpSlideAnimation;
  @override
  void initState() {
    super.initState();
    startTimer();

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

  void startTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        Endpoints.verifySignupOtp,
        data: {
          "email": widget.contactInfo,
          "code": _pinController.text.trim(),
          "phone": widget.phone ?? "",
        },
      );

      if (!mounted) return;

      final body = response.data;

      if (body['success'] == true) {
        final data = body['data'];

        if (data['STEP'] == 'SET_PASSWORD') {
          final tokens = data['tokens'];

          await secureStorage.write(
            key: StorageKeys.accessToken,
            value: tokens['accessToken'],
          );

          await secureStorage.write(
            key: StorageKeys.refreshToken,
            value: tokens['refreshToken'],
          );

          await secureStorage.write(
            key: StorageKeys.userRole,
            value: data['role'],
          );
          await secureStorage.write(
            key: StorageKeys.needsPassword,
            value: 'true',
          );

          if (!mounted) return;
          context.go(RouteNames.createPassword);
        } else {
          ref
              .read(appToastProvider.notifier)
              .showError('Unexpected step: ${data['STEP']}');
        }
      } else {
        ref
            .read(appToastProvider.notifier)
            .showError(body['message']?.toString() ?? 'Verification failed');
      }
    } catch (e) {
      if (!mounted) return;
      ref.read(appToastProvider.notifier).showError(e.toString());
    }
  }

  // resend otp
  void resendOtp() async {
    if (widget.contactInfo == null) {
      return;
    }

    _pinController.clear();
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        Endpoints.resendOtp,
        data: {'email': widget.contactInfo},
      );
      final data = response.data['data'];
      ref.read(appToastProvider.notifier).showSuccess(data['message']);
      startTimer();
    } catch (e) {}
  }

  @override
  void dispose() {
    _pinController.dispose();
    _otpAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen<AsyncValue<LoginOtpResponse?>>(authControllerProvider, (
    //   previous,
    //   next,
    // ) {
    //   if (next.hasError) {
    //   } else if (next.hasValue && next.value != null) {
    //     ref
    //         .watch(appToastProvider.notifier)
    //         .showSuccess("Otp resent successfully");
    //   }
    // });
    final authState = ref.watch(loginControllerProvider);
    ref.listen<AsyncValue>(otpControllerProvider, ((previous, next) {
      if (next.hasError) {
      } else if (next.hasValue && next.value != null) {
        ref
            .watch(appToastProvider.notifier)
            .showSuccess("Otp resent successfully");
      }
    }));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    // final authState = ref.read(OtpController);
    final loginData = ref.watch(loginRequestProvider);

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
                          const AppBackButton(),
                          const SizedBox(height: 35),

                          // Title
                          Text(
                            'Verify your\nnumber',
                            style: GoogleFonts.syne(
                              fontSize: 30,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Flexible(
                            child: Text(
                              'We\'ve sent a code to ${loginData?.email ?? widget.contactInfo ?? "your device"}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 42),

                          // Form & OTP Input
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Center(
                                  child: FadeTransition(
                                    opacity: _otpFadeAnimation,
                                    child: SlideTransition(
                                      position: _otpSlideAnimation,
                                      child: Center(
                                        child: Pinput(
                                          keyboardType: TextInputType.text,
                                          controller: _pinController,
                                          length: 4,
                                          hapticFeedbackType:
                                              HapticFeedbackType.vibrate,
                                          defaultPinTheme: PinTheme(
                                            width: 70,
                                            height: 60,
                                            textStyle: GoogleFonts.inter(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.onSurface,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surface,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: colorScheme.outline
                                                    .withValues(alpha: 0.2),
                                              ),
                                            ),
                                          ),
                                          separatorBuilder: (index) =>
                                              const SizedBox(width: 25),
                                          validator: (pin) {
                                            if (pin == null || pin.length < 4) {
                                              return 'Please enter 4 digits';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Didn't receive
                                Text(
                                  "Didn't receive the code?",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Resend
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: _remainingSeconds == 0
                                        ? resendOtp
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: ScaleTransition(
                                              scale:
                                                  Tween<double>(
                                                    begin: 0.9,
                                                    end: 1.0,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve: Curves.easeOutBack,
                                                    ),
                                                  ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          _remainingSeconds == 0
                                              ? 'Resend code'
                                              : 'Resend in 00:${_remainingSeconds.toString().padLeft(2, '0')}',
                                          key: ValueKey(_remainingSeconds == 0),
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            height: 1.2,
                                            fontWeight: FontWeight.w700,
                                            color: _remainingSeconds == 0
                                                ? colorScheme.primary
                                                : colorScheme.onSurface
                                                      .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // VERIFY BUTTON
                                Center(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: PrimaryButton(
                                      label: authState.isLoading
                                          ? 'Verifying...'
                                          : 'Verify & Create Account',
                                      onPressed: authState.isLoading
                                          ? () {}
                                          : verifyOtp,
                                      backgroundColor: isDark
                                          ? colorScheme.primary
                                          : colorScheme.secondary,
                                      textColor: isDark
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSecondary,
                                    ),
                                  ),
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
                        ),
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
