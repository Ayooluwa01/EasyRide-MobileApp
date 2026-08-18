import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride App')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(themeMode == ThemeMode.light ? 'Light Mode' : 'Dark Mode'),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              child: const Text('Request Ride'),
            ),
          ],
        ),
      ),
    );
  }
}
