import 'package:equatable/equatable.dart';

class Choice extends Equatable {
  Choice({
    required this.id,
    required this.name,
    this.order,
    this.competencies = const {},
    this.activities = const [],
    this.typeId,
    this.subtypeId,
  });

  final String id;
  final String name;
  final int? order;
  final Map<String, int> competencies;
  final List<String> activities;
  final String? typeId;
  final String? subtypeId;

  factory Choice.fromMap(Map<String, dynamic> data, String documentId) {
    final String id = data['id'] ?? documentId;
    final String name = data['name'] ?? '';
    final int? order = data['order'];
    final String? typeId = data['typeId'];
    final String? subtypeId = data['subtypeId'];

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
        activities: activities,
        typeId: typeId,
        subtypeId: subtypeId,
    );
  }

  @override
  List<Object?> get props => [id, name, order, typeId, subtypeId];

  @override
  bool get stringify => true;
}