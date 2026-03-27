import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/surah_model.dart';

class QuranRepository {
  static const _baseUrl = 'https://mp3quran.net/api/v3';

  Future<List<SurahModel>> getSuwar() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/suwar?language=eng'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final suwarList = data['suwar'] as List<dynamic>;
      return suwarList
          .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
}
