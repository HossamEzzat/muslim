import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim/core/theme/colors_manager.dart';

import 'package:muslim/features/quran/data/models/surah_model.dart';
import 'package:muslim/features/quran/data/repositories/quran_repository.dart';
import 'package:muslim/features/quran/presentation/cubit/quran_cubit.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuranCubit(QuranRepository())..loadSuwar(),
      child: const _QuranView(),
    );
  }
}

class _QuranView extends StatefulWidget {
  const _QuranView();

  @override
  State<_QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<_QuranView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
              'assets/taj.png',
              fit: BoxFit.cover,
              color: Colors.black.withAlpha(153),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(
                  child: BlocBuilder<QuranCubit, QuranState>(
                    builder: (context, state) {
                      if (state is QuranLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ColorsManager.goldColor,
                          ),
                        );
                      }
                      if (state is QuranError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: ColorsManager.goldColor,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<QuranCubit>().loadSuwar(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsManager.goldColor,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (state is QuranLoaded) {
                        return _buildContent(context, state);
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Image.asset('assets/logo.png', height: 80),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (q) => context.read<QuranCubit>().search(q),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/quran.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(ColorsManager.goldColor, BlendMode.srcIn),
            ),
            // Or use: Icon(Icons.menu_book, color: ColorsManager.goldColor)
          ),
          hintText: 'Sura Name',
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorsManager.goldColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorsManager.goldColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuranLoaded state) {
    return CustomScrollView(
      slivers: [
        // Recently Read Section
        SliverToBoxAdapter(child: _SectionHeader(title: 'Most Recently')),
        SliverToBoxAdapter(child: _RecentSurahCards(suwar: state.recentSuwar)),
        // Suras List Section
        SliverToBoxAdapter(child: _SectionHeader(title: 'Suras List')),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final surah = state.filteredSuwar[index];
            return _SurahListItem(surah: surah);
          }, childCount: state.filteredSuwar.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Recent Surah Horizontal Cards ───────────────────────────────────────────

class _RecentSurahCards extends StatelessWidget {
  final List<SurahModel> suwar;
  const _RecentSurahCards({required this.suwar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suwar.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _RecentCard(surah: suwar[index]),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final SurahModel surah;
  const _RecentCard({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: ColorsManager.goldColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                surah.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.blackColor,
                ),
              ),
              Text(
                surah.arabicName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.blackColor.withAlpha(217), // 0.85 * 255
                ),
              ),
              Text(
                '${surah.versesCount} Verses',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorsManager.blackColor.withAlpha(179), // 0.7 * 255
                ),
              ),
            ],
          ),
          // Decorative Quran illustration (replace with your asset)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.35,
              child: Image.asset('assets/quranSura.png', fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Surah List Item ─────────────────────────────────────────────────────────

class _SurahListItem extends StatelessWidget {
  final SurahModel surah;
  const _SurahListItem({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Navigate to surah detail screen
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (_) => SurahDetailScreen(surah: surah),
            // ));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Number badge
                _SurahNumberBadge(number: surah.id),
                const SizedBox(width: 16),
                // English name + verse count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah.versesCount} Verses',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arabic name
                Text(
                  surah.arabicName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontFamily: 'Amiri', // Use an Arabic font
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: Colors.white12,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}

class _SurahNumberBadge extends StatelessWidget {
  final int number;
  const _SurahNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Star/badge shape using CustomPaint or an asset
          Image.asset(
            'assets/sn.png', // The star-shaped badge from the design
            width: 48,
            height: 48,
            color: ColorsManager.goldColor,
          ),
          Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
