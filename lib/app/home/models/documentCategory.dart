class DocumentCategory {
  DocumentCategory({required this.name, required this.documentCategoryId, required this.order});

  factory DocumentCategory.fromMap(Map<String, dynamic>? data, String documentId) {
    final String name = data?['name'];
    final int order = data?['order'];
    final String documentCategoryId = documentId;

    return DocumentCategory(
      name: name,
      order: order,
      documentCategoryId: documentCategoryId,
    );
  }

  final String name;
  final String documentCategoryId;
  final int order;

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DocumentCategory &&
            other.documentCategoryId == documentCategoryId);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id' : documentCategoryId,
      'order' : order,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => documentCategoryId.hashCode;

}