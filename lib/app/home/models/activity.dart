class Activity {
  Activity({this.id, required this.name,
  });

  factory Activity.fromMap(Map<String, dynamic> data, String documentId) {
    final String id = data['id'];
    final String name = data['name'];

    return Activity(
      id: id,
      name: name,
    );
  }

  final String? id;
  final String name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}