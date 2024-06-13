import 'dart:async';

import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/language.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'data.dart';

import 'package:enreda_app/app/home/curriculum/pdf_generator/resume2_mobile.dart'
if (dart.library.html) 'package:enreda_app/app/home/curriculum/pdf_generator/resume2_web.dart' as my_cv;

const examples = <Example>[
  !kIsWeb ? Example('CV', 'resume2_mobile.dart', my_cv.generateResume2) : Example('CV', 'resume2_web.dart', my_cv.generateResume2),
];

typedef LayoutCallbackWithData = Future<Uint8List> Function(
    PdfPageFormat pageFormat,
    CustomData data,
    UserEnreda? user,
    String? city,
    String? province,
    String? country,
    List<Experience>? myExperiences,
    List<Experience>? myPersonalExperiences,
    List<Experience>? myEducation,
    List<Experience>? mySecondaryEducation,
    List<String>? idSelectedDateEducation,
    List<String>? idSelectedDateSecondaryEducation,
    List<String>? idSelectedDateExperience,
    List<String>? idSelectedDatePersonalExperience,
    List<String> competenciesNames,
    List<Language> languagesNames,
    String? aboutMe,
    List<String> myDataOfInterest,
    String myCustomEmail,
    String myCustomPhone,
    bool myPhoto,
    List<CertificationRequest>? myCustomReferences,
    String myMaxEducation,
    );

class Example {
  const Example(this.name, this.file, this.builder, [this.needsData = false]);

  final String name;

  final String file;

  final LayoutCallbackWithData builder;

  final bool needsData;
}
