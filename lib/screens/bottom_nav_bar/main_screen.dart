import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim/core/colors_manager.dart';

import '../../features/quran/presentation/screens/quran_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    QuranScreen(),
    const Center(child: Text('Hadith')),
    const Center(child: Text('Tasbih')),
    const Center(child: Text('Radio')),
    const Center(child: Text('Stats')),
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
      _NavItem(iconPath: 'assets/quran.svg', label: 'Quran'),
      _NavItem(iconPath: 'assets/hadith.svg', label: 'Hadith'),
      _NavItem(iconPath: 'assets/tasbih.svg', label: 'Tasbih'),
      _NavItem(iconPath: 'assets/radio.svg', label: 'Radio'),
      _NavItem(iconPath: 'assets/stat.svg', label: 'Stats'),
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
