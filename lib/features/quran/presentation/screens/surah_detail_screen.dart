import 'package:flutter/material.dart';
import 'package:muslim/features/quran/data/models/surah_model.dart' as my_surah;
import 'package:quran_library/quran_library.dart';

class SurahDetailScreen extends StatelessWidget {
  final my_surah.SurahModel surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return SurahDisplayScreen(
      parentContext: context,
      surahNumber: surah.id,
      isDark: true,
      appLanguageCode: 'ar',
      isFontsLocal: true,
    );
  }
}
