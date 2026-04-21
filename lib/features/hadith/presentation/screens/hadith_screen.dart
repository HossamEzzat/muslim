import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim/core/theme/colors_manager.dart';

import 'package:muslim/features/hadith/data/models/muslim_hadith_model.dart';
import 'package:muslim/features/hadith/data/repositories/muslim_hadith_repository.dart';
import 'package:muslim/features/hadith/presentation/cubit/muslim_hadith_cubit.dart';
import 'package:muslim/features/hadith/presentation/screens/muslim_hadith_detail_screen.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MuslimHadithCubit(MuslimHadithRepository())..loadHadiths(),
      child: const _HadithView(),
    );
  }
}

class _HadithView extends StatefulWidget {
  const _HadithView();

  @override
  State<_HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends State<_HadithView> {
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
                _buildSearchBar(),
                Expanded(
                  child: _buildMuslimTab(),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (q) {
          context.read<MuslimHadithCubit>().search(q);
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/icons/hadith.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                  ColorsManager.goldColor, BlendMode.srcIn),
            ),
          ),
          hintText: 'ابحث عن حديث...',
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: ColorsManager.goldColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: ColorsManager.goldColor, width: 2),
          ),
        ),
      ),
    );
  }

  // ─── Sahih Muslim Tab ────────────────────────────────────────────────────

  Widget _buildMuslimTab() {
    return BlocBuilder<MuslimHadithCubit, MuslimHadithState>(
      builder: (context, state) {
        if (state is MuslimHadithLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorsManager.goldColor,
            ),
          );
        }
        if (state is MuslimHadithError) {
          return _buildErrorWidget(
            message: state.message,
            onRetry: () =>
                context.read<MuslimHadithCubit>().loadHadiths(),
          );
        }
        if (state is MuslimHadithLoaded) {
          return _buildMuslimContent(context, state);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildMuslimContent(
      BuildContext context, MuslimHadithLoaded state) {
    return CustomScrollView(
      slivers: [
        // Collection name header
        SliverToBoxAdapter(
          child: _SectionHeader(title: 'صحيح مسلم'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${state.filteredHadiths.length} حديث',
              style: TextStyle(
                color: ColorsManager.goldColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        // Hadiths list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final hadith = state.filteredHadiths[index];
              return _MuslimHadithListItem(
                hadith: hadith,
                allHadiths: state.filteredHadiths,
                index: index,
              );
            },
            childCount: state.filteredHadiths.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  // ─── Shared Error Widget ─────────────────────────────────────────────────

  Widget _buildErrorWidget({
    required String message,
    required VoidCallback onRetry,
  }) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.goldColor,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
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
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
      ),
    );
  }
}

// ─── Muslim Hadith List Item ─────────────────────────────────────────────────

class _MuslimHadithListItem extends StatelessWidget {
  final MuslimHadithModel hadith;
  final List<MuslimHadithModel> allHadiths;
  final int index;

  const _MuslimHadithListItem({
    required this.hadith,
    required this.allHadiths,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(20), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MuslimHadithDetailScreen(
                  hadith: hadith,
                  allHadiths: allHadiths,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Number badge
                _SectionNumberBadge(number: hadith.number),
                const SizedBox(width: 16),
                // Hadith preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hadith.arab,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Amiri',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'رقم الحديث ${hadith.number}',
                        style: TextStyle(
                          color: ColorsManager.goldColor.withAlpha(220),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: ColorsManager.goldColor.withAlpha(200),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Number Badge ────────────────────────────────────────────────────

class _SectionNumberBadge extends StatelessWidget {
  final int number;
  const _SectionNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/star_badge.png',
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
