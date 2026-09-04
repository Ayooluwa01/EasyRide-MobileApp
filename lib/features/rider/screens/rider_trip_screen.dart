import 'package:easy_ride/app/models/ride_history_model.dart';
import 'package:easy_ride/app/services/ride_history.dart';
import 'package:easy_ride/app/shared/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RiderTripScreen extends ConsumerStatefulWidget {
  const RiderTripScreen({super.key});

  @override
  ConsumerState<RiderTripScreen> createState() => _RiderTripScreenState();
}

class _RiderTripScreenState extends ConsumerState<RiderTripScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rideHistoryProvider.notifier).getUserTrips();
    });
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Trips",
                style: syneBaseStyle.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: tripsState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Failed to load trip history',
                      style: interBaseStyle.copyWith(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  data: (trips) {
                    if (trips.isEmpty) {
                      return _NoTripsEmptyState(
                        syneBaseStyle: syneBaseStyle,
                        interBaseStyle: interBaseStyle,
                        onStartRide: () {},
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: trips.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _TripHistoryCard(
                          trip: trips[index],
                          interBaseStyle: interBaseStyle,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// TRIP HISTORY CARD
// ==================================================================

class _TripHistoryCard extends StatelessWidget {
  const _TripHistoryCard({required this.trip, required this.interBaseStyle});
  final RideHistoryModel trip;
  final TextStyle interBaseStyle;

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF2ED47A);
      case 'CANCELLED':
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFFF5A623);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final fare = num.tryParse(trip.fareFinal ?? trip.fareEstimate) ?? 0;
    final date = DateFormat('MMM d, y • h:mm a').format(trip.requestedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  style: interBaseStyle.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(trip.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip.status,
                  style: interBaseStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: _statusColor(trip.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.my_location,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                  ),
                  Icon(Icons.location_on, size: 14, color: colorScheme.primary),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.pickupAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: interBaseStyle.copyWith(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      trip.dropoffAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: interBaseStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              if (trip.driver?.user != null) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundImage: trip.driver!.user!.profilePhotoUrl != null
                      ? NetworkImage(trip.driver!.user!.profilePhotoUrl!)
                      : null,
                  child: trip.driver!.user!.profilePhotoUrl == null
                      ? Text(
                          trip.driver!.user!.fullName.isNotEmpty
                              ? trip.driver!.user!.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.driver!.user!.fullName,
                    style: interBaseStyle.copyWith(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              Text(
                formatFare(fare),
                style: interBaseStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// EMPTY STATE
// ==================================================================

class _NoTripsEmptyState extends StatelessWidget {
  const _NoTripsEmptyState({
    required this.syneBaseStyle,
    required this.interBaseStyle,
    required this.onStartRide,
  });

  final TextStyle syneBaseStyle;
  final TextStyle interBaseStyle;
  final VoidCallback onStartRide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFF2ED47A).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: Color(0xFF2ED47A),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No trip history",
            style: syneBaseStyle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your ride history is empty.\nTime to book your first adventure!",
            textAlign: TextAlign.center,
            style: interBaseStyle.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onSurface,
                foregroundColor: colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Start a Ride",
                    style: interBaseStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.add, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
