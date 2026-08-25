import 'dart:async';
import 'dart:ui';

import 'package:easy_ride/app/models/toast_notification_model.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

class Preloader extends ConsumerStatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const Preloader({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(seconds: 300),
  });

  @override
  ConsumerState<Preloader> createState() => _PreloaderState();
}

class _PreloaderState extends ConsumerState<Preloader> {
  Timer? _inactivityTimer;
  bool _isInactive = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(widget.timeoutDuration, _handleTimeout);
  }

  void _resetTimer() {
    if (_isInactive) {
      setState(() {
        _isInactive = false;
      });
    }
    _startTimer();
  }

  void _handleTimeout() {
    if (mounted) {
      setState(() {
        _isInactive = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(appActivityProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<ToastData?>(appToastProvider, (previous, next) {
      if (next == null) return;
      _showThemedToast(context, next);
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerHover: (_) => _resetTimer(),
      child: Stack(
        children: [
          widget.child,

          // Inactivity Blur Layer
          if (_isInactive) ...[
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 5.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, blurValue, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurValue,
                      sigmaY: blurValue,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  );
                },
              ),
            ),
          ],
          // Loading Indicator Layer
          if (isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                child: Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showThemedToast(BuildContext context, ToastData data) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final Color border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final Color textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final Color textSecondary = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final Color accent = switch (data.type) {
      ToastType.error => AppColors.error,
      ToastType.success => AppColors.success,
      ToastType.info => AppColors.info,
    };

    final IconData icon = switch (data.type) {
      ToastType.error => Icons.error_outline_rounded,
      ToastType.success => Icons.check_circle_outline_rounded,
      ToastType.info => Icons.info_outline_rounded,
    };

    toastification.showCustom(
      context: context,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      builder: (context, holder) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.type.name[0].toUpperCase() +
                          data.type.name.substring(1),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => toastification.dismissById(holder.id),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
