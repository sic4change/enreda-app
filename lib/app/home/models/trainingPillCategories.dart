class TrainingPillCategory {
  TrainingPillCategory({required this.name, required this.id, required this.order});

  factory TrainingPillCategory.fromMap(Map<String, dynamic>? data, String documentId) {
    final String name = data?['name'];
    final String id = data?['id'];
    final int order = data?['order'];


    return TrainingPillCategory(
      name: name,
      id: id,
      order: order,
    );
  }

  final String name;
  final String id;
  final int order;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id' : id,
      'order' : order,
    };
  }
}