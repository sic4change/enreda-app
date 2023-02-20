import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:pdf/pdf.dart';

import '../../models/competency.dart';
import '../../models/experience.dart';
import 'data.dart';

import 'package:enreda_app/app/home/curriculum/pdf_generator/resume_mobile.dart'
if (dart.library.html) 'package:enreda_app/app/home/curriculum/pdf_generator/resume_web.dart' as my_worker;


const examples = <Example>[
  Example('Mi Currículum', 'resume_mobile.dart', my_worker.generateResume),
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
    List<String>? dataOfInterest,
    List<String>? languages,
    List<String>? competenciesNames,
    );

class Example {
  const Example(this.name, this.file, this.builder, [this.needsData = false]);

  final String name;

  final String file;

  final LayoutCallbackWithData builder;

  final bool needsData;
}
