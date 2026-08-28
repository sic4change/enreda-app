/// Model representing a saved "favourite" version of a participant's CV.
///
/// Stores the user's ID and the snapshot of their selection (which experiences,
/// languages, competencies, etc. are included), plus a custom name and sector.
/// Personal data (name, email, photo, etc.) always comes from the live
/// [UserEnreda] profile — it is never duplicated here.
class FavouriteCV {
  FavouriteCV({
    this.favouriteCVId,
    required this.userId,
    required this.name,
    required this.sectorId,
    required this.sectorName,
    this.selectedExperienceIds = const [],
    this.selectedPersonalExperienceIds = const [],
    this.selectedEducationIds = const [],
    this.selectedSecondaryEducationIds = const [],
    this.selectedCompetencies = const [],
    this.selectedDataOfInterest = const [],
    this.selectedLanguageNames = const [],
    this.selectedReferenceIds = const [],
    this.aboutMe,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String? favouriteCVId;
  final String userId;
  final String name;
  final String sectorId;
  final String sectorName;

  /// IDs of [Experience] docs of type 'Profesional' to include.
  final List<String> selectedExperienceIds;

  /// IDs of [Experience] docs of type 'Personal' to include.
  final List<String> selectedPersonalExperienceIds;

  /// IDs of [Experience] docs of type 'Formativa' to include.
  final List<String> selectedEducationIds;

  /// IDs of [Experience] docs of type 'Complementaria' to include.
  final List<String> selectedSecondaryEducationIds;

  /// Names of competencies to include.
  final List<String> selectedCompetencies;

  /// Datos de interés strings to include.
  final List<String> selectedDataOfInterest;

  /// Language names to include.
  final List<String> selectedLanguageNames;

  /// IDs of [CertificationRequest] (references) to include.
  final List<String> selectedReferenceIds;

  /// "About me" text saved at the time of creation/last edit.
  final String? aboutMe;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ─── Firestore serialisation ──────────────────────────────────────────────

  factory FavouriteCV.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> _strings(dynamic raw) {
      if (raw == null) return const [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return const [];
    }

    return FavouriteCV(
      favouriteCVId: documentId,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      sectorId: data['sectorId'] as String? ?? '',
      sectorName: data['sectorName'] as String? ?? '',
      selectedExperienceIds: _strings(data['selectedExperienceIds']),
      selectedPersonalExperienceIds:
          _strings(data['selectedPersonalExperienceIds']),
      selectedEducationIds: _strings(data['selectedEducationIds']),
      selectedSecondaryEducationIds:
          _strings(data['selectedSecondaryEducationIds']),
      selectedCompetencies: _strings(data['selectedCompetencies']),
      selectedDataOfInterest: _strings(data['selectedDataOfInterest']),
      selectedLanguageNames: _strings(data['selectedLanguageNames']),
      selectedReferenceIds: _strings(data['selectedReferenceIds']),
      aboutMe: data['aboutMe'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'favouriteCVId': favouriteCVId,
      'userId': userId,
      'name': name,
      'sectorId': sectorId,
      'sectorName': sectorName,
      'selectedExperienceIds': selectedExperienceIds,
      'selectedPersonalExperienceIds': selectedPersonalExperienceIds,
      'selectedEducationIds': selectedEducationIds,
      'selectedSecondaryEducationIds': selectedSecondaryEducationIds,
      'selectedCompetencies': selectedCompetencies,
      'selectedDataOfInterest': selectedDataOfInterest,
      'selectedLanguageNames': selectedLanguageNames,
      'selectedReferenceIds': selectedReferenceIds,
      'aboutMe': aboutMe,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  FavouriteCV copyWith({
    String? favouriteCVId,
    String? userId,
    String? name,
    String? sectorId,
    String? sectorName,
    List<String>? selectedExperienceIds,
    List<String>? selectedPersonalExperienceIds,
    List<String>? selectedEducationIds,
    List<String>? selectedSecondaryEducationIds,
    List<String>? selectedCompetencies,
    List<String>? selectedDataOfInterest,
    List<String>? selectedLanguageNames,
    List<String>? selectedReferenceIds,
    String? aboutMe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavouriteCV(
      favouriteCVId: favouriteCVId ?? this.favouriteCVId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      sectorId: sectorId ?? this.sectorId,
      sectorName: sectorName ?? this.sectorName,
      selectedExperienceIds:
          selectedExperienceIds ?? this.selectedExperienceIds,
      selectedPersonalExperienceIds:
          selectedPersonalExperienceIds ?? this.selectedPersonalExperienceIds,
      selectedEducationIds: selectedEducationIds ?? this.selectedEducationIds,
      selectedSecondaryEducationIds:
          selectedSecondaryEducationIds ?? this.selectedSecondaryEducationIds,
      selectedCompetencies: selectedCompetencies ?? this.selectedCompetencies,
      selectedDataOfInterest:
          selectedDataOfInterest ?? this.selectedDataOfInterest,
      selectedLanguageNames:
          selectedLanguageNames ?? this.selectedLanguageNames,
      selectedReferenceIds: selectedReferenceIds ?? this.selectedReferenceIds,
      aboutMe: aboutMe ?? this.aboutMe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavouriteCV && other.favouriteCVId == favouriteCVId);

  @override
  int get hashCode => favouriteCVId.hashCode;
}
