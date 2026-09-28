import 'package:flutter/material.dart';

class BiometricPromptDialog extends StatelessWidget {
  const BiometricPromptDialog({
    super.key,
    required this.isFace,
    required this.reason,
  });

  final bool isFace;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Align(
        alignment: const Alignment(0, -0.55),
        child: Material(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 8,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 300,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isFace
                        ? Icons.face_unlock_outlined
                        : Icons.fingerprint_rounded,
                    size: 26,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Verify it's you",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reason,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
