class GamificationFlag {
  GamificationFlag({required this.id, required this.description, required this.iconEnabled, required this.iconDisabled, required this.order});

  factory GamificationFlag.fromMap(Map<String, dynamic> data, String documentId) {
    final String id = data['id'];
    final String description = data['description'];
    final String iconEnabled = data['iconEnabled'];
    final String iconDisabled = data['iconDisabled'];
    final int order = data['order'];

    return GamificationFlag(
      id: id,
      description: description,
      iconEnabled: iconEnabled,
      iconDisabled: iconDisabled,
      order: order,
    );
  }

  final String id;
  final String description;
  final String iconEnabled;
  final String iconDisabled;
  final int order;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description' : description,
      'iconEnabled' : iconEnabled,
      'iconDisabled' : iconDisabled,
      'order' : order,
    };
  }
}