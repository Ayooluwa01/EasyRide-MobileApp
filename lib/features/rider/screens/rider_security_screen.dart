import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderSecuritySettings extends StatelessWidget {
  const RiderSecuritySettings({super.key});

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
    final interBaseStyle = GoogleFonts.inter();

    final secureBannerBg = isDark
        ? const Color(0xFF2ED47A).withValues(alpha: 0.14)
        : const Color(0xFFDDF5E6);
    const secureBannerText = Color(0xFF2ED47A);
    final sectionLabelColor = colorScheme.onSurface.withValues(alpha: 0.5);

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
                    "Security",
                    style: syneBaseStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Account is secure banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: secureBannerBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surface : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: secureBannerText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account is secure",
                          style: interBaseStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "LAST CHECKED TODAY",
                          style: interBaseStyle.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: secureBannerText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Login & Security
              _SectionLabel(
                "LOGIN & SECURITY",
                color: sectionLabelColor,
                style: interBaseStyle,
              ),
              const SizedBox(height: 12),

              _SecurityTile(
                icon: Icons.key_outlined,
                title: "Change Password",
                subtitle: "Last changed 3 months ago",
                onTap: () {
                  // TODO: navigate to change-password flow
                },
              ),
              const SizedBox(height: 12),
              _SecurityTile(
                icon: Icons.phone_iphone_outlined,
                title: "Two-Factor Auth",
                subtitle: "Extra layer of security",
                trailing: _StatusPill(
                  label: "ENABLED",
                  style: interBaseStyle,
                  background: secureBannerBg,
                  textColor: secureBannerText,
                ),
                onTap: () {
                  // TODO: navigate to 2FA settings
                },
              ),

              const SizedBox(height: 28),

              // Data & Privacy
              _SectionLabel(
                "DATA & PRIVACY",
                color: sectionLabelColor,
                style: interBaseStyle,
              ),
              const SizedBox(height: 12),

              _SecurityTile(
                icon: Icons.person_outline,
                title: "Privacy Center",
                onTap: () {
                  // TODO: navigate to privacy center
                },
              ),
              const SizedBox(height: 12),
              _SecurityTile(
                icon: Icons.download_outlined,
                title: "Download My Data",
                onTap: () {
                  // TODO: trigger data export
                },
              ),

              const SizedBox(height: 28),

              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFE53E3E).withValues(alpha: 0.14)
                        : const Color(0xFFFDE7E7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Color(0xFFE53E3E),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Delete Account",
                          style: interBaseStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE53E3E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
  const _SectionLabel(this.text, {required this.style, required this.color});

  final String text;
  final TextStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: color,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.style,
    required this.background,
    required this.textColor,
  });

  final String label;
  final TextStyle style;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: style.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: textColor,
        ),
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final interBaseStyle = GoogleFonts.inter();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: interBaseStyle.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }
}
