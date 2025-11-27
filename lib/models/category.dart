import 'package:flutter/widgets.dart';

class Category {
  final String name;
  final int iconCode;
  final String iconFamily;

  Category({
    required this.name,
    required this.iconCode,
    this.iconFamily = 'MaterialIcons',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'iconCode': iconCode,
        'iconFamily': iconFamily,
      };

  static Category fromJson(Map<String, dynamic> json) => Category(
        name: json['name'],
        iconCode: json['iconCode'],
        iconFamily: json['iconFamily'] ?? 'MaterialIcons',
      );

  /// UI'de Icon göstermek için helper
  Icon get iconWidget => Icon(
        IconData(iconCode, fontFamily: iconFamily),
      );
}
