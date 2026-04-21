import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim/features/hadith/data/models/hadith_model.dart';

class HadithRepository {
  static const _apiUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-abudawud.min.json';
  static const _cacheKey = 'cached_abudawud_hadiths';

  Map<String, dynamic>? _cachedData;

  Future<Map<String, dynamic>> _fetchData() async {
    if (_cachedData != null) return _cachedData!;

    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _cachedData = json.decode(response.body) as Map<String, dynamic>;
        // Save to cache
        await prefs.setString(_cacheKey, response.body);
        return _cachedData!;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to cache
      final cachedString = prefs.getString(_cacheKey);
      if (cachedString != null) {
        _cachedData = json.decode(cachedString) as Map<String, dynamic>;
        return _cachedData!;
      }
      
      if (e is SocketException) {
        throw Exception('No internet connection and no cached data.');
      }
      rethrow;
    }
  }

  static const arabicSections = {
    1: 'كتاب الطهارة',
    2: 'كتاب الصلاة',
    3: 'كتاب الاستسقاء',
    4: 'صلاة السفر',
    5: 'صلاة التطوع',
    6: 'شهر رمضان',
    7: 'سجود القرآن',
    8: 'الوتر',
    9: 'كتاب الزكاة',
    10: 'كتاب اللقطة',
    11: 'كتاب المناسك والحج',
    12: 'كتاب النكاح',
    13: 'كتاب الطلاق',
    14: 'كتاب الصيام',
    15: 'كتاب الجهاد',
    16: 'كتاب الضحايا',
    17: 'كتاب الصيد',
    18: 'كتاب الوصايا',
    19: 'كتاب الفرائض',
    20: 'كتاب الخراج والإمارة والفيء',
    21: 'كتاب الجنائز',
    22: 'كتاب الأيمان والنذور',
    23: 'كتاب البيوع',
    24: 'كتاب الإجارة',
    25: 'كتاب الأقضية',
    26: 'كتاب العلم',
    27: 'كتاب الأشربة',
    28: 'كتاب الأطعمة',
    29: 'كتاب الطب',
    30: 'كتاب الكهانة والتطير',
    31: 'كتاب العتق',
    32: 'كتاب الحروف والقراءات',
    33: 'كتاب الحمام',
    34: 'كتاب اللباس',
    35: 'كتاب الترجل',
    36: 'كتاب الخاتم',
    37: 'كتاب الفتن والملاحم',
    38: 'كتاب المهدي',
    39: 'كتاب الملاحم',
    40: 'كتاب الحدود',
    41: 'كتاب الديات',
    42: 'كتاب السنة',
    43: 'كتاب الأدب',
  };

  Future<List<HadithSectionModel>> getSections() async {
    final data = await _fetchData();
    final metadata = data['metadata'] as Map<String, dynamic>;
    final sections = metadata['sections'] as Map<String, dynamic>;
    final sectionDetails = metadata['section_details'] as Map<String, dynamic>;

    final result = <HadithSectionModel>[];

    for (final entry in sections.entries) {
      final id = int.tryParse(entry.key);
      if (id == null || id == 0) continue; // Skip section 0 (empty)

      final name = arabicSections[id] ?? entry.value as String;
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
