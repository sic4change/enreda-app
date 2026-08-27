class CompanionData {
  CompanionData({
    this.companionDataId,
    required this.userId,
    this.companionFamilySituation,
    this.companionDateArriveSpain,
    this.companionAdministrativeStatus,
    this.companionWorkPermit,
    this.companionWorkPermitRenewalDate,
    this.companionDocumentType,
    this.companionDocumentNumber,
    this.companionHelpNeeds = const [],
    this.companionHelpNeedsOther,
    this.companionContactSchedule = const [],
    this.companionProfessionalHelp,
    this.companionOtherRelevantData,
  });

  final String? companionDataId;
  final String userId;
  final String? companionFamilySituation;
  final String? companionDateArriveSpain;
  final String? companionAdministrativeStatus;
  final bool? companionWorkPermit;
  final String? companionWorkPermitRenewalDate;
  final String? companionDocumentType;
  final String? companionDocumentNumber;
  final List<String> companionHelpNeeds;
  final String? companionHelpNeedsOther;
  final List<String> companionContactSchedule;
  final bool? companionProfessionalHelp;
  final String? companionOtherRelevantData;

  factory CompanionData.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> helpNeeds = [];
    if (data['companionHelpNeeds'] != null) {
      data['companionHelpNeeds'].forEach((item) {
        helpNeeds.add(item.toString());
      });
    }

    List<String> contactSchedule = [];
    if (data['companionContactSchedule'] != null) {
      if (data['companionContactSchedule'] is List) {
        data['companionContactSchedule'].forEach((item) {
          contactSchedule.add(item.toString());
        });
      } else if (data['companionContactSchedule'] is String) {
        contactSchedule.add(data['companionContactSchedule'].toString());
      }
    }

    return CompanionData(
      companionDataId: documentId,
      userId: data['userId'] ?? '',
      companionFamilySituation: data['companionFamilySituation'],
      companionDateArriveSpain: data['companionDateArriveSpain'],
      companionAdministrativeStatus: data['companionAdministrativeStatus'],
      companionWorkPermit: data['companionWorkPermit'],
      companionWorkPermitRenewalDate: data['companionWorkPermitRenewalDate'],
      companionDocumentType: data['companionDocumentType'],
      companionDocumentNumber: data['companionDocumentNumber'],
      companionHelpNeeds: helpNeeds,
      companionHelpNeedsOther: data['companionHelpNeedsOther'],
      companionContactSchedule: contactSchedule,
      companionProfessionalHelp: data['companionProfessionalHelp'],
      companionOtherRelevantData: data['companionOtherRelevantData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'companionFamilySituation': companionFamilySituation,
      'companionDateArriveSpain': companionDateArriveSpain,
      'companionAdministrativeStatus': companionAdministrativeStatus,
      'companionWorkPermit': companionWorkPermit,
      'companionWorkPermitRenewalDate': companionWorkPermitRenewalDate,
      'companionDocumentType': companionDocumentType,
      'companionDocumentNumber': companionDocumentNumber,
      'companionHelpNeeds': companionHelpNeeds,
      'companionHelpNeedsOther': companionHelpNeedsOther,
      'companionContactSchedule': companionContactSchedule,
      'companionProfessionalHelp': companionProfessionalHelp,
      'companionOtherRelevantData': companionOtherRelevantData,
    };
  }
}
