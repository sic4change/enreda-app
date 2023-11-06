import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import '../../models/experience.dart';
import 'data.dart';

import 'package:enreda_app/app/home/curriculum/pdf_generator/resume1_mobile.dart'
if (dart.library.html) 'package:enreda_app/app/home/curriculum/pdf_generator/resume1_web.dart' as my_worker;

import 'package:enreda_app/app/home/curriculum/pdf_generator/resume2_mobile.dart'
if (dart.library.html) 'package:enreda_app/app/home/curriculum/pdf_generator/resume2_web.dart' as my_worker;

import 'package:enreda_app/app/home/curriculum/pdf_generator/resume3_mobile.dart'
if (dart.library.html) 'package:enreda_app/app/home/curriculum/pdf_generator/resume3_web.dart' as my_worker;

const examples = <Example>[
  !kIsWeb ? Example('Modelo 1', 'resume1_mobile.dart', my_worker.generateResume1) : Example('Modelo 1', 'resume1_web.dart', my_worker.generateResume1),
  !kIsWeb ? Example('Modelo 2', 'resume2_mobile.dart', my_worker.generateResume2) : Example('Modelo 2', 'resume2_web.dart', my_worker.generateResume2),
  !kIsWeb ? Example('Modelo 3', 'resume3_mobile.dart', my_worker.generateResume3) : Example('Modelo 3', 'resume3_web.dart', my_worker.generateResume3),
  //!kIsWeb ? Example('Modelo 3', 'resume_mobile.dart', my_worker.generateResume) : Example('Modelo 3', 'resume_web.dart', my_worker.generateResume),
];

typedef LayoutCallbackWithData = Future<Uint8List> Function(
    PdfPageFormat pageFormat,
    CustomData data,
    UserEnreda? user,
    String? city,
    String? province,
    String? country,
    List<Experience>? myExperiences,
    List<Experience>? myEducation,
    List<String> competenciesNames,
    List<String> languagesNames,
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
