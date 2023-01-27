import 'package:enreda_app/app/home/models/addressUser.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/interestsUserEnreda.dart';
import 'package:enreda_app/app/home/models/profilepic.dart';
import 'package:flutter/material.dart';

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
    this.specificInterests: const [],
    this.interests: const [],
    this.abilities,
    this.unemployedType,
    this.role,
    this.showChatWelcome,
    this.competencies: const {},
    this.education,
    this.dataOfInterest: const [],
    this.languages: const [],
    this.aboutMe,
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
      print('user not abilities');
    }

    List<String> interests = [];
    try {
      data['interests']['interests'].forEach((interest) {
        interests.add(interest.toString());
      });
    } catch (e) {
      print('user not intersts');
    }

    List<String> specificInterests = [];
    try {
      data['interests']['specificInterests'].forEach((specificInterest) {
        specificInterests.add(specificInterest.toString());
      });
    } catch (e) {
      print('user not specific intersts');
    }

    final ProfilePic profilePic =
        new ProfilePic(src: photo, title: 'photo.jpg');
    final Address address = new Address(
        country: country,
        province: province,
        city: city,
        postalCode: postalCode);

    final bool? showChatWelcome = data['showChatWelcome'];

    Map<String, String> competencies = {};
    if (data['competencies'] != null) {
      (data['competencies'] as Map<String, dynamic>).forEach((key, value) {
        competencies[key] = value;
      });
    }

    String? education;
    try {
      education = data['education']['value'];
    } catch (e) {
      print('user does not have education data');
    }

    List<String> dataOfInterest = [];
    try {
      data['dataOfInterest'].forEach((interest) {
        dataOfInterest.add(interest.toString());
      });
    } catch (e) {
      print('user does not have data of interest');
    }

    List<String> languages = [];
    try {
      data['languages'].forEach((language) {
        languages.add(language.toString());
      });
    } catch (e) {
      print('user does not have languages');
    }

    final String? aboutMe = data['aboutMe'];

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
      showChatWelcome: showChatWelcome,
      competencies: competencies,
      education: education,
      dataOfInterest: dataOfInterest,
      languages: languages,
      aboutMe: aboutMe,
    );
  }

  final String email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? userId;
  String? photo;
  final ProfilePic? profilePic;
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
  final String? role;
  bool? showChatWelcome;
  final Map<String, String> competencies;
  final String? education;
  final List<String> dataOfInterest;
  final List<String> languages;
  final String? aboutMe;

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
      'role': role,
      'unemployedType': unemployedType,
      'showChatWelcome': showChatWelcome,
      'competencies': competencies,
      'dataOfInterest': dataOfInterest,
      'languages': languages,
      'aboutMe': aboutMe,
      /*'education.label': education,
      'education.value': education,*/
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
    String? education,
    List<String>? dataOfInterest,
    List<String>? languages,
    String? aboutMe,
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
      aboutMe: aboutMe ?? this.aboutMe,
    );
  }
}
