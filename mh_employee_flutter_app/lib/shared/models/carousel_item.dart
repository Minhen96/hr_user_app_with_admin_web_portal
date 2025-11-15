// carousel_item.dart - Update the CarouselItem class
import '../../services/api_service.dart';

class CarouselItem {
  final int id;
  final String title;
  final String titleCn;
  final String description;
  final String descriptionCn;
  final String imageUrl;
  final String carouselType;
  final String? lastEditedBy;
  final DateTime? lastEditedDate;

  CarouselItem({
    required this.id,
    required this.title,
    required this.titleCn,
    required this.description,
    required this.descriptionCn,
    required this.imageUrl,
    required this.carouselType,
    this.lastEditedBy,
    this.lastEditedDate,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> json) {
    return CarouselItem(
      id: json['id'],
      title: json['title'] ?? json['carouselType'] ?? 'Untitled',
      titleCn: json['titleCn'] ?? json['title'] ?? 'Untitled',
      description: json['text'] ?? '',
      descriptionCn: json['textCn'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      carouselType: json['carouselType'],
      lastEditedBy: json['lastEditedBy'],
      lastEditedDate: json['lastEditedDate'] != null
          ? DateTime.parse(json['lastEditedDate'])
          : null,
    );
  }
}

