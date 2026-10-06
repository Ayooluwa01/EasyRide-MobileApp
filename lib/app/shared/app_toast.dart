import 'package:flutter/material.dart';

class AppToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    _current?.remove();

    final entry = OverlayEntry(
      builder: (_) => _ToastView(message: message, isError: isError),
    );
    _current = entry;
    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (_current == entry) {
        entry.remove();
        _current = null;
      }
    });
  }
}

class _ToastView extends StatefulWidget {
  final String message;
  final bool isError;

  const _ToastView({required this.message, required this.isError});

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError ? Colors.red.shade700 : Colors.green.shade700;
    final icon = widget.isError
        ? Icons.error_outline
        : Icons.check_circle_outline;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _controller,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
