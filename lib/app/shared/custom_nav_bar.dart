import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected) {
    final Color activeColor = item.activeColorPrimary;
    final Color inactiveColor = item.inactiveColorPrimary ?? Colors.grey;

    return Container(
      alignment: Alignment.center,
      height: 60.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: IconTheme(
              data: IconThemeData(
                size: 24.0,
                color: isSelected ? Colors.white : inactiveColor,
              ),
              child: item.icon,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            item.title ?? '',
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 11.0,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: 68.0,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.map((item) {
            final int index = items.indexOf(item);
            return Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onItemSelected(index),
                child: _buildItem(item, selectedIndex == index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
