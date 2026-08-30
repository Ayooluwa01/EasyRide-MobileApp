import 'package:flutter/material.dart';

class RequestRideSearchingRadar extends StatefulWidget {
  const RequestRideSearchingRadar({
    super.key,
    required this.color,
    this.label = 'Looking for nearby drivers...',
    this.onCancel,
  });

  final Color color;

  final String? label;

  final VoidCallback? onCancel;

  @override
  State<RequestRideSearchingRadar> createState() =>
      _RequestRideSearchingRadarState();
}

class _RequestRideSearchingRadarState extends State<RequestRideSearchingRadar>
    with SingleTickerProviderStateMixin {
  static const int _ringCount = 3;
  static const double _radarSize = 200;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _radarSize,
          height: _radarSize,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (var i = 0; i < _ringCount; i++)
                    _buildRing((_controller.value + i / _ringCount) % 1.0),
                  _buildCenterDot(),
                ],
              );
            },
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 13,

              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
            ),
          ),
        ],
        if (widget.onCancel != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Cancel'),
          ),
        ],
      ],
    );
  }

  Widget _buildRing(double t) {
    return Opacity(
      opacity: (1 - t).clamp(0.0, 1.0),
      child: Transform.scale(
        scale: 1 + t,
        child: Container(
          width: _radarSize,
          height: _radarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.color, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDot() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 8),
        ],
      ),
    );
  }
}
