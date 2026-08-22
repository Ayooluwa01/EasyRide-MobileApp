import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/shared/app-activity-provider.dart';
import 'package:easy_ride/app/shared/auth_form_provider.dart';
import 'package:easy_ride/app/theme/theme_provider.dart';
import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:easy_ride/features/auth/models/auth/login_model.dart';
import 'package:easy_ride/features/auth/state/auth.state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;
  late final TextEditingController _emailEditingController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
    _emailEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _emailEditingController.dispose();
    super.dispose();
  }

  void goBack() {
    if (context.canPop()) {
      ref.read(themeProvider.notifier).toggleTheme();
      context.pop();
    }
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      final request = LoginRequest(
        email: _emailEditingController.text.trim(),
        phone: _numberController.text.trim(),
      );
      try {
        final response = await ref
            .read(authControllerProvider.notifier)
            .login(request);
        if (mounted && response != null) {
          ref
              .read(appToastProvider.notifier)
              .showSuccess("Otp sent to your email");
          ref.read(loginRequestProvider.notifier).state = request;
          context.push(RouteNames.otp);
        }
      } catch (e) {}
      // context.push(RouteNames.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Back Button Container
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
                            spreadRadius: 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: goBack,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: colorScheme.onSurface,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Welcome Title
                  SizedBox(
                    width: double.infinity,
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.syne(
                          fontSize: 30,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: "Welcome back to \n",
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          TextSpan(
                            text: "Easy",
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          TextSpan(
                            text: "Ride",
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    "Enter your phone number to sign in.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Label
                  Text(
                    "PHONE NUMBER",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Form & Phone Input Field
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _numberController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: "800 000 0000",
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "EMAIL ADDRESS",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email Address input
                        TextFormField(
                          controller: _emailEditingController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: "yourEmail@gmail.com",
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: "Continue",
                          onPressed: () {
                            login();
                          },
                          backgroundColor: isDark
                              ? colorScheme.primary
                              : colorScheme.secondary,
                          textColor: isDark
                              ? colorScheme.onPrimary
                              : colorScheme.onSecondary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Create Account Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New to Easy Ride?",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(RouteNames.signup);
                        },
                        child: Text(
                          " Create account",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),

            // footer
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 260,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          height: 1.5,
                          letterSpacing: 0.5,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        children: [
                          const TextSpan(
                            text: "BY CONTINUING, YOU AGREE TO EASY RIDE'S ",
                          ),
                          TextSpan(
                            text: "TERMS OF SERVICE",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const TextSpan(text: " & "),
                          TextSpan(
                            text: "PRIVACY POLICY",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
