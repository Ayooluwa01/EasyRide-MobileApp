import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/core/widgets/option_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syneBaseStyle = GoogleFonts.syne(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                children: [
                  // IconButton(
                  //   onPressed: () {},
                  //   padding: EdgeInsets.zero,
                  //   constraints: const BoxConstraints(),
                  //   icon: Icon(
                  //     Icons.arrow_back_ios_new_rounded,
                  //     color: colorScheme.onSurface,
                  //     size: 18,
                  //   ),
                  // ),
                  // Expanded(
                  //   child: Text(
                  //     "Settings",
                  //     textAlign: TextAlign.center,
                  //     style: syneBaseStyle.copyWith(
                  //       fontSize: 22,
                  //       fontWeight: FontWeight.w800,
                  //     ),
                  //   ),
                  // ),
                  // Balances the leading back button so the title stays centered
                  const SizedBox(width: 30),
                ],
              ),
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
                                color: Colors.white,
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
                          "Amaka Obi",
                          style: syneBaseStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'amaka.obi@email.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
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
              const _SectionHeader(title: "ACCOUNT"),
              _SettingsGroupCard(
                children: [
                  OptionTile(
                    icon: Icons.person_outline_rounded,
                    label: "Personal Information",
                    onTap: () {
                      context.push(RouteNames.riderpersonalprofile);
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: Color.fromARGB(26, 204, 201, 201),
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
              const _SectionHeader(title: "PREFERENCES"),
              _SettingsGroupCard(
                children: [
                  OptionTile(
                    icon: Icons.notifications_none_rounded,
                    label: "Notifications",
                    onTap: () {
                      context.push(RouteNames.ridernotification);
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: Color.fromARGB(26, 204, 201, 201),
                  ),
                  OptionTile(
                    icon: Icons.shield_outlined,
                    label: "Privacy & Security",
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SUPPORT SECTION
              const _SectionHeader(title: "SUPPORT"),
              _SettingsGroupCard(
                children: [
                  OptionTile(
                    icon: Icons.help_outline_rounded,
                    label: "Help Center",
                    onTap: () {},
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 48,
                    color: Color.fromARGB(26, 204, 201, 201),
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
              _SignOutButton(onTap: () {}),
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

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9E9E9E),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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

// Reusable Tile Widget

// Sign Out Button (rounded white card, red label + icon)
class _SignOutButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SignOutButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
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
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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
