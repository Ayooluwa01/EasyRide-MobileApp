import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _isOnline = false;

  void _toggleOnline(bool value) {
    setState(() => _isOnline = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final syneBaseStyle = GoogleFonts.syne(height: 1.15);
    final interBaseStyle = GoogleFonts.inter();

    const driverName = 'John';
    const driverPhotoUrl = null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // GREETING
              // ==========================================================
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: interBaseStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          driverName,
                          style: syneBaseStyle.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AvatarWithStatusDot(
                    name: driverName,
                    imageUrl: driverPhotoUrl,
                    isOnline: _isOnline,
                    colorScheme: colorScheme,
                    scaffoldBg: theme.scaffoldBackgroundColor,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==========================================================
              // ONLINE / OFFLINE  CARD
              // ==========================================================
              _OnlineStatusHero(
                isOnline: _isOnline,
                onToggle: _toggleOnline,
                colorScheme: colorScheme,
                isDark: isDark,
                syneBaseStyle: syneBaseStyle,
                interBaseStyle: interBaseStyle,
              ),

              const SizedBox(height: 28),

              // ==========================================================
              // TODAY'S STATS
              // ==========================================================
              Text(
                "TODAY'S SUMMARY",
                style: interBaseStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Earnings',
                      value: '₦0',
                      accent: const Color(0xFF2ED47A),
                      colorScheme: colorScheme,
                      isDark: isDark,
                      syneBaseStyle: syneBaseStyle,
                      interBaseStyle: interBaseStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_taxi_rounded,
                      label: 'Trips',
                      value: '0',
                      accent: const Color(0xFF5B8DEF),
                      colorScheme: colorScheme,
                      isDark: isDark,
                      syneBaseStyle: syneBaseStyle,
                      interBaseStyle: interBaseStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Expanded(
                  //   child: _StatCard(
                  //     icon: Icons.star_rounded,
                  //     label: 'Rating',
                  //     value: '—',
                  //     accent: const Color(0xFFFFB020),
                  //     colorScheme: colorScheme,
                  //     isDark: isDark,
                  //     syneBaseStyle: syneBaseStyle,
                  //     interBaseStyle: interBaseStyle,
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 28),

              // ==========================================================
              // RIDE OFFERS
              // ==========================================================
              Text(
                'RIDE OFFERS',
                style: interBaseStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 12),
              if (!_isOnline)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 42,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You are offline',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Go online to start receiving ride requests.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_isOnline)
                _RideOffers(
                  key: const ValueKey('ride_offer_1'),
                  colorScheme: colorScheme,
                  isDark: isDark,
                  isOnline: _isOnline,
                  fare: '5000',
                  pickup: 'Lekki Phase 1',
                  dropoff: 'Ajah, Lagos',
                  etaMinutes: '3 mins',
                  distanceKm: '6.2 km',
                  onAccept: () {},
                  onReject: () {},
                ),

              // Row(
              //   children: [
              //     Expanded(
              //       child: _QuickActionCard(
              //         icon: Icons.receipt_long_rounded,
              //         label: 'Trip history',
              //         accent: const Color(0xFF9B6BFF),
              //         colorScheme: colorScheme,
              //         isDark: isDark,
              //         interBaseStyle: interBaseStyle,
              //         onTap: () {},
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: _QuickActionCard(
              //         icon: Icons.account_balance_rounded,
              //         label: 'Payouts',
              //         accent: const Color(0xFF2ED47A),
              //         colorScheme: colorScheme,
              //         isDark: isDark,
              //         interBaseStyle: interBaseStyle,
              //         onTap: () {},
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }
}

// ==================================================================
// AVATAR WITH STATUS DOT
// ==================================================================

class _AvatarWithStatusDot extends StatelessWidget {
  const _AvatarWithStatusDot({
    required this.name,
    required this.imageUrl,
    required this.isOnline,
    required this.colorScheme,
    required this.scaffoldBg,
  });

  final String name;
  final String? imageUrl;
  final bool isOnline;
  final ColorScheme colorScheme;
  final Color scaffoldBg;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isOnline
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.15),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: colorScheme.primary,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF2ED47A)
                  : colorScheme.onSurface.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: scaffoldBg, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// ONLINE STATUS HERO CARD
// ==================================================================

class _OnlineStatusHero extends StatelessWidget {
  const _OnlineStatusHero({
    required this.isOnline,
    required this.onToggle,
    required this.colorScheme,
    required this.isDark,
    required this.syneBaseStyle,
    required this.interBaseStyle,
  });

  final bool isOnline;
  final ValueChanged<bool> onToggle;
  final ColorScheme colorScheme;
  final bool isDark;
  final TextStyle syneBaseStyle;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isOnline
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.75),
                ],
              )
            : null,
        color: isOnline ? null : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: isOnline
            ? null
            : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: isOnline
                ? colorScheme.primary.withValues(alpha: 0.35)
                : (isDark
                      ? Colors.transparent
                      : Colors.black.withValues(alpha: 0.04)),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? 'LIVE' : 'OFFLINE',
                style: interBaseStyle.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: isOnline
                      ? Colors.white.withValues(alpha: 0.9)
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isOnline ? "You're online" : "You're offline",
            style: syneBaseStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isOnline ? Colors.white : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isOnline
                ? 'Ride requests will come through now'
                : 'Go online to start receiving ride requests',
            style: interBaseStyle.copyWith(
              fontSize: 13,
              color: isOnline
                  ? Colors.white.withValues(alpha: 0.85)
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => onToggle(!isOnline),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.white : colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    isOnline ? 'Go offline' : 'Go online',
                    style: interBaseStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isOnline
                          ? colorScheme.primary
                          : colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// STAT CARD
// ==================================================================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.colorScheme,
    required this.isDark,
    required this.syneBaseStyle,
    required this.interBaseStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final ColorScheme colorScheme;
  final bool isDark;
  final TextStyle syneBaseStyle;
  final TextStyle interBaseStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: interBaseStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: interBaseStyle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// QUICK ACTION CARD
// ==================================================================

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.accent,
    required this.colorScheme,
    required this.isDark,
    required this.interBaseStyle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final ColorScheme colorScheme;
  final bool isDark;
  final TextStyle interBaseStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: accent),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: interBaseStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
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
// RIDE OFFER CARD — swipe left to decline, tap button to accept
// ==================================================================

class _RideOffers extends StatefulWidget {
  final ColorScheme colorScheme;
  final bool isDark;
  final bool isOnline;
  final String fare;
  final String pickup;
  final String dropoff;
  final String etaMinutes;
  final String distanceKm;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _RideOffers({
    super.key,
    required this.colorScheme,
    required this.isDark,
    required this.isOnline,
    required this.fare,
    this.pickup = 'Lekki Phase 1',
    this.dropoff = 'Ajah, Lagos',
    this.etaMinutes = '3 mins',
    this.distanceKm = '6.2 km',
    this.onAccept,
    this.onReject,
  });

  @override
  State<_RideOffers> createState() => _RideOffersState();
}

class _RideOffersState extends State<_RideOffers> {
  late num _offer;
  late final TextEditingController _amountController;

  static const double _step = 200;

  @override
  void initState() {
    super.initState();
    _offer = num.tryParse(widget.fare) ?? 0;
    _amountController = TextEditingController(text: _formatOffer(_offer));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatOffer(num value) {
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      buffer.write(s[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  void _adjustOffer(double delta) {
    setState(() {
      _offer = math.max(0, _offer + delta);
      _amountController.text = _formatOffer(_offer);
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final isDark = widget.isDark;
    final isOnline = widget.isOnline;
    final cardBg = isDark ? colorScheme.surface : Colors.white;

    return Dismissible(
      key: widget.key ?? const ValueKey('ride_offer_card'),
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
            // Header: new-offer badge + fare badge
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
                      '₦${_formatOffer(num.tryParse(widget.fare) ?? 0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
                          'From ${widget.pickup}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'To ${widget.dropoff}',
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

            const SizedBox(height: 16),

            // ------------------------------------------
            // Distance / time chips
            // ------------------------------------------
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 18),
            //   child: Row(
            //     children: [
            //       _InfoChip(
            //         icon: Icons.access_time_rounded,
            //         label: widget.etaMinutes,
            //         colorScheme: colorScheme,
            //       ),
            //       const SizedBox(width: 8),
            //       _InfoChip(
            //         icon: Icons.map_rounded,
            //         label: widget.distanceKm,
            //         colorScheme: colorScheme,
            //       ),
            //     ],
            //   ),
            // ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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

// ==================================================================
// REJECT SWIPE BACKGROUND
// ==================================================================

class _RejectSwipeBackground extends StatelessWidget {
  const _RejectSwipeBackground({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 26),
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
