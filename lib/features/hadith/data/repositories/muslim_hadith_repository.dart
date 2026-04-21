import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim/features/hadith/data/models/muslim_hadith_model.dart';

class MuslimHadithRepository {
  /// Fetches hadiths 1–150 from Sahih Muslim via the gading.dev API.
  static const _apiUrl =
      'https://api.hadith.gading.dev/books/muslim?range=1-150';
  static const _cacheKey = 'cached_muslim_hadiths';

  MuslimHadithResponse? _cachedResponse;

  Future<MuslimHadithResponse> fetchHadiths() async {
    if (_cachedResponse != null) return _cachedResponse!;

    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        // Save to local cache
        await prefs.setString(_cacheKey, response.body);
        _cachedResponse = MuslimHadithResponse.fromJson(jsonData);
        return _cachedResponse!;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load from cache if network fails or server errors
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final jsonData = json.decode(cachedData) as Map<String, dynamic>;
        _cachedResponse = MuslimHadithResponse.fromJson(jsonData);
        return _cachedResponse!;
      }
      
      if (e is SocketException) {
        throw Exception('No internet connection and no cached data found.');
      }
      rethrow;
    }
  }

  String getCollectionName() => 'صحيح مسلم';
}
