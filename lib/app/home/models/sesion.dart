/// Domain model for a Sesión.
///
/// Mirrors (exactly) the `Sesion` schema owned by the `enredaEntidadSocial`
/// técnico dashboard so both apps read/write the SAME Firestore `sesiones`
/// collection without contract drift. In `enreda-app` (participants) the model
/// is consumed READ-ONLY: a participant sees the sessions they were invited to
/// (`invitedParticipants` contains their `userId`).
///
/// Schema decisions (locked by product, owned by enredaEntidadSocial):
///   * `invitedParticipants` and `attendedParticipants` are **always** arrays
///     of user IDs, even for individual sessions (count = 1).
///   * `tecnicoId` is the user ID of the convener (social entity worker).
///   * `socialEntityId` is denormalized for cheap server-side filtering.
class Sesion {
  Sesion({
    this.sesionId,
    required this.tecnicoId,
    this.socialEntityId,
    required this.sessionType,
    required this.modality,
    required this.scheduledAt,
    this.fechaFin,
    this.isAllDay = false,
    required this.invitedParticipants,
    required this.attendedParticipants,
    this.title,
    this.description,
    this.observations,
    this.lugar,
    this.duracion,
    this.createIpil = false,
    this.competenciaCategoriaId,
    this.competenciaSubCategoriaId,
    this.createdAt,
    this.lastUpdated,
    this.absentParticipants = const <String>[],
    this.participantSubvenciones = const <String, String>{},
    this.reminderUserIds = const <String>[],
    this.confirmedParticipants = const <String>[],
  });

  /// Firestore document id.
  final String? sesionId;

  /// User id of the técnico (social entity worker) who convened the session.
  final String tecnicoId;

  /// Owning social entity id.
  final String? socialEntityId;

  /// `individual` | `grupal`. Drives the displayed row title.
  final String sessionType;

  /// `online` | `presencial` | `blended`. Drives the modality chip label.
  final String modality;

  /// When the session is/was scheduled to take place. Time component honoured
  /// unless [isAllDay] is true. Used to bucket into Próximas vs Pasadas.
  final DateTime scheduledAt;

  /// True when the session occupies the entire day rather than a specific hour.
  final bool isAllDay;

  /// Optional explicit end timestamp. When set, the gCal / ICS exports use it
  /// directly for the event's DTEND instead of deriving from `duracion`.
  final DateTime? fechaFin;

  /// IDs of invited participants. Always an array — even for individual
  /// sessions (length 1).
  final List<String> invitedParticipants;

  /// IDs of participants who actually attended. Always an array.
  final List<String> attendedParticipants;

  /// Optional user-supplied title override. Falls back to the default
  /// per-`sessionType` label in the UI when null/empty.
  final String? title;

  /// Long-form "Desarrollo y evaluación" body.
  final String? description;

  /// Long-form "Observaciones y/o incidencias" body.
  final String? observations;

  /// "Lugar de la actividad" — free-text venue / address.
  final String? lugar;

  /// "Duración" — free-text duration label (e.g. "2 horas", "90 min").
  final String? duracion;

  /// True when the convener flagged this session to also generate an IPIL.
  final bool createIpil;

  /// `Categoría de Competencias` selection.
  final String? competenciaCategoriaId;

  /// `Sub categoría de Competencias` selection.
  final String? competenciaSubCategoriaId;

  /// Created timestamp. Set on initial write.
  final DateTime? createdAt;

  /// Last-update timestamp. Set on every write.
  final DateTime? lastUpdated;

  /// Participants explicitly confirmed as absent. Always an array.
  final List<String> absentParticipants;

  /// Per-participant grant assignment captured at export time (técnico side).
  final Map<String, String> participantSubvenciones;

  /// User IDs who have opted into a reminder for this session.
  final List<String> reminderUserIds;

  /// Participants who confirmed they will attend ("Confirmar Asistencia").
  final List<String> confirmedParticipants;

  /// `true` when [scheduledAt] is today or in the future.
  bool get isUpcoming => !scheduledAt.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

  factory Sesion.fromMap(Map<String, dynamic> data, String documentId) {
    return Sesion(
      sesionId: data['sesionId']?.toString() ?? documentId,
      tecnicoId: data['tecnicoId']?.toString() ?? '',
      socialEntityId: data['socialEntityId']?.toString(),
      sessionType: data['sessionType']?.toString() ?? 'individual',
      modality: data['modality']?.toString() ?? 'presencial',
      scheduledAt: data['scheduledAt']?.toDate() ?? DateTime.now(),
      fechaFin: data['fechaFin']?.toDate(),
      isAllDay: data['isAllDay'] == true,
      invitedParticipants: _parseStringList(data['invitedParticipants']),
      attendedParticipants: _parseStringList(data['attendedParticipants']),
      title: data['title']?.toString(),
      description: data['description']?.toString(),
      observations: data['observations']?.toString(),
      lugar: data['lugar']?.toString(),
      duracion: data['duracion']?.toString(),
      createIpil: data['createIpil'] == true,
      competenciaCategoriaId: data['competenciaCategoriaId']?.toString(),
      competenciaSubCategoriaId: data['competenciaSubCategoriaId']?.toString(),
      createdAt: data['createdAt']?.toDate(),
      lastUpdated: data['lastUpdated']?.toDate(),
      absentParticipants: _parseStringList(data['absentParticipants']),
      participantSubvenciones:
          _parseStringStringMap(data['participantSubvenciones']),
      reminderUserIds: _parseStringList(data['reminderUserIds']),
      confirmedParticipants: _parseStringList(data['confirmedParticipants']),
    );
  }

  /// Safely parses a Firestore array field into a `List<String>`.
  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return <String>[];
    return [for (final item in raw as Iterable) item.toString()];
  }

  /// Safely parses a Firestore `Map` field into a `Map<String, String>`.
  static Map<String, String> _parseStringStringMap(dynamic raw) {
    if (raw == null) return const <String, String>{};
    final out = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v != null) out[k.toString()] = v.toString();
      });
    }
    return out;
  }

  Map<String, dynamic> toMap() {
    return {
      'sesionId': sesionId,
      'tecnicoId': tecnicoId,
      'socialEntityId': socialEntityId,
      'sessionType': sessionType,
      'modality': modality,
      'scheduledAt': scheduledAt,
      'fechaFin': fechaFin,
      'isAllDay': isAllDay,
      'invitedParticipants': invitedParticipants,
      'attendedParticipants': attendedParticipants,
      'title': title,
      'description': description,
      'observations': observations,
      'lugar': lugar,
      'duracion': duracion,
      'createIpil': createIpil,
      'competenciaCategoriaId': competenciaCategoriaId,
      'competenciaSubCategoriaId': competenciaSubCategoriaId,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
      'absentParticipants': absentParticipants,
      'participantSubvenciones': participantSubvenciones,
      'reminderUserIds': reminderUserIds,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Sesion &&
            other.sesionId == sesionId);
  }

  @override
  int get hashCode => sesionId?.hashCode ?? 0;
}

/// Allowed values for `Sesion.sessionType`.
class SesionType {
  static const String individual = 'individual';
  static const String grupal = 'grupal';
}

/// Allowed values for `Sesion.modality`.
class SesionModality {
  static const String online = 'online';
  static const String presencial = 'presencial';
  static const String blended = 'blended';
}
