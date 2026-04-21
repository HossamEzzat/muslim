import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim/core/theme/colors_manager.dart';

import 'package:muslim/features/hadith/data/models/hadith_model.dart';
import 'package:muslim/features/hadith/data/repositories/hadith_repository.dart';
import 'package:muslim/features/hadith/presentation/cubit/hadith_detail_cubit.dart';

class HadithDetailScreen extends StatelessWidget {
  final HadithSectionModel section;
  const HadithDetailScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HadithDetailCubit(HadithRepository())..loadHadiths(section.id),
      child: _HadithDetailView(section: section),
    );
  }
}

class _HadithDetailView extends StatefulWidget {
  final HadithSectionModel section;
  const _HadithDetailView({required this.section});

  @override
  State<_HadithDetailView> createState() => _HadithDetailViewState();
}

class _HadithDetailViewState extends State<_HadithDetailView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
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
                _buildSectionInfo(),
                Expanded(
                  child: BlocBuilder<HadithDetailCubit, HadithDetailState>(
                    builder: (context, state) {
                      if (state is HadithDetailLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ColorsManager.goldColor,
                          ),
                        );
                      }
                      if (state is HadithDetailError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  color: ColorsManager.goldColor, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                style:
                                    const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<HadithDetailCubit>()
                                    .loadHadiths(widget.section.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsManager.goldColor,
                                ),
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (state is HadithDetailLoaded) {
                        return _buildHadithPager(context, state);
                      }
                      return const SizedBox();
                    },
                  ),
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
              HadithRepository.arabicSections[widget.section.id] ?? widget.section.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSectionInfo() {
    return BlocBuilder<HadithDetailCubit, HadithDetailState>(
      builder: (context, state) {
        String info = 'جاري التحميل...';
        if (state is HadithDetailLoaded) {
          info =
              'الحديث ${state.currentIndex + 1} من ${state.hadiths.length}';
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            info,
            style: TextStyle(
              color: ColorsManager.goldColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHadithPager(
      BuildContext context, HadithDetailLoaded state) {
    if (state.hadiths.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أحاديث في هذا القسم.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: state.hadiths.length,
      onPageChanged: (i) =>
          context.read<HadithDetailCubit>().updateIndex(i),
      itemBuilder: (context, index) {
        final hadith = state.hadiths[index];
        return _HadithCard(
          hadith: hadith,
          index: index,
          total: state.hadiths.length,
        );
      },
    );
  }
}

// ─── Hadith Card ─────────────────────────────────────────────────────────────

class _HadithCard extends StatelessWidget {
  final HadithModel hadith;
  final int index;
  final int total;

  const _HadithCard({
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
                      'الحديث ${_toArabicNumber(index + 1)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.blackColor,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Hadith text
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        hadith.text,
                        style: TextStyle(
                          fontSize: 17,
                          height: 2.0,
                          color: ColorsManager.blackColor,
                          fontFamily: 'Amiri',
                        ),
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Grades section
                  if (hadith.grades.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorsManager.blackColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'التصنيف',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ColorsManager.blackColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: hadith.grades.take(3).map((g) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _gradeColor(g.grade),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_translateName(g.name)}: ${_translateGrade(g.grade)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Hadith reference
                  Text(
                    'رقم الحديث #${hadith.hadithNumber}',
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

  Color _gradeColor(String grade) {
    final lower = grade.toLowerCase();
    if (lower.contains('sahih')) return const Color(0xFF2E7D32);
    if (lower.contains('hasan')) return const Color(0xFF1565C0);
    if (lower.contains('daif') || lower.contains('munkar')) {
      return const Color(0xFFC62828);
    }
    return const Color(0xFF616161);
  }

  String _translateGrade(String grade) {
    final lower = grade.toLowerCase();
    if (lower.contains('sahih')) return 'صحيح';
    if (lower.contains('hasan')) return 'حسن';
    if (lower.contains('daif')) return 'ضعيف';
    if (lower.contains('munkar')) return 'منكر';
    if (lower.contains('mawdu')) return 'موضوع';
    return grade;
  }

  String _translateName(String name) {
    if (name.toLowerCase().contains('albani')) return 'الألباني';
    if (name.toLowerCase().contains('shuaib')) return 'شعيب الأرناؤوط';
    if (name.toLowerCase().contains('zubair')) return 'زبير علي زئي';
    return name;
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
