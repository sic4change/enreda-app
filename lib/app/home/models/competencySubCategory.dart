class CompetencySubCategory {
  CompetencySubCategory({required this.name, required this.competencySubCategoryId, required this.order});

  factory CompetencySubCategory.fromMap(Map<String, dynamic>? data, String documentId) {
    final String name = data?['name'];
    final String competencySubCategoryId = data?['competencySubCategoryId'];
    final int order = data?['order'];

    return CompetencySubCategory(
        name: name,
        competencySubCategoryId: competencySubCategoryId,
        order: order,
    );
  }

  final String name;
  final String competencySubCategoryId;
  final int order;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'competencySubCategoryId' : competencySubCategoryId,
      'order' : order,
    };
  }

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompetencySubCategory &&
            other.competencySubCategoryId == competencySubCategoryId);
  }

  @override
  int get hashCode => super.hashCode;

}