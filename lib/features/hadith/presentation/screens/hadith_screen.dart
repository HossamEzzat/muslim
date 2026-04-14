import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim/core/theme/colors_manager.dart';

import 'package:muslim/features/hadith/data/models/hadith_model.dart';
import 'package:muslim/features/hadith/data/repositories/hadith_repository.dart';
import 'package:muslim/features/hadith/presentation/cubit/hadith_cubit.dart';
import 'package:muslim/features/hadith/presentation/screens/hadith_detail_screen.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HadithCubit(HadithRepository())..loadSections(),
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
                  child: BlocBuilder<HadithCubit, HadithState>(
                    builder: (context, state) {
                      if (state is HadithLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ColorsManager.goldColor,
                          ),
                        );
                      }
                      if (state is HadithError) {
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style:
                                      const TextStyle(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<HadithCubit>()
                                    .loadSections(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsManager.goldColor,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (state is HadithSectionsLoaded) {
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
        onChanged: (q) => context.read<HadithCubit>().search(q),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/hadith.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                  ColorsManager.goldColor, BlendMode.srcIn),
            ),
          ),
          hintText: 'Hadith Name',
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

  Widget _buildContent(BuildContext context, HadithSectionsLoaded state) {
    return CustomScrollView(
      slivers: [
        // Collection name header
        SliverToBoxAdapter(
          child: _SectionHeader(title: 'سنن أبي داود'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${state.filteredSections.length} Books',
              style: TextStyle(
                color: ColorsManager.goldColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        // Sections list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final section = state.filteredSections[index];
              return _SectionListItem(section: section);
            },
            childCount: state.filteredSections.length,
          ),
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
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
      ),
    );
  }
}

// ─── Section List Item ───────────────────────────────────────────────────────

class _SectionListItem extends StatelessWidget {
  final HadithSectionModel section;
  const _SectionListItem({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HadithDetailScreen(section: section),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Number badge
                _SectionNumberBadge(number: section.id),
                const SizedBox(width: 16),
                // Section name + hadith count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${section.hadithCount} Hadiths',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: ColorsManager.goldColor,
                  size: 16,
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
            'assets/sn.png',
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
