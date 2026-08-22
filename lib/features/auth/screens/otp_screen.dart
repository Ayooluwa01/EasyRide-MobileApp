import 'dart:async';

import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:easy_ride/core/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
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

  @override
  void dispose() {
    _otpAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
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
                          AppBackButton(),
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

                          // Description
                          Text(
                            "We've sent a code to +234 812 *** 6789",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 42),

                          // ─────────────────────────
                          // OTP
                          // ─────────────────────────
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
                                          length: 4,

                                          hapticFeedbackType:
                                              HapticFeedbackType.vibrate,

                                          defaultPinTheme: PinTheme(
                                            width: 80,
                                            height: 80,
                                            textStyle: GoogleFonts.inter(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.onSurface,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surface,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: colorScheme.outline
                                                    .withValues(alpha: 0.2),
                                              ),
                                            ),
                                          ),

                                          separatorBuilder: (index) =>
                                              const SizedBox(width: 16),

                                          pinputAutovalidateMode:
                                              PinputAutovalidateMode.onSubmit,

                                          validator: (pin) {
                                            if (pin == '2224') {
                                              return null;
                                            }

                                            return 'Pin is incorrect';
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
                                        ? () {
                                            startTimer();
                                          }
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

                                // ─────────────────────────
                                // VERIFY BUTTON
                                // ─────────────────────────
                                Center(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: PrimaryButton(
                                      label: 'Verify & Create Account',
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          // context.push(RouteNames.otp);
                                        }
                                      },
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

                    // ─────────────────────────────
                    // FOOTER
                    // ─────────────────────────────
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
