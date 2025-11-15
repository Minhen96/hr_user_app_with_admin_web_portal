import 'dart:ui';
import 'package:flutter/cupertino.dart';


class BannerItem {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final Widget Function(BuildContext) screen;

  BannerItem({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.screen,
  });
}

