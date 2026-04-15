/// Model for a single hadith from the gading.dev API (Sahih Muslim).
class MuslimHadithModel {
  final int number;
  final String arab;
  final String id; // Indonesian translation

  MuslimHadithModel({
    required this.number,
    required this.arab,
    required this.id,
  });

  factory MuslimHadithModel.fromJson(Map<String, dynamic> json) {
    return MuslimHadithModel(
      number: json['number'] as int,
      arab: json['arab'] as String,
      id: json['id'] as String,
    );
  }
}

/// Wrapper for the full Muslim API response.
class MuslimHadithResponse {
  final String name;
  final String bookId;
  final int available;
  final int requested;
  final List<MuslimHadithModel> hadiths;

  MuslimHadithResponse({
    required this.name,
    required this.bookId,
    required this.available,
    required this.requested,
    required this.hadiths,
  });

  factory MuslimHadithResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final hadithsList = (data['hadiths'] as List<dynamic>)
        .map((h) => MuslimHadithModel.fromJson(h as Map<String, dynamic>))
        .toList();

    return MuslimHadithResponse(
      name: data['name'] as String,
      bookId: data['id'] as String,
      available: data['available'] as int,
      requested: data['requested'] as int,
      hadiths: hadithsList,
    );
  }
}
