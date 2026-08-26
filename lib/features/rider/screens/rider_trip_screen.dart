import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderTripScreen extends StatefulWidget {
  const RiderTripScreen({super.key});

  @override
  State<RiderTripScreen> createState() => _RiderTripScreenState();
}

class _RiderTripScreenState extends State<RiderTripScreen> {
  bool _hasActiveTrip = false;
  bool _isActiveTabSelected = true;

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _hasActiveTrip ? "My Trips" : "Trips",
                    style: syneBaseStyle.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (!_hasActiveTrip)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),

                  if (true)
                    IconButton(
                      tooltip: 'Toggle demo state',
                      onPressed: () =>
                          setState(() => _hasActiveTrip = !_hasActiveTrip),
                      icon: Icon(
                        Icons.swap_horiz_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ),
                ],
              ),

              if (_hasActiveTrip) ...[
                const SizedBox(height: 20),
                _TripTabs(
                  isActiveSelected: _isActiveTabSelected,
                  onChanged: (isActive) =>
                      setState(() => _isActiveTabSelected = isActive),
                  interBaseStyle: interBaseStyle,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _isActiveTabSelected
                      ? _ActiveTripCard(
                          syneBaseStyle: syneBaseStyle,
                          interBaseStyle: interBaseStyle,
                        )
                      : _CompletedTripsPlaceholder(
                          interBaseStyle: interBaseStyle,
                        ),
                ),
              ] else
                Expanded(
                  child: _NoTripsEmptyState(
                    syneBaseStyle: syneBaseStyle,
                    interBaseStyle: interBaseStyle,
                    onStartRide: () {},
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Segmented Active/Completed tab control
class _TripTabs extends StatelessWidget {
  const _TripTabs({
    required this.isActiveSelected,
    required this.onChanged,
    required this.interBaseStyle,
  });

  final bool isActiveSelected;
  final ValueChanged<bool> onChanged;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabItem(
          label: "ACTIVE TRIP",
          isSelected: isActiveSelected,
          onTap: () => onChanged(true),
          interBaseStyle: interBaseStyle,
        ),
        const SizedBox(width: 24),
        _TabItem(
          label: "COMPLETED",
          isSelected: !isActiveSelected,
          onTap: () => onChanged(false),
          interBaseStyle: interBaseStyle,
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.interBaseStyle,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: interBaseStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected
                    ? const Color(0xFF2ED47A)
                    : colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: label.length * 6.5,
              color: isSelected ? const Color(0xFF2ED47A) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// Empty state
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
            "No trips yet",
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

// Active trip card
class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({
    required this.syneBaseStyle,
    required this.interBaseStyle,
  });

  final TextStyle syneBaseStyle;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LIVE STATUS",
                      style: interBaseStyle.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: const Color(0xFF2ED47A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Heading to\nDropoff",
                      style: syneBaseStyle.copyWith(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "ETA",
                    style: interBaseStyle.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "12 min",
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

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.55,
              minHeight: 4,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2ED47A)),
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _TripStat(
                  label: "DISTANCE LEFT",
                  value: "4.2 km",
                  interBaseStyle: interBaseStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TripStat(
                  label: "EST. FARE",
                  value: "₦2,450",
                  interBaseStyle: interBaseStyle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                // TODO: confirmation dialog + cancel-trip flow
              },
              style: TextButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFFE53E3E).withValues(alpha: 0.14)
                    : const Color(0xFFFDE7E7),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "CANCEL TRIP",
                style: interBaseStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: const Color(0xFFE53E3E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  const _TripStat({
    required this.label,
    required this.value,
    required this.interBaseStyle,
  });

  final String label;
  final String value;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.onSurface.withValues(alpha: 0.06)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: interBaseStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: interBaseStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedTripsPlaceholder extends StatelessWidget {
  const _CompletedTripsPlaceholder({required this.interBaseStyle});

  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        "No completed trips yet",
        style: interBaseStyle.copyWith(
          fontSize: 13,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
