import 'package:equatable/equatable.dart';

class Choice extends Equatable {
  Choice({
    required this.id,
    required this.name,
    this.order,
    this.competencies = const {},
    this.activities = const []
  });

  final String id;
  final String name;
  final int? order;
  final Map<String, int> competencies;
  final List<String> activities;

  factory Choice.fromMap(Map<String, dynamic> data, String documentId) {
    final String id = data['id'];
    final String name = data['name'];
    final int? order = data['order'];

    Map<String, int> competencies = {};
    if (data['competencies'] != null) {
      data['competencies'].forEach((competency) {
        competencies[competency['competencyId']] = competency['points'];
      });
    }

    List<String> activities = [];
    if (data['activities'] != null) {
      data['activities'].forEach((activityId) {
        activities.add(activityId);
      });
    }

    return Choice(
        id: id,
        name: name,
        order: order,
        competencies: competencies,
        activities: activities
    );
  }

  @override
  List<Object?> get props => [id, name];

  @override
  bool get stringify => true;
}