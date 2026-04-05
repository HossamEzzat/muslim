class AyahModel {
  final int id;
  final int numberInSurah;
  final String text;

  const AyahModel({
    required this.id,
    required this.numberInSurah,
    required this.text,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      id: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
    );
  }
}
