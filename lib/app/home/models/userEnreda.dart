import 'package:enreda_app/app/home/models/addressUser.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/interestsUserEnreda.dart';
import 'package:enreda_app/app/home/models/language.dart';
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
    this.education,
    this.dataOfInterest = const [],
    this.languages = const [], // Deprecated
    this.languagesLevels = const [],
    this.aboutMe,
    this.points,
    this.points5CertifiedReceived,
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

    final Education education = new Education(
      label: data['education']['label'],
      value: data['education']['value'],
      order: data['education']['order'],
    );

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
    final int? points = data['points']?? 0;
    final bool? points5CertifiedReceived = data['points5CertifiedReceived']?? false;

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
      education: education,
      dataOfInterest: dataOfInterest,
      languages: languages,
      languagesLevels: languagesLevels,
      aboutMe: aboutMe,
      points: points,
      points5CertifiedReceived: points5CertifiedReceived,
    );
  }

  final String email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? userId;
  String? photo;
  final ProfilePic? profilePic;
  final Education? education;
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
  final int? points;
  final bool? points5CertifiedReceived;

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
      'education': education?.toMap(),
      'points': points,
      'points5CertifiedReceived': points5CertifiedReceived,
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
    Education? education,
    List<String>? dataOfInterest,
    List<String>? languages,
    List<Language>? languagesLevels,
    String? aboutMe,
    int? points,
    bool? points5CertifiedReceived,
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
      education: education ?? this.education,
      dataOfInterest: dataOfInterest ?? this.dataOfInterest,
      languages: languages ?? this.languages,
      languagesLevels: languagesLevels ?? this.languagesLevels,
      aboutMe: aboutMe ?? this.aboutMe,
      points: points ?? this.points,
      points5CertifiedReceived: points5CertifiedReceived ?? this.points5CertifiedReceived,
    );
  }
}
