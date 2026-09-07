import 'package:easy_ride/app/models/ride_offer_model.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/ride_history.dart';
import 'package:easy_ride/app/services/ride_offer_provider.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/app/shared/ride_offer_card.dart';
import 'package:easy_ride/core/controllers/active_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
      // ref.read(rideHistoryProvider.notifier).getUserTrips();
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
    final websocket = ref.watch(activeRideProvider);
    final status = websocket?['status'];
    print('ride offer status $status');
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
    AsyncValue tripsState,
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

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: trips.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            // return _TripHistoryCard(
            //   trip: trips[index],
            //   interBaseStyle: interBaseStyle,
            // );
            return const SizedBox.shrink();
          },
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
