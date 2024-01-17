import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

class CompetencySubCategory {
  CompetencySubCategory({
    this.competencyCategoryId,
    this.competencySubCategoryId,
    required this.name,
    required this.order
  });

  factory CompetencySubCategory.fromMap(Map<String, dynamic> data, String documentId) {
    return CompetencySubCategory(
      competencyCategoryId: data['competencyCategoryId']??"",
      competencySubCategoryId: data['competencySubCategoryId']??"",
      name: data["name"]??"",
      order: data['order']??0,
    );
  }

  final String? competencyCategoryId;
  final String? competencySubCategoryId;
  final String name;
  final int order;

  final ValueNotifier<bool> selected = ValueNotifier<bool>(false);

  Map<String, dynamic> toMap() {
    return {
      'competencyCategoryId': competencyCategoryId,
      'competencySubCategoryId': competencySubCategoryId,
      'name': name,
      'order':order,
    };
  }
}
