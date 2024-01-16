import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

class CompetencyCategory {
  CompetencyCategory({
    this.id,
    required this.name,
    required this.order
  });

  factory CompetencyCategory.fromMap(Map<String, dynamic> data, String documentId) {
    return CompetencyCategory(
      id: data['id']??"",
      name: data["name"]??"",
      order: data['order']??0,
    );
  }

  final String? id;
  final String name;
  final int order;

  final ValueNotifier<bool> selected = ValueNotifier<bool>(false);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'order':order,
    };
  }
}
