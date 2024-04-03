class PersonalDocumentType {
  PersonalDocumentType({
    required this.title,
    required this.order,
    required this.personalDocId,
  });

  final String title;
  final int order;
  final String personalDocId;

  factory PersonalDocumentType.fromMap(Map<String, dynamic> data, String documentId) {
    return PersonalDocumentType(
      title: data['title'] ?? "",
      order: data['order'] ?? 0, //TODO
      personalDocId: data['personalDocId'] ?? '',
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
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}