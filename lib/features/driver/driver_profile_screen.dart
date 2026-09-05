import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/user_controller.dart';
import 'package:easy_ride/app/shared/number_formatter.dart';
import 'package:easy_ride/app/shared/storage_keys.dart';
import 'package:easy_ride/app/theme/theme_provider.dart';
import 'package:easy_ride/core/widgets/option_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  ConsumerState<DriverProfileScreen> createState() =>
      _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  bool _biometricsEnabled = false;

  // TODO: replace with a real provider watching the driver's wallet balance
  num _walletBalance = 12500;

  Future<void> _openTopUpSheet() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showModalBottomSheet<num>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _TopUpSheet(colorScheme: colorScheme, isDark: isDark),
    );

    if (result != null && result > 0) {
      // TODO: call your top-up API here, then refresh the real balance
      setState(() => _walletBalance += result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(currentUserProvider);
    final user = loginState.value;
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);

    final isDarkMode = themeMode == ThemeMode.dark;

    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final syneBaseStyle = GoogleFonts.syne(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );
    final dividerColor = colorScheme.onSurface.withValues(alpha: 0.08);
    final mutedTextColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(children: [const SizedBox(width: 30)]),
              const SizedBox(height: 34),

              Align(
                alignment: AlignmentGeometry.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(22),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://i.pravatar.cc/150?img=32',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            user?.fullName ?? '',
                            style: syneBaseStyle.copyWith(
                              fontSize: 20,

                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Center(
                          child: Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: Color(0xFF4CAF50),
                                ),
                                const SizedBox(width: 4),
                                Center(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    user?.role ?? '',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                      letterSpacing: 0.5,
                                    ),
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
              ),

              const SizedBox(height: 24),

              // ==========================================================
              // WALLET BALANCE
              // ==========================================================
              _WalletCard(
                balance: _walletBalance,
                colorScheme: colorScheme,
                isDark: isDark,
                onTopUp: _openTopUpSheet,
              ),

              const SizedBox(height: 24),

              // ACCOUNT SECTION
              _SectionHeader(title: "ACCOUNT", color: mutedTextColor),

              _SettingsGroupCard(
                colorScheme: colorScheme,
                isDark: isDark,
                children: [
                  OptionTile(
                    icon: Icons.person_outline_rounded,
                    label: "Personal Information",
                    onTap: () {
                      context.push(RouteNames.personalprofile);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: dividerColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: "PREFERENCES", color: mutedTextColor),
              _SettingsGroupCard(
                colorScheme: colorScheme,
                isDark: isDark,
                children: [
                  OptionTile(
                    icon: Icons.notifications_none_rounded,
                    label: "Notifications",
                    onTap: () {
                      context.push(RouteNames.notification);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: dividerColor,
                  ),
                  OptionTile(
                    icon: Icons.shield_outlined,
                    label: "Privacy & Security",
                    onTap: () {
                      context.push(RouteNames.ridersecurity);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: dividerColor,
                  ),
                  OptionTile(
                    icon: Icons.dark_mode_outlined,
                    label: "Dark Mode",
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (_) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF2ED47A),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: colorScheme.onSurface.withValues(
                        alpha: 0.2,
                      ),
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: dividerColor,
                  ),
                  OptionTile(
                    icon: Icons.fingerprint_rounded,
                    label: "Biometric Login",
                    trailing: Switch(
                      value: _biometricsEnabled,
                      onChanged: (v) {
                        setState(() => _biometricsEnabled = v);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF2ED47A),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: colorScheme.onSurface.withValues(
                        alpha: 0.2,
                      ),
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: "SUPPORT", color: mutedTextColor),
              _SettingsGroupCard(
                colorScheme: colorScheme,
                isDark: isDark,
                children: [
                  OptionTile(
                    icon: Icons.help_outline_rounded,
                    label: "Help Center",
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: dividerColor,
                  ),
                  OptionTile(
                    icon: Icons.info_outline_rounded,
                    label: "About EasyRide",
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SIGN OUT
              _SignOutButton(
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// WALLET CARD
// ==================================================================

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.balance,
    required this.colorScheme,
    required this.isDark,
    required this.onTopUp,
  });

  final num balance;
  final ColorScheme colorScheme;
  final bool isDark;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'WALLET BALANCE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatFare(balance),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onTopUp,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Top up',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
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
// TOP UP SHEET
// ==================================================================

class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet({required this.colorScheme, required this.isDark});

  final ColorScheme colorScheme;
  final bool isDark;

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  static const List<num> _quickAmounts = [1000, 2000, 5000, 10000];

  final TextEditingController _amountController = TextEditingController();
  num? _selectedQuickAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(num amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  num? get _enteredAmount =>
      num.tryParse(_amountController.text.replaceAll(',', ''));

  void _confirm() {
    final amount = _enteredAmount;
    if (amount == null || amount <= 0) return;
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final isDark = widget.isDark;
    final amount = _enteredAmount;
    final isValid = amount != null && amount > 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Text(
              'Top up wallet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose an amount or enter a custom one',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------
            // Amount input
            // ------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() => _selectedQuickAmount = null),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  prefixText: '₦ ',
                  prefixStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                  hintText: '0',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ------------------------------------------
            // Quick amounts
            // ------------------------------------------
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _quickAmounts.map((quickAmount) {
                final isSelected = _selectedQuickAmount == quickAmount;
                return GestureDetector(
                  onTap: () => _selectQuickAmount(quickAmount),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.14)
                          : colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      formatFare(quickAmount),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isValid ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: colorScheme.onSurface.withValues(
                    alpha: 0.1,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isValid ? 'Top up ${formatFare(amount)}' : 'Enter an amount',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: AlignmentGeometry.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;
  final ColorScheme colorScheme;
  final bool isDark;

  const _SettingsGroupCard({
    required this.children,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }
}

// Sign Out Button (rounded card, red label + icon)
class _SignOutButton extends StatelessWidget {
  final VoidCallback? onTap;
  final ColorScheme colorScheme;
  final bool isDark;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  const _SignOutButton({
    this.onTap,
    required this.colorScheme,
    required this.isDark,
  });

  void _signout() async {
    await secureStorage.delete(key: StorageKeys.accessToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _signout,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.transparent
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 16, color: Color(0xFFE53935)),
                SizedBox(width: 8),
                Text(
                  "Sign Out",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
