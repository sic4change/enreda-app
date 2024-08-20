// TODO: Rename, this class refers to documentSubCategory
class PersonalDocumentType {
  PersonalDocumentType({
    required this.title,
    required this.order,
    required this.personalDocId,  // Refers to documentSubCategoryId
    required this.documentCategoryId,
  });

  final String title;
  final int order;
  final String personalDocId;
  final String documentCategoryId;

  factory PersonalDocumentType.fromMap(Map<String, dynamic> data, String documentId) {
    return PersonalDocumentType(
      title: data['title'] ?? "",
      order: data['order'] ?? 0, //TODO
      personalDocId: documentId,
      documentCategoryId: data['documentCategoryId'] ?? '',
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonalDocumentType &&
            other.personalDocId == personalDocId);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'order': order,
      'personalDocId': personalDocId,
      'documentCategoryId': documentCategoryId,
    };
  }
}