import 'package:easy_ride/app/shared/app-activity-provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Preloader extends ConsumerWidget {
  final Widget child;

  const Preloader({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(appActivityProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,

        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
