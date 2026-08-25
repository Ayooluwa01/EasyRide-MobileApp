import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                // Splash Illustration
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/splash.png',
                      height: 600,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Main Heading with Highlighted Word
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.syne(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      const TextSpan(text: "Ride with\n"),
                      TextSpan(
                        text: "Ease ",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                      const TextSpan(text: "today"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  "Book in one tap and enjoy a\nseamless journey across your city.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Get Started Button
                PrimaryButton(
                  label: "Get Started",
                  icon: Icons.check,
                  backgroundColor: isDark
                      ? colorScheme.primary
                      : colorScheme.secondary,
                  textColor: isDark
                      ? colorScheme.onPrimary
                      : colorScheme.onSecondary,
                  onPressed: () {
                    // ref.read(appActivityProvider.notifier).startLoading();
                    context.push(RouteNames.getstarted);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
