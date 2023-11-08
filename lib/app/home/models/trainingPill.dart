class TrainingPill {
  TrainingPill({
    required this.title,
    required this.description,
    required this.status,
    required this.id,
    required this.trainingPillCategory,
    this.trainingPillCategoryName,
    required this.order,
    required this.urlVideo,
    required this.placeholderImage,
    required this.likes,
  });

  factory TrainingPill.fromMap(Map<String, dynamic>? data, String documentId) {
    final String title = data?['title'];
    final String description = data?['description'];
    final String status = data?['status'];
    final String id = data?['id'];
    final String trainingPillCategory = data?['trainingPillCategory'];
    final String? trainingPillCategoryName = data?['trainingPillCategoryName'];
    final String urlVideo = data?['urlVideo'];
    final String placeholderImage = data?['placeholderImage'];
    final int order = data?['order'];
    List<String> likes = [];
    if (data?['likes'] != null) {
      data?['likes'].forEach((like) {likes.add(like.toString());});
    }

    return TrainingPill(
        title: title,
        description: description,
        status: status,
        id: id,
        trainingPillCategory: trainingPillCategory,
        trainingPillCategoryName: trainingPillCategoryName,
        order: order,
        urlVideo: urlVideo,
        placeholderImage: placeholderImage,
        likes: likes
    );
  }

  final String title;
  final String description;
  final String status;
  final String id;
  final String trainingPillCategory;
  String? trainingPillCategoryName;
  final int order;
  final String urlVideo;
  final String placeholderImage;
  final List<String> likes;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'id' : id,
      'trainingPillCategory' : trainingPillCategory,
      'trainingPillCategoryName' : trainingPillCategoryName,
      'order' : order,
      'urlVideo' : urlVideo,
      'placeholderImage' : placeholderImage,
      'likes' : likes
    };
  }
  void setTrainingPillCategoryName() {
    switch(this.trainingPillCategory) {
      case 'qYNh55gdfU84ZqoUnGap': {
        this.trainingPillCategoryName = 'Vídeo';
      }
      break;

      case 'iZIMrgGqAdtt2NeM9BEU': {
        this.trainingPillCategoryName = 'Artículo';
      }
      break;
    }
  }

}
