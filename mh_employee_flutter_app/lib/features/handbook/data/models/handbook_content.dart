class HandbookContent {
  final int id;
  final int handbookSectionId;
  final String subtitle;
  final String content;

  HandbookContent({
    required this.id,
    required this.handbookSectionId,
    required this.subtitle,
    required this.content,
  });

  factory HandbookContent.fromJson(Map<String, dynamic> json) {
    return HandbookContent(
      id: json['id'] ?? 0,
      handbookSectionId: json['handbookSectionId'] ?? 0,
      subtitle: json['subtitle'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
