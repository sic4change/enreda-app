import 'package:enreda_app/app/home/models/addressUser.dart';
import 'package:enreda_app/app/home/models/interestsUserEnreda.dart';
import 'package:enreda_app/app/home/models/language.dart';
import 'package:enreda_app/app/home/models/motivation.dart';
import 'package:enreda_app/app/home/models/personalDocument.dart';
import 'package:enreda_app/app/home/models/profilepic.dart';

class UserEnreda {
  UserEnreda({
    required this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.userId,
    this.profilePic,
    this.photo,
    this.phone,
    this.birthday,
    this.country,
    this.province,
    this.city,
    this.postalCode,
    this.address,
    this.specificInterests = const [],
    this.interests = const [],
    this.abilities,
    this.certifications,
    this.unemployedType,
    this.role,
    this.showChatWelcome,
    this.competencies = const {},
    this.educationId,
    this.dataOfInterest = const [],
    this.languages = const [], // Deprecated
    this.languagesLevels = const [],
    this.aboutMe,
    this.resourcesAccessCount,
    this.checkAgreeCV,
    this.gamificationFlags = const {},
    this.nationality,
    this.assignedEntityId,
    this.motivation,
    this.personalDocuments = const [],
  });

  factory UserEnreda.fromMap(Map<String, dynamic> data, String documentId) {
    final String email = data['email'];
    final String? firstName = data['firstName'];
    final String? lastName = data['lastName'];
    final String? gender = data['gender'];
    final String? userId = data['userId'];
    final String? unemployedType = data['unemployedType'];
    final String? role = data['role'];
    String photo;
    try {
      photo = data['profilePic']['src'];
    } catch (e) {
      photo = '';
    }
    final String? phone = data['phone'];
    final DateTime? birthday =
        DateTime.parse(data['birthday'].toDate().toString());
    final String? country = data['address']['country'];
    final String? province = data['address']['province'];
    final String? city = data['address']['city'];
    final String? postalCode = data['address']['postalCode'];

    List<String> abilities = [];
    try {
      data['motivation']['abilities'].forEach((ability) {
        abilities.add(ability.toString());
      });
    } catch (e) {
      //print('user not abilities');
    }

    List<String> interests = [];
    try {
      data['interests']['interests'].forEach((interest) {
        interests.add(interest.toString());
      });
    } catch (e) {
      //print('user not intersts');
    }

    List<String> specificInterests = [];
    try {
      data['interests']['specificInterests'].forEach((specificInterest) {
        specificInterests.add(specificInterest.toString());
      });
    } catch (e) {
      //print('user not specific intersts');
    }

    List<String> certifications = [];
    try {
      data['certifications'].forEach((certification) {certifications.add(certification.toString());});
    } catch (e) {
      //print('user does not have certifications');
    }

    final ProfilePic profilePic = new ProfilePic(src: photo, title: 'photo.jpg');
    final Address address = new Address(
        country: country,
        province: province,
        city: city,
        postalCode: postalCode);

    final String educationId = data['educationId']?? "";

    final bool? showChatWelcome = data['showChatWelcome'];

    Map<String, String> competencies = {};
    if (data['competencies'] != null) {
      (data['competencies'] as Map<String, dynamic>).forEach((key, value) {
        competencies[key] = value;
      });
    }

    List<String> dataOfInterest = [];
    try {
      data['dataOfInterest'].forEach((interest) {
        dataOfInterest.add(interest.toString());
      });
    } catch (e) {
      //print('user does not have data of interest');
    }

    List<String> languages = [];
    try {
      data['languages'].forEach((language) {
        languages.add(language.toString());
      });
    } catch (e) {
    }

    List<Language> languagesLevels = [];
    if (data['languagesLevels'] != null) {
      data['languagesLevels'].forEach((languageLevel) {
        final languageLevelFirestore = languageLevel as Map<String, dynamic>;
        languagesLevels.add(
            Language(
                name: languageLevelFirestore['name']?? "",
                speakingLevel: languageLevelFirestore['speakingLevel']?? 1,
                writingLevel: languageLevelFirestore['writingLevel']?? 1,
            )
        );
      });
    }

    final String? aboutMe = data['aboutMe'];
    final int resourcesAccessCount = data['resourcesAccessCount']?? 0;
    final bool? checkAgreeCV = data['checkAgreeCV'];

    Map<String, bool> gamificationFlags = {};
    if (data['gamificationFlags'] != null) {
      (data['gamificationFlags'] as Map<String, dynamic>).forEach((key, value) {
        gamificationFlags[key] = value as bool;
      });
    }

    final String? nationality = data['nationality'];
    final String? assignedEntityId = data['assignedEntityId'];

    final Motivation? motivation = new Motivation(
        abilities: abilities,
        dedication: data['dedication'],
        timeSearching: data['timeSearching'],
        timeSpentWeekly: data['timeSpentWeekly']
    );

    List<PersonalDocument> personalDocuments = [];
    if (data['personalDocuments'] != null) {
      data['personalDocuments'].forEach((personalDocument) {
        final personalDocumentsFirestore = personalDocument as Map<String, dynamic>;
        personalDocuments.add(
            PersonalDocument(
              name: personalDocumentsFirestore['name'] ?? '',
              order: personalDocumentsFirestore['order'] ?? 0,
              document: personalDocumentsFirestore['document'] ?? '',
            )
        );
      });
    }

    return UserEnreda(
      email: email,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      userId: userId,
      photo: photo,
      profilePic: profilePic,
      phone: phone,
      birthday: birthday,
      country: country,
      province: province,
      city: city,
      address: address,
      postalCode: postalCode,
      specificInterests: specificInterests,
      interests: interests,
      unemployedType: unemployedType,
      role: role,
      abilities: abilities,
      certifications: certifications,
      showChatWelcome: showChatWelcome,
      competencies: competencies,
      educationId: educationId,
      dataOfInterest: dataOfInterest,
      languages: languages,
      languagesLevels: languagesLevels,
      aboutMe: aboutMe,
      resourcesAccessCount: resourcesAccessCount,
      checkAgreeCV: checkAgreeCV,
      gamificationFlags: gamificationFlags,
      nationality: nationality,
      assignedEntityId: assignedEntityId,
      motivation: motivation,
      personalDocuments: personalDocuments,
    );
  }

  final String email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? userId;
  String? photo;
  final ProfilePic? profilePic;
  final String? educationId;
  final String? phone;
  final DateTime? birthday;
  final String? country;
  final String? province;
  final String? city;
  final String? postalCode;
  final Address? address;
  final List<String> interests;
  final List<String> specificInterests;
  final String? unemployedType;
  final List<String>? abilities;
  final List<String>? certifications;
  final String? role;
  bool? showChatWelcome;
  final Map<String, String> competencies;
  final List<String> dataOfInterest;
  final List<String> languages;
  final List<Language> languagesLevels;
  final String? aboutMe;
  final int? resourcesAccessCount;
  final bool? checkAgreeCV;
  final Map<String, bool> gamificationFlags;
  final String? nationality;
  final String? assignedEntityId;
  final Motivation? motivation;
  final List<PersonalDocument> personalDocuments;

  Map<String, dynamic> toMap() {
    InterestsUserEnreda interestUserEnreda = InterestsUserEnreda(
        interests: interests, specificInterests: specificInterests);
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'userId': userId,
      //'profilePic': profilePic.toMap(),
      'phone': phone,
      'birthday': birthday,
      'address': address?.toMap(),
      'interests': interestUserEnreda.toMap(),
      'unemployedType': unemployedType,
      'abilities': abilities,
      'certifications': certifications,
      'role': role,
      'unemployedType': unemployedType,
      'showChatWelcome': showChatWelcome,
      'competencies': competencies,
      'dataOfInterest': dataOfInterest,
      'languages': languages,
      'languagesLevels': languagesLevels.map((e) => e.toMap()).toList(),
      'aboutMe': aboutMe,
      'resourcesAccessCount': resourcesAccessCount,
      'checkAgreeCV': checkAgreeCV,
      'gamificationFlags': gamificationFlags,
      'educationId': educationId,
      'nationality': nationality,
      'assignedEntityId': assignedEntityId,
      'motivation': motivation?.toMap(),
      'personalDocuments': personalDocuments.map((e) => e.toMap()).toList(),
    };
  }

  void updateShowChatWelcome(bool newValue) {
    showChatWelcome = newValue;
  }

  UserEnreda copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? userId,
    ProfilePic? profilePic,
    String? photo,
    String? phone,
    DateTime? birthday,
    String? country,
    String? province,
    String? city,
    String? postalCode,
    Address? address,
    List<String>? specificInterests,
    List<String>? interests,
    List<String>? abilities,
    String? unemployedType,
    String? role,
    bool? showChatWelcome,
    Map<String, String>? competencies,
    String? educationId,
    List<String>? dataOfInterest,
    List<String>? languages,
    List<Language>? languagesLevels,
    String? aboutMe,
    int? resourcesAccessCount,
    bool? checkAgreeCV,
    Map<String, bool>? gamificationFlags,
    String? nationality,
    String? assignedEntityId,
    Motivation? motivation,
    List<PersonalDocument>? personalDocuments,
  }) {
    return UserEnreda(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      userId: userId ?? this.userId,
      profilePic: profilePic ?? this.profilePic,
      photo: photo ?? this.photo,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      country: country ?? this.country,
      province: province ?? this.province,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      address: address ?? this.address,
      specificInterests: specificInterests ?? this.specificInterests,
      interests: interests ?? this.interests,
      abilities: abilities ?? this.abilities,
      unemployedType: unemployedType ?? this.unemployedType,
      role: role ?? this.role,
      showChatWelcome: showChatWelcome ?? this.showChatWelcome,
      competencies: competencies ?? this.competencies,
      educationId: educationId ?? this.educationId,
      dataOfInterest: dataOfInterest ?? this.dataOfInterest,
      languages: languages ?? this.languages,
      languagesLevels: languagesLevels ?? this.languagesLevels,
      aboutMe: aboutMe ?? this.aboutMe,
      resourcesAccessCount: resourcesAccessCount ?? this.resourcesAccessCount,
      checkAgreeCV: checkAgreeCV ?? this.checkAgreeCV,
      gamificationFlags: gamificationFlags ?? this.gamificationFlags,
      nationality: nationality ?? this.nationality,
      assignedEntityId: assignedEntityId ?? this.assignedEntityId,
      motivation: motivation ?? this.motivation,
      personalDocuments: personalDocuments ?? this.personalDocuments,
    );
  }

  static const String FLAG_SIGN_UP = "iIcnoLQfpVs7MmDzRGg7";
  static const String FLAG_PILL_WHAT_IS_ENREDA = "9tnftkYhk6xNUzokdi88";
  //static const String FLAG_PILL_TRAVEL_BEGINS = "X1Lzl17lvipjLRfXkXyB";
  static const String FLAG_PILL_COMPETENCIES = "08IEuCZq5ZpSihRHolTw";
  static const String FLAG_CHAT = "sfEkAorz3lEPflUwmfKv";
  static const String FLAG_EVALUATE_COMPETENCY = "7pFCCgX4X67ps2K3Mx0o";
  static const String FLAG_PILL_CV_COMPETENCIES = "0OSUTbLQWbQav69HBBPa";
  static const String FLAG_PILL_HOW_TO_DO_CV = "jw5RlKNEbCMeSZIwhrfo";
  static const String FLAG_CV_FORMATION = "jKZDpf8eb9iLsruDJr2H";
  static const String FLAG_CV_COMPLEMENTARY_FORMATION = "FIzQqM0tXwZoIH1V9CSP";
  static const String FLAG_CV_PERSONAL = "EDZWlWGf1IbAmQfB1TBU";
  static const String FLAG_CV_PROFESSIONAL = "PMpPOn5hMZCJR1qdU4sW";
  static const String FLAG_CV_ABOUT_ME = "KhDJqMIR6du9t4zOjKTx";
  static const String FLAG_CV_DATA_OF_INTEREST = "c6h0owyqz66P6MqbrSB6";
  static const String FLAG_CV_PHOTO = "fjr17WGx5vegzNHc9RWY";
  static const String FLAG_JOIN_RESOURCE = "oreFRQYdp5TNusvu3ubK";
}
