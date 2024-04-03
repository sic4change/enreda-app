class PersonalDocument {
  PersonalDocument({
    required this.name,
    required this.order,
    required this.document,
  });

  final String name;
  final int order;
  final String document;

  factory PersonalDocument.fromMap(Map<String, dynamic> data, String documentId) {
    return PersonalDocument(
      name: data['name'] ?? "",
      order: data['order'] ?? 0, //TODO
      document: data['document'] ?? '',
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonalDocument &&
            other.name == name);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'order': order,
      'document': document,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}