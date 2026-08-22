import 'package:easy_ride/features/rider/screens/rider_chat_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_home_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_profile_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_trip_screen.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  static const Color activeGreen = Color(0xFF22C55E);
  static const Color activeText = Color(0xFF111827);
  static const Color inactiveGrey = Color(0xFF9CA3AF);

  final List<Widget> _screens = const [
    RiderHomeScreen(),
    RiderChatScreen(),
    RiderTripScreen(),
    RiderProfileScreen(),
  ];

  final List<_NavItemData> _items = const [
    _NavItemData(icon: Icons.home_rounded, label: 'Home'),
    _NavItemData(icon: Icons.chat_bubble_rounded, label: 'Chats'),
    _NavItemData(icon: Icons.history_rounded, label: 'Trips'),
    _NavItemData(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
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
                  onTap: () => setState(() => _currentIndex = index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? activeGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _items[index].icon,
                          size: 22,
                          color: index == _currentIndex
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
                          fontWeight: index == _currentIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: index == _currentIndex
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
