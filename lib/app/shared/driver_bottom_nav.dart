import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DriverBottomNav({super.key, required this.navigationShell});

  static const Color activeGreen = Color(0xFF22C55E);
  static const Color activeText = Color(0xFF111827);
  static const Color inactiveGrey = Color(0xFF9CA3AF);

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_rounded, label: 'Home'),
    _NavItemData(icon: Icons.history_rounded, label: 'Rides'),
    _NavItemData(icon: Icons.chat_bubble_rounded, label: 'Chats'),
    _NavItemData(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildNavBar(context, currentIndex),
    );
  }

  Widget _buildNavBar(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int index = 0; index < _items.length; index++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => navigationShell.goBranch(
                    index,
                    initialLocation: index == currentIndex,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: index == currentIndex
                              ? activeGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _items[index].icon,
                          size: 22,
                          color: index == currentIndex
                              ? Colors.black
                              : inactiveGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _items[index].label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.5,
                          fontWeight: index == currentIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: index == currentIndex
                              ? activeText
                              : inactiveGrey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}
