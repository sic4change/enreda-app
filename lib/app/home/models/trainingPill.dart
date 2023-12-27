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
    required this.duration,
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
    final String duration = data?['duration'];
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
        duration: duration,
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
  final List<String> likes;
  final String duration;

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
      'likes' : likes,
      'duration' : duration
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

  static const String TRAVEL_BEGINS_ID = "4nggROI8bvWlOjFq45he";
  static const String JOB_INTERVIEW_ID = "IM0OWIcMfiX63Ed6THsH";
  static const String WHAT_ARE_COMPETENCIES_ID = "JeuiHzJMFb4p8W3CWanR";
  static const String CV_COMPETENCIES_ID = "KVlxl5T38VxWR278UTw8";
  static const String HOW_TO_DO_CV_ID = "R5Svduj5z1Wux0kcdQRd";
  static const String WHAT_IS_ENREDA_ID = "RSZTAJ8gzW2ZV4JRAzz9";
  static const String DONT_LOSE_MOTIVATION_ID = "U4s8A3Y5EUjiixYTc57s";
  static const String SPANISH_WELFARE_SYSTEM_ID = "W0yXbW5i1CGvPZq3r9ce";

}
