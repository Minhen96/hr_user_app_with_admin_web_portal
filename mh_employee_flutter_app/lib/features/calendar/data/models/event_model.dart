class Event {
  final int? id;
  final String title;
  final String? description;
  final DateTime date;
  final int userId;
  final String? userName;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isRead;

  Event({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.userId,
    this.userName,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      userId: json['user_id'],
      userName: json['user_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    int? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
