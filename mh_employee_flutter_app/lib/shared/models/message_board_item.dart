class MessageBoardItem {
  final String message;
  final DateTime datePosted;
  final String author;

  MessageBoardItem({
    required this.message,
    required this.datePosted,
    required this.author,
  });

  Map<String, dynamic> toJson() => {
    'message': message,
    'datePosted': datePosted.toIso8601String(),
    'author': author,
  };

  factory MessageBoardItem.fromJson(Map<String, dynamic> json) => MessageBoardItem(
    message: json['message'],
    datePosted: DateTime.parse(json['datePosted']),
    author: json['author'],
  );
}
