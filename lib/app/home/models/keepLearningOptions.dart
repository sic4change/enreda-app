class KeepLearningOption {
  KeepLearningOption({required this.keepLearningOptionId, required this.title, required this.order});

  final String keepLearningOptionId;
  final String title;
  final int order;

  factory KeepLearningOption.fromMap(Map<String, dynamic> data, String documentId) {
    return KeepLearningOption(
      keepLearningOptionId: data['keepLearningOptionId'],
      title: data['title'],
      order: data['order'],
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is KeepLearningOption &&
            other.keepLearningOptionId == keepLearningOptionId);
  }

  Map<String, dynamic> toMap() {
    return {
      'keepLearningOptionId': keepLearningOptionId,
      'title': title,
      'order': order,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}