import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim/features/quran/data/models/ayah_model.dart';
import 'package:muslim/features/quran/data/models/surah_model.dart';

class QuranRepository {
  static const _baseUrl = 'https://mp3quran.net/api/v3';
  static const _suwarCacheKey = 'cached_quran_suwar';
  static String _surahDetailsCacheKey(int id) => 'cached_surah_details_$id';

  Future<List<SurahModel>> getSuwar() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/suwar?language=eng'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await prefs.setString(_suwarCacheKey, response.body);
        final data = json.decode(response.body) as Map<String, dynamic>;
        final suwarList = data['suwar'] as List<dynamic>;
        return suwarList
            .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      final cached = prefs.getString(_suwarCacheKey);
      if (cached != null) {
        final data = json.decode(cached) as Map<String, dynamic>;
        final suwarList = data['suwar'] as List<dynamic>;
        return suwarList
            .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (e is SocketException) {
        throw Exception('No internet connection and no cached Quran list.');
      }
      rethrow;
    }
  }

  Future<List<AyahModel>> getSurahDetails(int surahId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _surahDetailsCacheKey(surahId);
    
    try {
      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/quran-uthmani'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>;
        final ayahsList = data['ayahs'] as List<dynamic>;

        return ayahsList
            .map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final jsonResponse = json.decode(cached) as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>;
        final ayahsList = data['ayahs'] as List<dynamic>;

        return ayahsList
            .map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (e is SocketException) {
        throw Exception('No internet connection. This Surah is not cached.');
      }
      rethrow;
    }
  }
}

