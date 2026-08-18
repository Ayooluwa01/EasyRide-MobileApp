// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../../../app/theme/theme_provider.dart';

// // class LoginScreen extends ConsumerWidget {
// //   const LoginScreen({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final themeMode = ref.watch(themeProvider);

// //     return Scaffold(
// //       // appBar: AppBar(title: const Text('Ride App')),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text(themeMode == ThemeMode.light ? 'Light Mode' : 'Dark Mode'),

// //             const SizedBox(height: 20),

// //             ElevatedButton(
// //               onPressed: () {
// //                 ref.read(themeProvider.notifier).toggleTheme();
// //               },
// //               child: const Text('Request Ride'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'package:easy_ride/app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    void goBack() {
      if (context.canPop()) {
        context.pop();
        ref.read(themeProvider.notifier).toggleTheme();
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button Container
              Container(
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
              const SizedBox(height: 20),

              SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.syne(
                      fontSize: 30,
                      height: 1.3,
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
              Text(
                "Enter your phone number to sign in.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 0.3,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
