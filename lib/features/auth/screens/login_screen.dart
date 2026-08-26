import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/shared/auth_form_provider.dart';
import 'package:easy_ride/app/theme/theme_provider.dart';
import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:easy_ride/features/auth/controllers/login_controller.dart';
import 'package:easy_ride/features/auth/models/auth/login_model.dart';
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

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = LoginRequest(
      phone: _numberController.text.trim(),
      email: _emailEditingController.text.trim(),
    );

    try {
      final response = await ref
          .read(loginControllerProvider.notifier)
          .login(request);

      if (!mounted) return;

      if (response.success) {
        ref.read(loginRequestProvider.notifier).state = request;
        context.push(RouteNames.otp);
      }
    } catch (e) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final interBaseStyle = GoogleFonts.inter();
    final syneBaseStyle = GoogleFonts.syne(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 20,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
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
                      RichText(
                        text: TextSpan(
                          style: syneBaseStyle,
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
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        "Enter your phone number to sign in.",
                        style: interBaseStyle.copyWith(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Form Section
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PHONE NUMBER",
                              style: interBaseStyle.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            TextFormField(
                              controller: _numberController,
                              keyboardType: TextInputType.phone,
                              style: interBaseStyle.copyWith(
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
                                border: inputBorder,
                                enabledBorder: inputBorder,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter your phone number'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            Text(
                              "EMAIL ADDRESS",
                              style: interBaseStyle.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            TextFormField(
                              controller: _emailEditingController,
                              keyboardType: TextInputType.emailAddress,
                              style: interBaseStyle.copyWith(
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
                                border: inputBorder,
                                enabledBorder: inputBorder,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Please enter your email address'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            PrimaryButton(
                              label: "Continue",
                              onPressed: login,
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
                            style: interBaseStyle.copyWith(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(RouteNames.signup),
                            child: Text(
                              " Create account",
                              style: interBaseStyle.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 260,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: interBaseStyle.copyWith(
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
