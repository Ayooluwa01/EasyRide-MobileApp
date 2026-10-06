import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SosButton extends StatefulWidget {
  const SosButton({
    super.key,
    required this.onTriggered,
    this.isActive = false,
    this.onActiveTap,
    this.holdDuration = const Duration(seconds: 2),
  });

  final Future<void> Function() onTriggered;
  final bool isActive;
  final VoidCallback? onActiveTap;
  final Duration holdDuration;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold =
      AnimationController(vsync: this, duration: widget.holdDuration)
        ..addStatusListener((status) async {
          if (status == AnimationStatus.completed) {
            HapticFeedback.heavyImpact();
            await widget.onTriggered();
            if (mounted) _hold.reset();
          }
        });

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  void _start() {
    if (widget.isActive) return;
    HapticFeedback.mediumImpact();
    _hold.forward();
  }

  void _cancel() {
    if (widget.isActive) return;
    if (_hold.status != AnimationStatus.completed) _hold.reverse();
  }

  String get _label {
    if (widget.isActive) return 'SOS ACTIVE';
    if (_hold.value > 0) return 'KEEP HOLDING';
    return 'HOLD ${widget.holdDuration.inSeconds}S';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isActive ? widget.onActiveTap : null,
      onTapDown: (_) => _start(),
      onTapUp: (_) => _cancel(),
      onTapCancel: _cancel,
      child: AnimatedBuilder(
        animation: _hold,
        builder: (context, _) {
          final progress = widget.isActive ? 1.0 : _hold.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // White backing so it stands out on any map color.
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    // Progress ring: dark so it's visible on the white backing.
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        color: const Color(0xFF7F1010),
                        backgroundColor: Colors.red.withValues(alpha: 0.12),
                      ),
                    ),
                    // Red button grows slightly while held.
                    Transform.scale(
                      scale: 1 + (progress * 0.1),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC22424),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            widget.isActive
                                ? Icons.notifications_active
                                : Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? const Color(0xFFC22424)
                      : Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
