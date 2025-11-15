import 'handbook_content.dart';

class HandbookSection {
  final int id;
  final String title;
  final List<HandbookContent> contents;

  HandbookSection({
    required this.id,
    required this.title,
    required this.contents,
  });

  factory HandbookSection.fromJson(Map<String, dynamic> json) {
    return HandbookSection(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      contents: (json['contents'] as List<dynamic>?)
          ?.map((content) => HandbookContent.fromJson(content))
          .toList() ?? [],
    );
  }
}
