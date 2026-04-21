import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim/core/theme/colors_manager.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  bool isPlaying = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.blackColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/taj.png',
              fit: BoxFit.cover,
              color: Colors.black.withAlpha(153),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                const Text(
                  'إذاعة القرآن الكريم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Amiri',
                  ),
                ),
                const SizedBox(height: 60),
                // Radio Image SVG
                Center(
                  child: SvgPicture.asset(
                    'assets/icons/radio.svg',
                    height: 200,
                    colorFilter: ColorFilter.mode(ColorsManager.goldColor, BlendMode.srcIn),
                  ),
                ),
                const Spacer(),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: ColorsManager.goldColor),
                      iconSize: 48,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsManager.goldColor,
                          boxShadow: [
                            BoxShadow(
                              color: ColorsManager.goldColor.withAlpha(100),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: ColorsManager.blackColor,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.skip_next, color: ColorsManager.goldColor),
                      iconSize: 48,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 80),
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
