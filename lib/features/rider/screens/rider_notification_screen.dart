import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderNotificationSettings extends StatefulWidget {
  const RiderNotificationSettings({super.key});

  @override
  State<RiderNotificationSettings> createState() =>
      _RiderNotificationSettingsState();
}

class _RiderNotificationSettingsState extends State<RiderNotificationSettings> {
  bool _rideUpdates = true;
  bool _promotions = true;
  bool _messages = true;
  bool _rideReceipts = true;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) context.pop();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Notifications",
                    style: syneBaseStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Push notifications
              _SectionLabel("PUSH NOTIFICATIONS", style: interBaseStyle),
              const SizedBox(height: 12),

              _NotificationTile(
                icon: Icons.directions_car_filled_outlined,
                title: "Ride Updates",
                subtitle: "Arrived, started, finished",
                value: _rideUpdates,
                onChanged: (v) => setState(() => _rideUpdates = v),
              ),
              const SizedBox(height: 12),
              _NotificationTile(
                icon: Icons.local_offer_outlined,
                title: "Promotions",
                subtitle: "Discounts and offers",
                value: _promotions,
                onChanged: (v) => setState(() => _promotions = v),
              ),
              const SizedBox(height: 12),
              _NotificationTile(
                icon: Icons.chat_bubble_outline,
                title: "Messages",
                subtitle: "New chat from driver",
                value: _messages,
                onChanged: (v) => setState(() => _messages = v),
              ),

              const SizedBox(height: 28),

              // Email notifications
              _SectionLabel("EMAIL NOTIFICATIONS", style: interBaseStyle),
              const SizedBox(height: 12),

              _NotificationTile(
                icon: Icons.receipt_long_outlined,
                title: "Ride Receipts",
                subtitle: "Sent after every trip",
                value: _rideReceipts,
                onChanged: (v) => setState(() => _rideReceipts = v),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      text,
      style: style.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final interBaseStyle = GoogleFonts.inter();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.onSurface.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: interBaseStyle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: interBaseStyle.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF2ED47A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.2),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
