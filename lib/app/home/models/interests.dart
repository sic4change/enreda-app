import 'package:enreda_app/app/home/models/dedication.dart';

class Interests {
  Interests({this.interests, this.specificInterests, this.surePurpose, this.continueLearning});
  final List<String>? interests;
  final List<String>? specificInterests;
  final Dedication? surePurpose;
  final String? continueLearning;

  factory Interests.fromMap(Map<String, dynamic> data, String documentId) {

    final Dedication? dedication = new Dedication(
        label: data['dedication']['label'],
        value: data['dedication']['value']
    );

    return Interests(
      interests: data['interests'],
      specificInterests: data['specificInterests'],
      surePurpose: dedication,
      continueLearning: data['continueLearning'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'interests': interests,
      'specificInterests': specificInterests,
      'surePurpose' : surePurpose?.toMap(),
      'continueLearning' : continueLearning,
    };
  }
}