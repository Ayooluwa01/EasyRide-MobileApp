import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:easy_ride/app/models/mapbox_location_model.dart';
import 'package:easy_ride/app/models/request_ride_model.dart';
import 'package:easy_ride/app/services/request_ride.dart';
import 'package:easy_ride/app/services/route_service.dart';
import 'package:easy_ride/app/services/suggestions_service.dart';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:easy_ride/core/controllers/driver_offers.dart';
import 'package:easy_ride/core/controllers/nearby_drivers.dart';
import 'package:easy_ride/features/rider/request_ride/request_ride_models.dart';
import 'package:easy_ride/features/rider/request_ride/request_ride_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
part 'request_ride_logic.dart';

class RequestRideScreen extends ConsumerStatefulWidget {
  const RequestRideScreen({super.key});

  @override
  ConsumerState<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends ConsumerState<RequestRideScreen> {
  GoogleMapController? _mapController;

  final Set<Marker> _pickupMarkers = {};
  final Set<Marker> _destMarkers = {};
  final Set<Marker> _driverMarkers = {};
  Set<Polyline> _routePolylines = {};
  bool _hasRouteLayer = false;

  bool _searchNearbyDrivers = false;
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();
  Timer? _debounceTimer;
  int _searchRequestId = 0;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;

  RideDestination? _selectedDestination;
  RouteInfo? _routeInfo;
  bool _isRoutingLoading = false;
  bool _isConfirmingRide = false;
  String? _rideId;
  int _nearbyDriversCount = 0;
  final Map<String, Marker> _driverAnnotations = {};
  PaymentMethod _selectedPaymentMethod = PaymentMethod.CASH;
  String _pickupAddress = '';
  String _sessionToken = DateTime.now().microsecondsSinceEpoch.toString();

  static const double _fallbackLat = 6.5244;
  static const double _fallbackLng = 3.3792;

  @override
  void dispose() {
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  ({double lat, double lng}) get _pickupLatLng {
    final userLatLng = ref.read(userLatLngProvider);
    return (
      lat: userLatLng?.latitude ?? _fallbackLat,
      lng: userLatLng?.longitude ?? _fallbackLng,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final pickup = _pickupLatLng;

    ref.listen<dynamic>(nearbyDriversProvider, (previous, next) {
      final driverList =
          (next is Map ? next['drivers'] as List<dynamic>? : null) ?? [];
      unawaited(_updateDriverMarkers(driverList));
    });

    final nearbyDrivers = ref.watch(nearbyDriversProvider);
    final drivers =
        (nearbyDrivers is Map
            ? nearbyDrivers['drivers'] as List<dynamic>?
            : null) ??
        [];
    final count = drivers.length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _destinationFocusNode.unfocus(),
        child: Stack(
          children: [
            GoogleMap(
              key: const ValueKey('request_ride_map'),
              initialCameraPosition: CameraPosition(
                target: LatLng(pickup.lat, pickup.lng),
                zoom: 15,
              ),
              markers: {..._pickupMarkers, ..._destMarkers, ..._driverMarkers},
              polylines: _routePolylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: RequestRideIconButton(
                  icon: Icons.arrow_back_rounded,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onTap: () {
                    ref.read(driverOfferProvider.notifier).clearOffers();
                    context.pop();
                  },
                ),
              ),
            ),

            if (!_searchNearbyDrivers) ...[
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 64, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RequestRideSearchPanel(
                        isDark: isDark,
                        colorScheme: colorScheme,
                        destinationController: _destinationController,
                        destinationFocusNode: _destinationFocusNode,
                        isSearching: _isSearching,
                        hasDestination: _selectedDestination != null,
                        onChanged: _onDestinationChanged,
                        onClear: _clearDestination,
                      ),
                      if (_suggestions.isNotEmpty)
                        RequestRideSuggestionsList(
                          isDark: isDark,
                          colorScheme: colorScheme,
                          suggestions: _suggestions,
                          onSelect: _selectSuggestion,
                        ),
                    ],
                  ),
                ),
              ),

              if (_selectedDestination != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Column(
                      children: [
                        RequestRideTripSummaryCard(
                          isDark: isDark,
                          colorScheme: colorScheme,
                          destination: _selectedDestination!,
                          routeInfo: _routeInfo,
                          isLoading: _isRoutingLoading || _isConfirmingRide,
                          onConfirm: (offeredFare) => _confirmRide(offeredFare),
                          paymentSelector: Row(
                            children: [
                              Expanded(
                                child: paymentCard(
                                  method: PaymentMethod.CASH,
                                  title: 'Cash',
                                  subtitle: 'Pay driver directly',
                                  icon: Icons.payments_outlined,
                                  theme: theme,
                                  colorScheme: colorScheme,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: paymentCard(
                                  method: PaymentMethod.TRANSFER,
                                  title: 'Transfer',
                                  subtitle: 'Pay via bank transfer',
                                  icon: Icons.account_balance_outlined,
                                  theme: theme,
                                  colorScheme: colorScheme,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: RequestRideSearchingRadar(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: AvailableDrivers(
                    isDark: isDark,
                    colorScheme: colorScheme,
                    count: count,
                    drivers: drivers,
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
