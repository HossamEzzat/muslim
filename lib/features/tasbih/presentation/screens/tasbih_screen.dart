import 'package:flutter/material.dart';
import 'package:muslim/core/theme/colors_manager.dart';
import 'dart:math' as math;

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _phraseIndex = 0;
  double _turns = 0.0;

  final List<String> _phrases = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
  ];

  void _increment() {
    setState(() {
      _counter++;
      // Rotate the sebha a small fraction per click
      _turns += 1 / 33;

      if (_counter >= 33) {
        _counter = 0;
        _phraseIndex = (_phraseIndex + 1) % _phrases.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.blackColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                const Text(
                  'سَبِّحِ اسْمَ رَبِّكَ الأعْلَى',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri', // Or a custom premium font
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _increment,
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Sebha Layout with separate Head and Body
                          Positioned(
                            top: 0,
                            bottom: 80, // Adjust position to link head and body
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Static Head
                                Image.asset(
                                  'assets/sebha/head_sebha.png',
                                  height: 100,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(height: 100),
                                ),
                                // Rotating Body
                                AnimatedRotation(
                                  turns: _turns,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  child: Image.asset(
                                    'assets/sebha/body_sebha.png',
                                    width: 320,
                                    height: 320,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/images/quran_sura.png',
                                      width: 320,
                                      height: 320,
                                      color: ColorsManager.goldColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Inner Text centered inside the beads!
                          Positioned(
                            top: 240, // Position text inside the circle
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _phrases[_phraseIndex],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Amiri',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_counter',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Image.asset('assets/images/logo.png', height: 80),
    );
  }
}
