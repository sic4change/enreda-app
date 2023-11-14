class UserPoints {
  UserPoints({
    required this.id,
    required this.title,
    required this.description,
    required this.message,
    required this.points,
    required this.showPopup,
  });

  factory UserPoints.fromMap(Map<String, dynamic> data, String documentId) {
    final String id = data['id'];
    final String title = data['title'];
    final String description = data['description']?? "";
    final String message = data['message']?? "";
    final int points = data['points']?? 0;
    final bool showPopup = data['showPopup']?? false;

    return UserPoints(
        id: id,
        title: title,
        description: description,
        message: message,
        points: points,
        showPopup: showPopup
    );
  }

  final String id;
  final String title;
  final String description;
  final String message;
  final int points;
  final bool showPopup;

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'title': title,
      'description': description,
      'message': message,
      'points': points,
      'showPopup': showPopup,
    };
  }

  static const String ACCESS_ID = "jWuQfDYscjgCBbqDpB5P";
  static const String SIGN_UP_ID = "bdWYX9kC6zL3XEQPiWzN";
  static const String UPDATE_CV_ID = "Mk2p3HdKVJICxGOusYQJ";
}
