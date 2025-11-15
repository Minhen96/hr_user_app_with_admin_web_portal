import 'carousel_item.dart';

class QuoteItem extends CarouselItem {
  final String? quote;
  final String? quoteCn;
  @override
  final String lastEditedBy;
  @override
  final DateTime lastEditedDate;
  late List<QuoteView> views;
  late List<QuoteReaction> reactions;

  static const String defaultImageUrl = 'assets/images/quote.jpg';

  QuoteItem({
    required super.id,
    this.quote,
    this.quoteCn,
    required super.title,
    required super.titleCn,
    required super.description,
    required super.descriptionCn,
    required super.imageUrl,
    required this.lastEditedBy,
    required this.lastEditedDate,
    this.views = const [],
    this.reactions = const [],
  }) : super(
    carouselType: 'quote',
  );

  QuoteItem copyWith({
    int? id,
    String? quote,
    String? quoteCn,
    String? title,
    String? titleCn,
    String? description,
    String? descriptionCn,
    String? imageUrl,
    String? lastEditedBy,
    DateTime? lastEditedDate,
    List<QuoteView>? views,
    List<QuoteReaction>? reactions,
  }) {
    return QuoteItem(
      id: id ?? this.id,
      quote: quote ?? this.quote,
      quoteCn: quoteCn ?? this.quoteCn,
      title: title ?? this.title,
      titleCn: titleCn ?? this.titleCn,
      description: description ?? this.description,
      descriptionCn: descriptionCn ?? this.descriptionCn,
      imageUrl: imageUrl ?? this.imageUrl,
      lastEditedBy: lastEditedBy ?? this.lastEditedBy,
      lastEditedDate: lastEditedDate ?? this.lastEditedDate,
      views: views ?? this.views,
      reactions: reactions ?? this.reactions,
    );
  }

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      id: json['id'],
      quote: json['text'],
      quoteCn: json['textCn'],
      title: 'Quote of the Day',
      titleCn: '每日励志',
      description: json['text'] ?? '',
      descriptionCn: json['textCn'] ?? '',
      imageUrl: json['imageUrl']?.isNotEmpty == true
          ? json['imageUrl']
          : defaultImageUrl,  // Use the default if imageUrl is null or empty
      lastEditedBy: json['lastEditedBy'] ?? 'Unknown',
      lastEditedDate: DateTime.parse(json['lastEditedDate']),
      views: (json['views'] as List?)
          ?.map((v) => QuoteView.fromJson(v))
          .toList() ?? [],
      reactions: (json['reactions'] as List?)
          ?.map((r) => QuoteReaction.fromJson(r))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': quote,
      'textCn': quoteCn,
      'lastEditedBy': lastEditedBy,
      'lastEditedDate': lastEditedDate.toIso8601String(),
      'views': views.map((v) => v.toJson()).toList(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
    };
  }
}

class QuoteView {
  final String viewedBy;
  final DateTime viewedAt;

  QuoteView({
    required this.viewedBy,
    required this.viewedAt,
  });

  factory QuoteView.fromJson(Map<String, dynamic> json) {
    return QuoteView(
      viewedBy: json['viewedBy'],
      viewedAt: DateTime.parse(json['viewedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewedBy': viewedBy,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }
}

class QuoteReaction {
  final String reactedBy;
  final String reaction;
  final DateTime reactedAt;

  QuoteReaction({
    required this.reactedBy,
    required this.reaction,
    required this.reactedAt,
  });

  factory QuoteReaction.fromJson(Map<String, dynamic> json) {
    return QuoteReaction(
      reactedBy: json['reactedBy'],
      reaction: json['reaction'],
      reactedAt: DateTime.parse(json['reactedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reactedBy': reactedBy,
      'reaction': reaction,
      'reactedAt': reactedAt.toIso8601String(),
    };
  }
}


// import 'carousel_item.dart';
//
// class QuoteItem extends CarouselItem {
//   final int id;
//   String? quote;
//   String? quoteCn;
//   String lastEditedBy;
//   DateTime lastEditedDate;
//   final String imageUrl = 'assets/images/quote.jpg';
//   List<QuoteView> views;
//   List<QuoteReaction> reactions;
//
//   QuoteItem({
//     required this.id,
//     this.quote,
//     this.quoteCn,
//     required String title,
//     required String titleCn,
//     required String description,
//     required String descriptionCn,
//     required this.lastEditedBy,
//     required this.lastEditedDate,
//     this.views = const [],
//     this.reactions = const [],
//   }) : super(
//     title: title,
//     titleCn: titleCn,
//     description: description,
//     descriptionCn: descriptionCn,
//     imageUrl: 'assets/images/quote.jpg', // Pass the value directly
//   );
//
//   QuoteItem copyWith({
//     String? quote,
//     String? quoteCn,
//     String? lastEditedBy,
//     DateTime? lastEditedDate,
//     List<QuoteView>? views,
//     List<QuoteReaction>? reactions,
//   }) {
//     return QuoteItem(
//       id: id,
//       quote: quote ?? this.quote,
//       quoteCn: quoteCn ?? this.quoteCn,
//       title: title,
//       titleCn: titleCn,
//       description: description,
//       descriptionCn: descriptionCn,
//       lastEditedBy: lastEditedBy ?? this.lastEditedBy,
//       lastEditedDate: lastEditedDate ?? this.lastEditedDate,
//       views: views ?? this.views,
//       reactions: reactions ?? this.reactions,
//     );
//   }
//
//   factory QuoteItem.fromJson(Map<String, dynamic> json) {
//     return QuoteItem(
//       id: json['id'],
//       quote: json['text'],
//       quoteCn: json['textCn'],
//       title: 'Quote of the Day',
//       titleCn: '每日励志',
//       description: json['text'],
//       descriptionCn: json['textCn'],
//       lastEditedBy: json['lastEditedBy'],
//       lastEditedDate: DateTime.parse(json['lastEditedDate']),
//       views: (json['views'] as List)
//           .map((v) => QuoteView.fromJson(v))
//           .toList(),
//       reactions: (json['reactions'] as List)
//           .map((r) => QuoteReaction.fromJson(r))
//           .toList(),
//     );
//   }
// }
//
// class QuoteView {
//   final String viewedBy;
//   final DateTime viewedAt;
//
//   QuoteView({
//     required this.viewedBy,
//     required this.viewedAt,
//   });
//
//   factory QuoteView.fromJson(Map<String, dynamic> json) {
//     return QuoteView(
//       viewedBy: json['viewedBy'],
//       viewedAt: DateTime.parse(json['viewedAt']),
//     );
//   }
// }
//
// class QuoteReaction {
//   final String reactedBy;
//   late final String reaction;
//   late final DateTime reactedAt;
//
//   QuoteReaction({
//     required this.reactedBy,
//     required this.reaction,
//     required this.reactedAt,
//   });
//
//   factory QuoteReaction.fromJson(Map<String, dynamic> json) {
//     return QuoteReaction(
//       reactedBy: json['reactedBy'],
//       reaction: json['reaction'],
//       reactedAt: DateTime.parse(json['reactedAt']),
//     );
//   }
// }


