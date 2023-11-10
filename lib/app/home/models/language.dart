class Language {
  Language({
    required this.name,
    required this.speakingLevel,
    required this.writingLevel,
  });

  final String name;
  final int speakingLevel;
  final int writingLevel;

  factory Language.fromMap(Map<String, dynamic> data, String documentId) {
    return Language(
      name: data['name']?? "",
      speakingLevel: data['speakingLevel']?? 1,
      writingLevel: data['writingLevel']?? 1,
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Language &&
            other.name == name);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'speakingLevel': speakingLevel,
      'writingLevel': writingLevel,
    };
  }
}