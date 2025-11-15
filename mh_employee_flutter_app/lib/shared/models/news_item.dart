import 'package:mh_employee_app/features/documents/data/models/document_model.dart';

class NewsItem {
  final int id;
  final String title;
  final String content;
  final DateTime datePosted;
  final String author;
  final bool isRead;
  final int uid;
  String? displayName; // New field for nickname/fullname

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.datePosted,
    required this.author,
    this.isRead = false,
    required this.uid,
    this.displayName,
  });

  factory NewsItem.fromDocument(Document doc) {
    return NewsItem(
      id: doc.id,
      title: doc.title,
      content: doc.content ?? '',
      datePosted: doc.postDate,
      author: doc.posterName,
      isRead: false,
      uid: doc.uid,
      displayName: null, // Will be populated later
    );
  }

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    datePosted: DateTime.parse(json['postDate']),
    author: json['posterName'] ?? 'Unknown Author',
    isRead: json['isRead'] ?? false,
    uid: json['userid'] ?? '',
    displayName: null, // Will be populated later
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'datePosted': datePosted.toIso8601String(),
    'author': author,
    'isRead': isRead,
    'userid': uid,
    'displayName': displayName,
  };

  NewsItem copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? datePosted,
    String? author,
    bool? isRead,
    int? uid,
    String? displayName,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      datePosted: datePosted ?? this.datePosted,
      author: author ?? this.author,
      isRead: isRead ?? this.isRead,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
    );
  }
}

