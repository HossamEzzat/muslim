import 'package:flutter/material.dart';
import 'package:muslim/core/theme/colors_manager.dart';

import 'package:muslim/features/hadith/data/models/muslim_hadith_model.dart';

class MuslimHadithDetailScreen extends StatelessWidget {
  final MuslimHadithModel hadith;
  final List<MuslimHadithModel> allHadiths;
  final int initialIndex;

  const MuslimHadithDetailScreen({
    super.key,
    required this.hadith,
    required this.allHadiths,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return _MuslimHadithDetailView(
      allHadiths: allHadiths,
      initialIndex: initialIndex,
    );
  }
}

class _MuslimHadithDetailView extends StatefulWidget {
  final List<MuslimHadithModel> allHadiths;
  final int initialIndex;

  const _MuslimHadithDetailView({
    required this.allHadiths,
    required this.initialIndex,
  });

  @override
  State<_MuslimHadithDetailView> createState() =>
      _MuslimHadithDetailViewState();
}

class _MuslimHadithDetailViewState extends State<_MuslimHadithDetailView> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      viewportFraction: 0.88,
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.blackColor,
      body: Stack(
        children: [
          // Background image
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
                _buildAppBar(context),
                _buildHadithInfo(),
                Expanded(
                  child: _buildHadithPager(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'صحيح مسلم',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildHadithInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'الحديث ${_currentIndex + 1} من ${widget.allHadiths.length}',
        style: TextStyle(
          color: ColorsManager.goldColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHadithPager() {
    if (widget.allHadiths.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أحاديث.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.allHadiths.length,
      onPageChanged: (i) {
        setState(() {
          _currentIndex = i;
        });
      },
      itemBuilder: (context, index) {
        final hadith = widget.allHadiths[index];
        return _MuslimHadithCard(
          hadith: hadith,
          index: index,
          total: widget.allHadiths.length,
        );
      },
    );
  }
}

// ─── Muslim Hadith Card ──────────────────────────────────────────────────────

class _MuslimHadithCard extends StatelessWidget {
  final MuslimHadithModel hadith;
  final int index;
  final int total;

  const _MuslimHadithCard({
    required this.hadith,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsManager.goldColor.withAlpha(230),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative overlay
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/quran_sura.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Hadith number title
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: ColorsManager.blackColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'الحديث ${_toArabicNumber(hadith.number)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.blackColor,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Arabic hadith text
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Arabic text
                          Text(
                            hadith.arab,
                            style: TextStyle(
                              fontSize: 17,
                              height: 2.0,
                              color: ColorsManager.blackColor,
                              fontFamily: 'Amiri',
                            ),
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                          ),
                           // Removed translation box for arabic only mode
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Hadith reference
                  Text(
                    'رواه مسلم #${hadith.number}',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorsManager.blackColor.withAlpha(153),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }
}
