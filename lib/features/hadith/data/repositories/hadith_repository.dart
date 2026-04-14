import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:muslim/features/hadith/data/models/hadith_model.dart';

class HadithRepository {
  static const _apiUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-abudawud.min.json';

  Map<String, dynamic>? _cachedData;

  Future<Map<String, dynamic>> _fetchData() async {
    if (_cachedData != null) return _cachedData!;

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      _cachedData = json.decode(response.body) as Map<String, dynamic>;
      return _cachedData!;
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

  Future<List<HadithSectionModel>> getSections() async {
    final data = await _fetchData();
    final metadata = data['metadata'] as Map<String, dynamic>;
    final sections = metadata['sections'] as Map<String, dynamic>;
    final sectionDetails = metadata['section_details'] as Map<String, dynamic>;

    final result = <HadithSectionModel>[];

    for (final entry in sections.entries) {
      final id = int.tryParse(entry.key);
      if (id == null || id == 0) continue; // Skip section 0 (empty)

      final name = entry.value as String;
      final details = sectionDetails[entry.key] as Map<String, dynamic>?;

      if (details != null) {
        result.add(HadithSectionModel(
          id: id,
          name: name,
          hadithFirst: details['hadithnumber_first'] as int,
          hadithLast: details['hadithnumber_last'] as int,
        ));
      }
    }

    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  Future<List<HadithModel>> getHadithsBySection(int sectionId) async {
    final data = await _fetchData();
    final hadiths = data['hadiths'] as List<dynamic>;

    return hadiths
        .where((h) {
          final ref = h['reference'] as Map<String, dynamic>;
          return ref['book'] == sectionId;
        })
        .map((h) => HadithModel.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  String getCollectionName() => 'سنن أبي داود';
}
