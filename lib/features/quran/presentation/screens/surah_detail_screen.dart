import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim/core/theme/colors_manager.dart';
import 'package:muslim/features/quran/data/models/surah_model.dart';
import 'package:muslim/features/quran/data/repositories/quran_repository.dart';
import 'package:muslim/features/quran/presentation/cubit/surah_detail_cubit.dart';

class SurahDetailScreen extends StatelessWidget {
  final SurahModel surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SurahDetailCubit(QuranRepository())..loadSurahDetails(surah.id),
      child: _SurahDetailView(surah: surah),
    );
  }
}

class _SurahDetailView extends StatelessWidget {
  final SurahModel surah;

  const _SurahDetailView({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.blackColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorsManager.goldColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          surah.name,
          style: TextStyle(
            color: ColorsManager.goldColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Silhouette at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: 0.2, // Adjust opacity as needed
              child: Image.asset(
                'assets/mosque_bg.png', // Placeholder for the silhouette image
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          
          Column(
            children: [
              // Arabic Surah Name Header with Corners
              _buildSurahHeader(),
              
              // Ayahs List
              Expanded(
                child: BlocBuilder<SurahDetailCubit, SurahDetailState>(
                  builder: (context, state) {
                    if (state is SurahDetailLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: ColorsManager.goldColor,
                        ),
                      );
                    } else if (state is SurahDetailError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, color: ColorsManager.goldColor, size: 48),
                            const SizedBox(height: 12),
                            Text(state.message, style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.goldColor),
                              onPressed: () {
                                context.read<SurahDetailCubit>().loadSurahDetails(surah.id);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is SurahDetailLoaded) {
                      final ayahs = state.ayahs;
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        itemCount: ayahs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ayah = ayahs[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ColorsManager.goldColor.withAlpha(200),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              '[${ayah.numberInSurah}] ${ayah.text}',
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: ColorsManager.goldColor,
                                fontSize: 22,
                                height: 1.6,
                                fontFamily: 'Amiri', // Assumes you have an arabic font configured
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Corner
          Positioned(
            left: 0,
            top: 0,
            child: Image.asset(
              'assets/corner.png', // Replace with the actual corner asset name
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 50, height: 50),
            ),
          ),
          
          // Right Corner (mirrored horizontally)
          Positioned(
            right: 0,
            top: 0,
            child: Transform.scale(
              scaleX: -1,
              child: Image.asset(
                'assets/corner.png', // Replace with the actual corner asset name
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) => const SizedBox(width: 50, height: 50),
              ),
            ),
          ),
          
          // Arabic Name in Center
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
            child: Text(
              surah.arabicName,
              style: TextStyle(
                color: ColorsManager.goldColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri', // Assumes a traditional font
              ),
            ),
          ),
        ],
      ),
    );
  }
}
