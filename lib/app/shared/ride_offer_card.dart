import 'dart:math' as math;

import 'package:easy_ride/app/models/ride_offer_model.dart';
import 'package:easy_ride/app/shared/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RideOfferCard extends StatefulWidget {
  final RideOfferModel offer;
  final bool isOnline;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RideOfferCard({
    super.key,
    required this.offer,
    required this.isOnline,
    this.onAccept,
    this.onReject,
  });

  @override
  State<RideOfferCard> createState() => _RideOfferCardState();
}

class _RideOfferCardState extends State<RideOfferCard> {
  late num _offer;
  late final TextEditingController _amountController;

  static const double _step = 200;

  @override
  void initState() {
    super.initState();
    _offer = widget.offer.fare ?? 0;
    _amountController = TextEditingController(text: _offer.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _adjustOffer(double delta) {
    setState(() {
      _offer = math.max(0, _offer + delta);
      _amountController.text = _offer.toStringAsFixed(0);
    });
    HapticFeedback.selectionClick();
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m away';
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isOnline = widget.isOnline;
    final offer = widget.offer;
    final cardBg = isDark ? colorScheme.surface : Colors.white;

    return Dismissible(
      key: ValueKey('ride_offer_${offer.rideId}'),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.35},
      onUpdate: (details) {
        if (details.progress > 0.03 && details.progress < 0.06) {
          HapticFeedback.selectionClick();
        }
      },
      background: _RejectSwipeBackground(colorScheme: colorScheme),
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        widget.onReject?.call();
        return true;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.transparent
                  : colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------
            // Header: fare badge + distance
            // ------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ED47A).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      formatFare(offer.fare ?? 0),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        size: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDistance(offer.distanceFromDriverMeters),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ------------------------------------------
            // Pickup → Dropoff
            // ------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 12,
                    child: Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          height: 38,
                          child: CustomPaint(
                            size: const Size(2, 28),
                            painter: _DashedLinePainter(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFFEF5B5B),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From ${offer.pickup.address ?? 'Pickup location'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'To ${offer.dropoff.address ?? 'Dropoff location'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Divider(
              height: 1,
              color: colorScheme.onSurface.withValues(alpha: 0.07),
            ),
            const SizedBox(height: 16),

            // ------------------------------------------
            // Offer stepper
            // ------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your offer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _StepperButton(
                          icon: Icons.remove_rounded,
                          colorScheme: colorScheme,
                          onTap: () => _adjustOffer(-_step),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                            decoration: const InputDecoration(
                              prefixText: '₦ ',
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            onChanged: (value) {
                              final parsed = num.tryParse(
                                value.replaceAll(',', ''),
                              );
                              if (parsed != null) _offer = parsed;
                            },
                          ),
                        ),
                        _StepperButton(
                          icon: Icons.add_rounded,
                          colorScheme: colorScheme,
                          onTap: () => _adjustOffer(_step),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------
            // Accept button
            // ------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isOnline ? widget.onAccept : null,
                  icon: const Icon(Icons.check_rounded, size: 19),
                  label: const Text(
                    'Accept ride',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------
            // Swipe hint
            // ------------------------------------------
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  Text(
                    'Swipe to decline',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 52,
          child: Icon(icon, size: 18, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dashHeight = 3.5;
    const dashGap = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, math.min(y + dashHeight, size.height)),
        paint,
      );
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _RejectSwipeBackground extends StatelessWidget {
  const _RejectSwipeBackground({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 26),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF5B5B),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.close_rounded, color: Colors.white, size: 22),
          SizedBox(height: 2),
          Text(
            'Decline',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
