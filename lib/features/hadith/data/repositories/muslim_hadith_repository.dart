import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:muslim/features/hadith/data/models/muslim_hadith_model.dart';

class MuslimHadithRepository {
  /// Fetches hadiths 1–150 from Sahih Muslim via the gading.dev API.
  static const _apiUrl =
      'https://api.hadith.gading.dev/books/muslim?range=1-150';

  MuslimHadithResponse? _cachedResponse;

  Future<MuslimHadithResponse> fetchHadiths() async {
    if (_cachedResponse != null) return _cachedResponse!;

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      _cachedResponse = MuslimHadithResponse.fromJson(jsonData);
      return _cachedResponse!;
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again later.');
    } on FormatException {
      throw Exception('Unexpected response format.');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  String getCollectionName() => 'صحيح مسلم';
}
