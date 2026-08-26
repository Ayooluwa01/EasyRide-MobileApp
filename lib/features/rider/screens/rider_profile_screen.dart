import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/theme/theme_provider.dart';
import 'package:easy_ride/core/widgets/option_tile.dart';
import 'package:easy_ride/features/auth/controllers/login_controller.dart';
import 'package:easy_ride/features/auth/state/auth.state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderProfileScreen extends ConsumerStatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  ConsumerState<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends ConsumerState<RiderProfileScreen> {
  bool _biometricsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final syneBaseStyle = GoogleFonts.syne(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );

    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final loginState = ref.watch(loginControllerProvider);
    final user = loginState.value?.data.user;
    final dividerColor = colorScheme.onSurface.withValues(alpha: 0.08);
    final mutedTextColor = colorScheme.onSurface.withValues(alpha: 0.6);
    final chevronColor = colorScheme.onSurface.withValues(alpha: 0.4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(children: [const SizedBox(width: 30)]),
              const SizedBox(height: 34),

              // Profile Header Section
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
                        Text(
                          user?.fullName ?? '',
                          style: syneBaseStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'amaka.obi@email.com',
                          style: TextStyle(fontSize: 13, color: mutedTextColor),
                        ),
                        const SizedBox(height: 6),
                        Container(
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
                            children: const [
                              Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 4),
                              Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  '4.98 RIDER',
                                  style: TextStyle(
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
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

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
                      context.push(RouteNames.riderpersonalprofile);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: dividerColor,
                  ),
                  OptionTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: "Payment Methods",
                    onTap: () {
                      context.push(RouteNames.riderpaymentinformation);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // PREFERENCES SECTION
              _SectionHeader(title: "PREFERENCES", color: mutedTextColor),
              _SettingsGroupCard(
                colorScheme: colorScheme,
                isDark: isDark,
                children: [
                  OptionTile(
                    icon: Icons.notifications_none_rounded,
                    label: "Notifications",
                    onTap: () {
                      context.push(RouteNames.ridernotification);
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

              // SUPPORT SECTION
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
                    label: "About GidiRide",
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.2,
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
              // Shadows read as noise on dark surfaces, so only cast
              // one in light mode.
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

  const _SignOutButton({
    this.onTap,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
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
