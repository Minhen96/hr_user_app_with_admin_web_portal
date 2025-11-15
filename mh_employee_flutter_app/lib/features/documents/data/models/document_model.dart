class Document {
  final int id;
  final String type;
  final DateTime postDate;
  final String posterName;
  final String title;
  final String? content;
  final String departmentName;
  final String? documentUpload;
  final String? fileType;
  final bool isRead; // New field
  final int uid;
  String? nickname; // Add this field to store the nickname

  Document({
    required this.id,
    required this.type,
    required this.postDate,
    required this.posterName,
    required this.title,
    this.content,
    required this.departmentName,
    this.documentUpload,
    this.fileType,
    this.isRead = false, // Default to unread
    required this.uid,
    this.nickname,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
        id: json['id'],
        type: json['type'] ?? '',
        postDate: DateTime.parse(json['postDate']),
        posterName: json['posterName'] ?? '',
        title: json['title'] ?? '',
        content: json['content'],
        departmentName: json['departmentName'] ?? '',
        documentUpload: json['documentUpload'],
        fileType: json['fileType'],
        isRead: json['isRead'] ?? false,
        uid: json['userid'],
        nickname: null
    );
  }

  Document copyWith({
    int? id,
    String? type,
    DateTime? postDate,
    String? posterName,
    String? title,
    String? content,
    String? departmentName,
    String? documentUpload,
    String? fileType,
    bool? isRead,
    int? uid,
    String? nickname,
  }) {
    return Document(
      id: id ?? this.id,
      type: type ?? this.type,
      postDate: postDate ?? this.postDate,
      posterName: posterName ?? this.posterName,
      title: title ?? this.title,
      content: content ?? this.content,
      departmentName: departmentName ?? this.departmentName,
      documentUpload: documentUpload ?? this.documentUpload,
      fileType: fileType ?? this.fileType,
      isRead: isRead ?? this.isRead,
      uid: uid??this.uid,
      nickname: nickname ?? this.nickname,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponse(
      items: (json['items'] as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalCount: json['totalCount'],
    );
  }
}

