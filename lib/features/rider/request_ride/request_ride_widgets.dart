import 'dart:developer' as developer;

import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/shared/number_formatter.dart';
import 'package:easy_ride/app/theme/app_text_styling.dart';
import 'package:easy_ride/core/controllers/driver_offers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
export 'request_ride_searching_radar.dart';
import 'request_ride_models.dart';

class RequestRideIconButton extends StatelessWidget {
  const RequestRideIconButton({
    super.key,
    required this.icon,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: colorScheme.onSurface, size: 20),
        ),
      ),
    );
  }
}

class RequestRideSearchPanel extends StatelessWidget {
  const RequestRideSearchPanel({
    super.key,
    required this.isDark,
    required this.colorScheme,
    required this.destinationController,
    required this.destinationFocusNode,
    required this.isSearching,
    required this.hasDestination,
    required this.onChanged,
    required this.onClear,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final TextEditingController destinationController;
  final FocusNode destinationFocusNode;
  final bool isSearching;
  final bool hasDestination;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup row (fixed to current location for now)
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Current location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 4.5),
                SizedBox(
                  height: 16,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1.5,
                    color: (isDark ? Colors.white24 : Colors.black12),
                  ),
                ),
              ],
            ),
          ),
          // Destination row
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: destinationController,
                  focusNode: destinationFocusNode,
                  autofocus: true,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Where are you going?',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (isSearching)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              else if (destinationController.text.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.cancel,
                    size: 18,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RequestRideSuggestionsList extends StatelessWidget {
  const RequestRideSuggestionsList({
    super.key,
    required this.isDark,
    required this.colorScheme,
    required this.suggestions,
    required this.onSelect,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final List<Map<String, dynamic>> suggestions;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 56,
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return ListTile(
            onTap: () => onSelect(item),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              item['subtitle'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          );
        },
      ),
    );
  }
}

class RequestRideTripSummaryCard extends StatefulWidget {
  const RequestRideTripSummaryCard({
    super.key,
    required this.isDark,
    required this.colorScheme,
    required this.destination,
    required this.routeInfo,
    required this.isLoading,
    required this.onConfirm,
    required this.paymentSelector,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final RideDestination destination;
  final RouteInfo? routeInfo;
  final bool isLoading;
  final Widget paymentSelector;

  final ValueChanged<num> onConfirm;

  @override
  State<RequestRideTripSummaryCard> createState() =>
      _RequestRideTripSummaryCardState();
}

class _RequestRideTripSummaryCardState
    extends State<RequestRideTripSummaryCard> {
  static const num _maxReduction = 1000;
  static const num _step = 100;

  num? _offeredFare;

  @override
  void initState() {
    super.initState();
    _offeredFare = widget.routeInfo?.baseFare;
  }

  @override
  void didUpdateWidget(covariant RequestRideTripSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeInfo?.baseFare != widget.routeInfo?.baseFare) {
      _offeredFare = widget.routeInfo?.baseFare;
    }
  }

  num get _minFare {
    final base = widget.routeInfo?.baseFare ?? 0;
    final floor = base - _maxReduction;
    return floor < 0 ? 0 : floor;
  }

  void _decrement() {
    final base = widget.routeInfo?.baseFare;
    if (base == null || _offeredFare == null) return;
    final next = _offeredFare! - _step;
    setState(() => _offeredFare = next < _minFare ? _minFare : next);
  }

  void _increment() {
    final base = widget.routeInfo?.baseFare;
    if (base == null || _offeredFare == null) return;
    final next = _offeredFare! + _step;
    setState(() => _offeredFare = next > base ? base : next);
  }

  @override
  Widget build(BuildContext context) {
    final routeInfo = widget.routeInfo;
    final offeredFare = _offeredFare;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DROPPING OFF AT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: widget.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.destination.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      widget.destination.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.colorScheme.primary,
                  ),
                )
              else if (routeInfo != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      routeInfo.distanceLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      routeInfo.durationLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (!widget.isLoading &&
              routeInfo != null &&
              offeredFare != null) ...[
            const SizedBox(height: 16),
            _FareRow(
              isDark: widget.isDark,
              colorScheme: widget.colorScheme,
              baseFare: routeInfo.baseFare,
              offeredFare: offeredFare,
              onDecrement: offeredFare > _minFare ? _decrement : null,
              onIncrement: offeredFare < routeInfo.baseFare ? _increment : null,
            ),
          ],

          const SizedBox(height: 16),
          widget.paymentSelector,

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () => widget.onConfirm(
                      offeredFare ?? routeInfo?.baseFare ?? 0,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colorScheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Confirm Ride',
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({
    required this.isDark,
    required this.colorScheme,
    required this.baseFare,
    required this.offeredFare,
    required this.onDecrement,
    required this.onIncrement,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final num baseFare;
  final num offeredFare;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  bool get _isDiscounted => offeredFare < baseFare;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _isDiscounted ? 'YOUR OFFER' : 'ESTIMATED FARE',
              style: GoogleFonts.syne(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FareStepButton(
                icon: Icons.remove_rounded,
                isDark: isDark,
                onTap: onDecrement,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatFare(offeredFare),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (_isDiscounted)
                    Text(
                      'was ${formatFare(baseFare)}',
                      style: TextStyle(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                ],
              ),
              _FareStepButton(
                icon: Icons.add_rounded,
                isDark: isDark,
                onTap: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FareStepButton extends StatelessWidget {
  const _FareStepButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? (isDark ? Colors.white10 : Colors.white)
          : (isDark ? Colors.white10 : Colors.black12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white24 : Colors.black26),
          ),
        ),
      ),
    );
  }
}

class AvailableDrivers extends ConsumerWidget {
  const AvailableDrivers({
    super.key,
    required this.isDark,
    required this.colorScheme,
    required this.drivers,
    int? count,
  }) : _count = count;

  final bool isDark;
  final ColorScheme colorScheme;
  final List<dynamic> drivers;
  final int? _count;

  int get displayCount => _count ?? drivers.length;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(driverOfferProvider);

    return Container(
      constraints: const BoxConstraints(maxHeight: 560),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // =========================
          // NEARBY DRIVERS
          // =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$displayCount DRIVERS NEARBY',
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34C759),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // =========================
          // DRIVER OFFERS
          // =========================
          if (offers.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: offers.length,
                padding: EdgeInsets.zero,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final offer = offers[index];

                  return TweenAnimationBuilder<double>(
                    key: ValueKey(offer['driver']['id']),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value.clamp(0, 1),
                        child: Transform.translate(
                          offset: Offset(40 * (1 - value), 0),
                          child: child,
                        ),
                      );
                    },
                    child: _DriverOfferCard(
                      offer: offer,
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onAccept: () async {
                        try {
                          final response = await ref
                              .read(driverOfferProvider.notifier)
                              .acceptOffer(offer);
                          developer.log(
                            'Accept result — success: ${response.success}, rideId: ${response.rideId}',
                          );
                          if (!context.mounted) return;
                          if (response.success) {
                            context.go(
                              RouteNames.activeride,
                              extra: {'rideId': response.rideId},
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                        }
                      },
                      onReject: () async {
                        try {
                          await ref
                              .read(driverOfferProvider.notifier)
                              .rejectOffer(offer);
                        } catch (e) {
                          if (!context.mounted) return;
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text(
                          //       'Could not reject this offer. Please try again.',
                          //     ),
                          //     behavior: SnackBarBehavior.floating,
                          //   ),
                          // );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 36),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Waiting for driver offers…',
                    style: GoogleFonts.syne(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nearby drivers are reviewing your trip',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  String _formatDistance(double? meters) {
    if (meters == null) return 'Nearby';

    if (meters < 1000) {
      return '${meters.round()} m away';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }
}

class _DriverOfferCard extends StatelessWidget {
  const _DriverOfferCard({
    required this.offer,
    required this.isDark,
    required this.colorScheme,
    required this.onAccept,
    required this.onReject,
  });

  final dynamic offer;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final driver = offer['driver'];

    final String? photo = driver['photo'];
    final String name = driver['name'] ?? 'Driver';
    final amountValue = driver['amount'] is Map
        ? driver['amount']['amount']
        : driver['amount'];
    final amount = num.tryParse('$amountValue') ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // DRIVER PHOTO — with a subtle ring
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: isDark
                      ? Colors.white10
                      : colorScheme.primaryContainer,
                  backgroundImage: photo != null ? NetworkImage(photo) : null,
                  child: photo == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: GoogleFonts.syne(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDark
                                ? Colors.white
                                : colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              // DRIVER INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'OFFER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // PRICE
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'FARE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatFare(amount),
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(
            height: 1,
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.06),
          ),

          const SizedBox(height: 16),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Accept ${formatFare(amount)}',
                        style: GoogleFonts.syne(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: constant_identifier_names
enum PaymentMethod { CASH, TRANSFER }
