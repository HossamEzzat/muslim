import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim/core/theme/colors_manager.dart';

import 'package:muslim/features/quran/presentation/screens/quran_screen.dart';
import 'package:muslim/features/hadith/presentation/screens/hadith_screen.dart';
import 'package:muslim/features/tasbih/presentation/screens/tasbih_screen.dart';
import 'package:muslim/features/radio/presentation/screens/radio_screen.dart';
import 'package:muslim/features/stats/presentation/screens/stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    QuranScreen(),
    const HadithScreen(),
    const TasbihScreen(),
    const RadioScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      _NavItem(iconPath: 'assets/icons/quran.svg', label: 'القرآن'),
      _NavItem(iconPath: 'assets/icons/hadith.svg', label: 'الحديث'),
      _NavItem(iconPath: 'assets/icons/tasbih.svg', label: 'التسبيح'),
      _NavItem(iconPath: 'assets/icons/radio.svg', label: 'الراديو'),
      _NavItem(iconPath: 'assets/icons/stat.svg', label: 'الإحصائيات'),
    ];

    return Container(
      color: ColorsManager.goldColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: isSelected
                    ? BoxDecoration(
                        color: ColorsManager.greyColor,
                        borderRadius: BorderRadius.circular(24),
                      )
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      items[index].iconPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : ColorsManager.blackColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Text(
                        items[index].label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final String iconPath;
  final String label;
  const _NavItem({required this.iconPath, required this.label});
}
