class DocumentationParticipant {
  DocumentationParticipant({
    this.documentationParticipantId,
    required this.name,
    required this.userId,
    required this.createDate,
    required this.documentCategoryId,
    required this.documentSubCategoryId,
    this.renovationDate,
    this.urlDocument,
    this.nameDocument,
    this.createdBy,
  });

  final String? documentationParticipantId;
  final String name;
  final String userId;
  final DateTime createDate;
  final DateTime? renovationDate;
  final String documentCategoryId;
  final String documentSubCategoryId;
  final String? urlDocument;
  final String? nameDocument;
  final String? createdBy;

  factory DocumentationParticipant.fromMap(Map<String, dynamic> data, String documentId) {

    String? urlDocument;
    try {
      urlDocument = data['file']['src'];
    } catch (e) {
      urlDocument = '';
    }

    String? nameDocument;
    try {
      nameDocument = data['file']['title'];
    } catch (e) {
      nameDocument = '';
    }

    return DocumentationParticipant(
      documentationParticipantId: data['documentationParticipantId'],
      name: data['name'],
      userId: data['userId'],
      createdBy: data['createdBy'],
      createDate: DateTime.parse(data['createDate'].toDate().toString()),
      documentCategoryId: data['documentCategoryId'],
      documentSubCategoryId: data['documentSubCategoryId'],
      renovationDate: data['renovationDate'] != null ? DateTime.parse(data['renovationDate'].toDate().toString()) : null,
      urlDocument: urlDocument,
      nameDocument: nameDocument,
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DocumentationParticipant &&
            other.documentationParticipantId == documentationParticipantId);
  }

  Map<String, dynamic> toMap() {
    return {
      'documentationParticipantId': documentationParticipantId,
      'name': name,
      'userId': userId,
      'createdBy': createdBy,
      'createDate': createDate,
      'renovationDate': renovationDate,
      'documentCategoryId': documentCategoryId,
      'documentSubCategoryId': documentSubCategoryId,
    };
  }

  DocumentationParticipant copyWith({
    String? documentationParticipantId,
    String? name,
    String? userId,
    String? createdBy,
    DateTime? createDate,
    DateTime? renovationDate,
    String? documentCategoryId,
    String? documentSubCategoryId,

  }) {
    return DocumentationParticipant(
      documentationParticipantId: documentationParticipantId?? this.documentationParticipantId,
      name: name?? this.name,
      userId: userId?? this.userId,
      createdBy: createdBy?? this.createdBy,
      createDate: createDate?? this.createDate,
      documentCategoryId: documentCategoryId?? this.documentCategoryId,
      documentSubCategoryId: documentSubCategoryId?? this.documentSubCategoryId,
      renovationDate: renovationDate?? this.renovationDate,
    );
  }

}