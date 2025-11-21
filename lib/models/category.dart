import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon.codePoint,
      };

  static Category fromJson(Map<String, dynamic> json) => Category(
        name: json['name'],
        icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      );
}
