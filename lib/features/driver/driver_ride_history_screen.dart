import 'dart:developer' as developer;

import 'package:easy_ride/app/models/ride_history_model.dart';
import 'package:easy_ride/app/models/ride_offer_model.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/ride_history.dart';
import 'package:easy_ride/app/services/ride_offer_provider.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/app/shared/number_formatter.dart';
import 'package:easy_ride/app/shared/ride_offer_card.dart';
import 'package:easy_ride/core/controllers/active_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum DriverRideTab { requests, history }

class DriverRideHistoryScreen extends ConsumerStatefulWidget {
  const DriverRideHistoryScreen({super.key});

  @override
  ConsumerState<DriverRideHistoryScreen> createState() =>
      _DriverRideHistoryScreenState();
}

class _DriverRideHistoryScreenState
    extends ConsumerState<DriverRideHistoryScreen> {
  DriverRideTab _selectedTab = DriverRideTab.requests;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rideHistoryProvider.notifier).getUserTrips();
    });
  }

  void _acceptOffer(RideOfferModel offer, num counterOfferAmount) async {
    final success = await ref
        .read(rideOffersProvider.notifier)
        .acceptOffer(offer.rideId, counterOfferAmount);

    if (!mounted) return;
    if (success) {
      ref
          .read(appToastProvider.notifier)
          .showSuccess("OFFER SENT SUCCESSFULLY");
      return;
    }
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This ride is no longer available')),
      );
    }
  }

  void _rejectOffer(RideOfferModel offer) async {
    final success = await ref
        .read(rideOffersProvider.notifier)
        .rejectOffer(offer.rideId);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syneBaseStyle = GoogleFonts.syne(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );
    final interBaseStyle = GoogleFonts.inter();
    final tripsState = ref.watch(rideHistoryProvider);
    final offers = ref.watch(rideOffersProvider);
    // websocket
    ref.listen(activeRideProvider, (previous, next) {
      final previousStatus = previous?['status'];
      final nextStatus = next?['status'];
      if (nextStatus == 'MATCHED' && previousStatus != 'MATCHED') {
        developer.log("COUNTING RE RENDERING");
        context.push(RouteNames.driveractiveride, extra: next?['rideId']);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rides',
                style: syneBaseStyle.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              _DriverRideTopbar(
                selected: _selectedTab,
                requestCount: offers.valueOrNull?.length ?? 0,
                onChanged: (tab) => setState(() => _selectedTab = tab),
                interBaseStyle: interBaseStyle,
              ),
              const SizedBox(height: 20),

              Expanded(
                child: _selectedTab == DriverRideTab.requests
                    ? _buildRequestsTab(offers, colorScheme, interBaseStyle)
                    : _buildHistoryTab(tripsState, colorScheme, interBaseStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsTab(
    AsyncValue<List<RideOfferModel>> offersState,
    ColorScheme colorScheme,
    TextStyle interBaseStyle,
  ) {
    return offersState.when(
      loading: () => _LookingForRidesState(
        colorScheme: colorScheme,
        interBaseStyle: interBaseStyle,
      ),
      error: (error, stack) => _RequestsErrorState(
        colorScheme: colorScheme,
        interBaseStyle: interBaseStyle,
        onRetry: () => ref.read(rideOffersProvider.notifier).refreshOffers(),
      ),
      data: (offers) {
        if (offers.isEmpty) {
          return _NoRidesAvailableState(
            colorScheme: colorScheme,
            interBaseStyle: interBaseStyle,
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(rideOffersProvider.notifier).refreshOffers(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];

              return RideOfferCard(
                key: ValueKey(offer.rideId),
                offer: offer,
                isOnline: true,
                onAccept: (counterOfferAmount) =>
                    _acceptOffer(offer, counterOfferAmount),
                onReject: () => _rejectOffer(offer),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(
    AsyncValue<List<RideHistoryModel>> tripsState,
    ColorScheme colorScheme,
    TextStyle interBaseStyle,
  ) {
    return tripsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Failed to load ride history',
          style: interBaseStyle.copyWith(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
      data: (trips) {
        if (trips.isEmpty) {
          return Center(
            child: Text(
              'No rides yet',
              style: interBaseStyle.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(rideHistoryProvider.notifier).getUserTrips(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: trips.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _TripHistoryCard(
                trip: trips[index],
                interBaseStyle: interBaseStyle,
              );
            },
          ),
        );
      },
    );
  }
}

// ==================================================================
// LOOKING FOR RIDES (loading state)
// ==================================================================

class _LookingForRidesState extends StatefulWidget {
  const _LookingForRidesState({
    required this.colorScheme,
    required this.interBaseStyle,
  });

  final ColorScheme colorScheme;
  final TextStyle interBaseStyle;

  @override
  State<_LookingForRidesState> createState() => _LookingForRidesStateState();
}

class _LookingForRidesStateState extends State<_LookingForRidesState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _controller,
                  child: Icon(
                    Icons.autorenew_rounded,
                    size: 40,
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                Icon(
                  Icons.local_taxi_rounded,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Looking for rides…',
            style: widget.interBaseStyle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Checking for requests near you',
            style: widget.interBaseStyle.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// NO RIDES AVAILABLE (empty state)
// ==================================================================

class _NoRidesAvailableState extends StatelessWidget {
  const _NoRidesAvailableState({
    required this.colorScheme,
    required this.interBaseStyle,
  });

  final ColorScheme colorScheme;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                size: 30,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No rides available',
              style: interBaseStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "You'll be notified as soon as a ride is available near you",
              textAlign: TextAlign.center,
              style: interBaseStyle.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// ERROR STATE
// ==================================================================

class _RequestsErrorState extends StatelessWidget {
  const _RequestsErrorState({
    required this.colorScheme,
    required this.interBaseStyle,
    required this.onRetry,
  });

  final ColorScheme colorScheme;
  final TextStyle interBaseStyle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 14),
            Text(
              'Something went wrong',
              style: interBaseStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'We couldn\'t load ride requests. Please try again.',
              textAlign: TextAlign.center,
              style: interBaseStyle.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: interBaseStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// TOPBAR — Requests / History
// ==================================================================

class _DriverRideTopbar extends StatelessWidget {
  const _DriverRideTopbar({
    required this.selected,
    required this.requestCount,
    required this.onChanged,
    required this.interBaseStyle,
  });

  final DriverRideTab selected;
  final int requestCount;
  final ValueChanged<DriverRideTab> onChanged;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Requests',
              badgeCount: requestCount,
              isSelected: selected == DriverRideTab.requests,
              onTap: () => onChanged(DriverRideTab.requests),
              interBaseStyle: interBaseStyle,
              colorScheme: colorScheme,
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'History',
              isSelected: selected == DriverRideTab.history,
              onTap: () => onChanged(DriverRideTab.history),
              interBaseStyle: interBaseStyle,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.interBaseStyle,
    required this.colorScheme,
    this.badgeCount,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TextStyle interBaseStyle;
  final ColorScheme colorScheme;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: interBaseStyle.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================================================================

// ==================================================================

class _TripHistoryCard extends StatelessWidget {
  const _TripHistoryCard({required this.trip, required this.interBaseStyle});

  final RideHistoryModel trip;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isCancelled = trip.status == 'CANCELLED';
    final tripDate = trip.completedAt ?? trip.cancelledAt ?? trip.requestedAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Rider + date + status ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      _formatTripDate(tripDate),
                      style: interBaseStyle.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TripStatusPill(
                status: trip.status,
                interBaseStyle: interBaseStyle,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ---- Route ----
          _TripRouteRow(
            pickupAddress: trip.pickupAddress,
            dropoffAddress: trip.dropoffAddress,
            colorScheme: colorScheme,
            interBaseStyle: interBaseStyle,
          ),

          if (isCancelled && trip.cancellationReason != null) ...[
            const SizedBox(height: 10),
            Text(
              trip.cancelledBy != null
                  ? 'Cancelled by ${_formatCancelledBy(trip.cancelledBy!)} — ${trip.cancellationReason}'
                  : 'Cancelled — ${trip.cancellationReason}',
              style: interBaseStyle.copyWith(
                fontSize: 12,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 12),

          // ---- Fare + payment + distance ----
          Row(
            children: [
              // Text(
              //   trip.fareEstimate != null ? formatFare(num.tryParse(trip.fareEstimate)) : '—',
              //   style: interBaseStyle.copyWith(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w800,
              //     color: colorScheme.onSurface,
              //   ),
              // ),
              // const SizedBox(width: 10),
              _TripPaymentChip(
                method: trip.paymentMethod,
                status: trip.paymentStatus,
                interBaseStyle: interBaseStyle,
                colorScheme: colorScheme,
              ),
              const Spacer(),
              if (trip.distanceKm != null)
                Text(
                  '${trip.distanceKm!.toStringAsFixed(1)} km',
                  style: interBaseStyle.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _TripRouteRow({
  required String pickupAddress,
  required String dropoffAddress,
  required ColorScheme colorScheme,
  required TextStyle interBaseStyle,
}) {
  final mutedText = interBaseStyle.copyWith(
    fontSize: 13,
    color: colorScheme.onSurface.withValues(alpha: 0.75),
  );

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Icon(
            Icons.radio_button_checked,
            size: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          Container(
            width: 1,
            height: 22,
            margin: const EdgeInsets.symmetric(vertical: 2),
            color: colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const Icon(Icons.location_on, size: 12, color: Color(0xFFEF4444)),
        ],
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pickupAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mutedText,
            ),
            const SizedBox(height: 14),
            Text(
              dropoffAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mutedText,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _TripStatusPill({
  required String status,
  required TextStyle interBaseStyle,
}) {
  final color = _tripStatusColor(status);
  final label = _tripStatusLabel(status);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: interBaseStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}

Widget _TripPaymentChip({
  required String method,
  required String status,
  required TextStyle interBaseStyle,
  required ColorScheme colorScheme,
}) {
  final label =
      '${_formatPaymentMethod(method)} · ${_formatPaymentStatus(status)}';
  final color = _paymentStatusColor(status);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: colorScheme.onSurface.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: interBaseStyle.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    ),
  );
}

String _formatTripDate(DateTime date) {
  return DateFormat('MMM d, yyyy · h:mm a').format(date.toLocal());
}

String _formatCancelledBy(String cancelledBy) {
  switch (cancelledBy) {
    case 'RIDER':
      return 'rider';
    case 'DRIVER':
      return 'you';
    case 'ADMIN':
      return 'support';
    default:
      return cancelledBy.toLowerCase();
  }
}

String _tripStatusLabel(String status) {
  switch (status) {
    case 'COMPLETED':
      return 'Completed';
    case 'CANCELLED':
      return 'Cancelled';
    default:
      return status;
  }
}

Color _tripStatusColor(String status) {
  switch (status) {
    case 'COMPLETED':
      return const Color(0xFF22C55E);
    case 'CANCELLED':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFFF59E0B);
  }
}

String _formatPaymentMethod(String method) {
  switch (method) {
    case 'CASH':
      return 'Cash';
    case 'CARD':
      return 'Card';
    case 'TRANSFER':
      return 'Transfer';
    default:
      return method;
  }
}

String _formatPaymentStatus(String status) {
  switch (status) {
    case 'PAID':
      return 'Paid';
    case 'PENDING':
      return 'Pending';
    case 'FAILED':
      return 'Failed';
    default:
      return status;
  }
}

Color _paymentStatusColor(String status) {
  switch (status) {
    case 'PAID':
      return const Color(0xFF22C55E);
    case 'FAILED':
      return const Color(0xFFEF4444);
    case 'PENDING':
    default:
      return const Color(0xFFF59E0B);
  }
}
