import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStarted extends ConsumerWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = [
      isDark
          ? colorScheme.primary.withValues(alpha: 0.1)
          : colorScheme.primary.withValues(alpha: 0.23),
      theme.scaffoldBackgroundColor,
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.82,
            colors: gradientColors,
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                const Spacer(),

                // Center App Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 48,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 32),

                // EasyRide Rich Text Title
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.syne(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                    children: [
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
                const SizedBox(height: 16),

                // Subtitle
                SizedBox(
                  width: 280,
                  child: Text(
                    isDark
                        ? "The pulse of Lagos. Move faster, safer, and smarter."
                        : "Your city, simplified. Fast, safe, and reliable rides at your fingertips.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),

                const Spacer(),

                // Get Started Primary Button
                PrimaryButton(
                  label: "Log in",
                  backgroundColor: isDark
                      ? colorScheme.primary
                      : colorScheme.secondary,
                  textColor: isDark
                      ? colorScheme.onPrimary
                      : colorScheme.onSecondary,
                  onPressed: () {
                    context.push(RouteNames.login);
                  },
                ),
                const SizedBox(height: 12),

                // Sign In Secondary Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(
                        color: colorScheme.onSurface.withOpacity(0.12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Tags
                Text(
                  isDark
                      ? "SAFETY  •  SPEED  •  RELIABILITY"
                      : "SAFETY  •  SPEED  •  EASY",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
