class HadithSectionModel {
  final int id;
  final String name;
  final int hadithFirst;
  final int hadithLast;

  HadithSectionModel({
    required this.id,
    required this.name,
    required this.hadithFirst,
    required this.hadithLast,
  });

  int get hadithCount => hadithLast - hadithFirst + 1;
}

class HadithModel {
  final int hadithNumber;
  final int arabicNumber;
  final String text;
  final List<HadithGrade> grades;
  final int bookNumber;
  final int hadithInBook;

  HadithModel({
    required this.hadithNumber,
    required this.arabicNumber,
    required this.text,
    required this.grades,
    required this.bookNumber,
    required this.hadithInBook,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    final ref = json['reference'] as Map<String, dynamic>;
    final gradesList = (json['grades'] as List<dynamic>?)
            ?.map((g) => HadithGrade.fromJson(g as Map<String, dynamic>))
            .toList() ??
        [];

    return HadithModel(
      hadithNumber: json['hadithnumber'] as int,
      arabicNumber: json['arabicnumber'] as int,
      text: json['text'] as String,
      grades: gradesList,
      bookNumber: ref['book'] as int,
      hadithInBook: ref['hadith'] as int,
    );
  }
}

class HadithGrade {
  final String name;
  final String grade;

  HadithGrade({required this.name, required this.grade});

  factory HadithGrade.fromJson(Map<String, dynamic> json) {
    return HadithGrade(
      name: json['name'] as String,
      grade: json['grade'] as String,
    );
  }
}
