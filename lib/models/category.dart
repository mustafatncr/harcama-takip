import 'package:flutter/material.dart';
import '../utils/icon_map.dart'; // icon map'i birazdan vereceğim

class Category {
  final String name;
  final String iconName; // 🔥 artık sadece string tutuyoruz

  Category({
    required this.name,
    required this.iconName,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'iconName': iconName,
      };

  static Category fromJson(Map<String, dynamic> json) => Category(
        name: json['name'],
        iconName: json['iconName'],
      );

  /// UI için Icon getter
  Icon get iconWidget => Icon(
        iconMap[iconName] ?? Icons.category,
      );

  IconData get iconData => iconMap[iconName] ?? Icons.category;
}
