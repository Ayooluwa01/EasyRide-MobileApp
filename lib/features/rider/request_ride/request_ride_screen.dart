import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:easy_ride/app/models/mapbox_location_model.dart';
import 'package:easy_ride/app/models/request_ride_model.dart';
import 'package:easy_ride/app/services/request_ride.dart';
import 'package:easy_ride/app/services/route_service.dart';
import 'package:easy_ride/app/services/suggestions_service.dart';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:easy_ride/features/rider/request_ride/request_ride_models.dart';
import 'package:easy_ride/features/rider/request_ride/request_ride_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
part 'request_ride_logic.dart';

class RequestRideScreen extends ConsumerStatefulWidget {
  const RequestRideScreen({super.key});

  @override
  ConsumerState<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends ConsumerState<RequestRideScreen> {
  MapboxMap? _mapboxController;
  CircleAnnotationManager? _pickupAnnotationManager;
  CircleAnnotationManager? _destAnnotationManager;

  static const String _routeSourceId = 'route-line-source';
  static const String _routeCasingLayerId = 'route-line-casing';
  static const String _routeLineLayerId = 'route-line-layer';
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _destinationFocusNode.unfocus(),
        child: Stack(
          children: [
            MapWidget(
              key: const ValueKey('request_ride_map'),
              styleUri: isDark
                  ? MapboxStyles.DARK
                  : MapboxStyles.MAPBOX_STREETS,
              onMapCreated: _onMapCreated,
            ),

            // Back button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: RequestRideIconButton(
                  icon: Icons.arrow_back_rounded,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onTap: () => Navigator.of(context).pop(),
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

              // Trip summary
              if (_selectedDestination != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: RequestRideTripSummaryCard(
                      isDark: isDark,
                      colorScheme: colorScheme,
                      destination: _selectedDestination!,
                      routeInfo: _routeInfo,
                      isLoading: _isRoutingLoading || _isConfirmingRide,
                      onConfirm: _confirmRide,
                    ),
                  ),
                ),
            ] else ...[
              // Searching for nearby drivers: radar pulses over the map,
              // and the drivers panel sits fixed at the bottom. This
              // replaces (not stacks on top of) the search UI above.
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
                    count: _nearbyDriversCount,
                    drivers: const [],
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
