class CompetencyCategory {
  CompetencyCategory({required this.name, required this.competencyCategoryId, required this.order, required this.competencySubCategories});

  factory CompetencyCategory.fromMap(Map<String, dynamic>? data, String documentId) {
    final String name = data?['name'];
    final String competencyCategoryId = data?['competencyCategoryId'];
    final int order = data?['order'];
    List<String> competencySubCategories = [];
    try {
      data?['competencySubCategories'].forEach((competencySubCategory) {competencySubCategories.add(competencySubCategory.toString());});
    } catch (e) {
    }


    return CompetencyCategory(
      name: name,
      competencyCategoryId: competencyCategoryId,
      order: order,
      competencySubCategories: competencySubCategories
    );
  }

  final String name;
  final String competencyCategoryId;
  final int order;
  final List<String> competencySubCategories;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'competencyCategoryId' : competencyCategoryId,
      'order' : order,
      'competencySubCategories' : competencySubCategories
    };
  }

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompetencyCategory &&
            other.competencyCategoryId == competencyCategoryId);
  }

  @override
  int get hashCode => super.hashCode;

}