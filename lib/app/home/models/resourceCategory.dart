class ResourceCategory {
  ResourceCategory({required this.name, required this.id, required this.order, required this.backgroundUrl});

  factory ResourceCategory.fromMap(Map<String, dynamic>? data, String documentId) {
    final String name = data?['name'];
    final String id = data?['id'];
    final String backgroundUrl = data?['backgroundUrl'];
    final int order = data?['order'];


    return ResourceCategory(
        name: name,
        id: id,
        order: order,
        backgroundUrl: backgroundUrl);
  }

  final String name;
  final String id;
  final int order;
  final String backgroundUrl;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id' : id,
      'order' : order,
      'backgroundUrl' : backgroundUrl
    };
  }
}