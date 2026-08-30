import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        separatorBuilder: (_, __) => Divider(
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

class RequestRideTripSummaryCard extends StatelessWidget {
  const RequestRideTripSummaryCard({
    super.key,
    required this.isDark,
    required this.colorScheme,
    required this.destination,
    required this.routeInfo,
    required this.isLoading,
    required this.onConfirm,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final RideDestination destination;
  final RouteInfo? routeInfo;
  final bool isLoading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      destination.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              else if (routeInfo != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      routeInfo!.distanceLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      routeInfo!.durationLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
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
