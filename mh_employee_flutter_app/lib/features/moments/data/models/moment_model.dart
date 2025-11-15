class Moment {
  final int id;
  final String title;
  final String description;
  final int userId;
  final String? userName; // Nullable since backend can return null
  final List<String>? images;
  final List<String> imagePath; // New field
  final List<MomentReaction> reactions;
  final DateTime createdAt;
  final String? nickname;

  Moment({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    this.userName, // Nullable
    this.images,
    required this.imagePath, // New field
    required this.reactions,
    required this.createdAt,
    this.nickname,
  });

  // Factory constructor for JSON deserialization
  factory Moment.fromJson(Map<String, dynamic> json) {
    return Moment(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        userId: json['userId'] ?? 0,
        userName: json['userName'], // Can be null
        // images: List<String>.from(json['images'] ?? []),
        images: (json['imagePath'] as List?)
            ?.map((e) => e['imagePath'] as String)
            ?.toList() ??
            [],
        imagePath: (json['imagePath'] as List?)
            ?.map((e) => e['imagePath'] as String)
            ?.toList() ??
            [], // New field parsing
        reactions: (json['reactions'] as List?)
            ?.map((r) => MomentReaction.fromJson(r))
            ?.toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt']),
        nickname: json['nickname']
    );
  }

  // copyWith method to create a new instance with updated properties
  Moment copyWith({
    int? id,
    String? title,
    String? description,
    int? userId,
    String? userName,
    List<String>? images,
    List<String>? imagePath, //
    List<MomentReaction>? reactions,
    DateTime? createdAt,
    String? nickname,
  }) {
    return Moment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      images: images ?? this.images,
      imagePath: imagePath ?? this.imagePath, //
      reactions: reactions ?? this.reactions,
      createdAt: createdAt ?? this.createdAt,
      nickname: nickname?? this.nickname,
    );
  }
}

class MomentReaction {
  final int? id;
  final int userId;
  final String userName;
  final String reactionType;
  final DateTime createdAt;
  final String? nickname;

  MomentReaction({
    this.id,
    required this.userId,
    required this.userName,
    required this.reactionType,
    required this.createdAt,
    this.nickname,
  });

  // Factory constructor for JSON deserialization
  factory MomentReaction.fromJson(Map<String, dynamic> json) {
    return MomentReaction(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        reactionType: json['reactionType'],
        createdAt: DateTime.parse(json['createdAt']),
        nickname: json['nickname']
    );
  }

  // Optional: copyWith method for MomentReaction if needed
  MomentReaction copyWith({
    int? id,
    int? userId,
    String? userName,
    String? reactionType,
    DateTime? createdAt,
    String? nickname,
  }) {
    return MomentReaction(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        reactionType: reactionType ?? this.reactionType,
        createdAt: createdAt ?? this.createdAt,
        nickname: nickname?? this.nickname
    );
  }
}

class PagedResponse<T> {
  final List<T> items;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int totalCount;

  PagedResponse({
    required this.items,
    this.totalPages = 1,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalCount = 0,
  });

  factory PagedResponse.fromJson(
      dynamic json,
      T Function(dynamic) fromJsonT,
      ) {
    // If json is a list, convert it directly
    if (json is List) {
      return PagedResponse(
        items: json.map((item) => fromJsonT(item)).toList(),
        totalPages: 1,
        currentPage: 1,
        pageSize: json.length,
        totalCount: json.length,
      );
    }

    // If json is a map, try to extract items
    if (json is Map<String, dynamic>) {
      dynamic itemsData = json['items'] ?? json['data'] ?? [];
      List<dynamic> itemsList = itemsData is List ? itemsData : [];

      return PagedResponse(
        items: itemsList.map((item) => fromJsonT(item)).toList(),
        totalPages: json['totalPages'] ?? 1,
        currentPage: json['currentPage'] ?? 1,
        pageSize: json['pageSize'] ?? itemsList.length,
        totalCount: json['totalCount'] ?? itemsList.length,
      );
    }

    // Fallback for unexpected input
    return PagedResponse(items: []);
  }
}

