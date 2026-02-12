import 'dart:async';
import 'package:enreda_app/app/home/curriculum/pdf_generator/data.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/models/language.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../values/strings.dart';
import '../../../../values/values.dart';
import '../../models/experience.dart';
import 'package:http/http.dart';

const PdfColor teal = PdfColor.fromInt(0xFF004D5E);
const PdfColor greyBody = PdfColor.fromInt(0xFF535A5F);
const PdfColor greyLight = PdfColor.fromInt(0xFFADADAD);
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);

const leftWidth = 200.0;
const rightWidth = 350.0;

Future<Uint8List> generateResumeTeal(
  PdfPageFormat format,
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
  List<String>? competenciesNames,
  List<Language>? languagesNames,
  String? aboutMe,
  List<String>? myDataOfInterest,
  String myCustomEmail,
  String myCustomPhone,
  bool myPhoto,
  List<CertificationRequest>? myReferences,
  String myMaxEducation,
) async {
  final doc = pw.Document(title: 'Mi Currículum');

  var url = user?.profilePic?.src ?? "";

  Future<Uint8List> imageFromUrl(String url) async {
    final uri = Uri.parse(url);
    final Response response = await get(uri);
    return response.bodyBytes;
  }

  Uint8List? myUint8List;
  if (url != "") {
    try {
      myUint8List = await imageFromUrl(url);
    } catch (_) {}
  }

  final profileImageWeb = url == "" || myUint8List == null
      ? pw.MemoryImage(
          (await rootBundle.load(ImagePath.USER_DEFAULT)).buffer.asUint8List(),
        )
      : pw.MemoryImage(myUint8List);

  PdfPageFormat format1 =
      format.applyMargin(left: 0, top: 0, right: 0, bottom: 0);

  final pageTheme = await _myPageTheme(format1);
  final DateFormat formatter = DateFormat('yyyy');

  final headerSvg =
      '<svg width="600" height="280"><path d="M0,0 L600,0 L600,280 L200,280 Q0,280 0,180 Z" fill="#004D5E" /></svg>';

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(
                top: 1.0 * PdfPageFormat.cm, bottom: 20, right: 30),
            child: pw.Text(
                'Pág. ${context.pageNumber} de ${context.pagesCount}',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (pw.Context context) => <pw.Widget>[
        // Header
        pw.Container(
          height: 280,
          child: pw.Stack(
            children: [
              pw.SvgImage(svg: headerSvg),
              // Profile Photo
              if (myPhoto)
                pw.Positioned(
                  left: 60,
                  top: 60,
                  child: pw.Container(
                    width: 140,
                    height: 140,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: white, width: 6),
                    ),
                    child: pw.ClipOval(
                      child: pw.Image(profileImageWeb, fit: pw.BoxFit.cover),
                    ),
                  ),
                ),
              // Name and About Me
              pw.Positioned(
                left: 230,
                top: 70,
                right: 40,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${user?.firstName?.toUpperCase() ?? ''}',
                      style: pw.TextStyle(
                        fontSize: 36,
                        color: white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${user?.lastName?.toUpperCase() ?? ''}',
                      style: pw.TextStyle(
                        fontSize: 24,
                        color: white,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      StringConst.ABOUT_ME.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      aboutMe ?? '',
                      maxLines: 4,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        pw.Partitions(
          children: [
            // Left Column
            pw.Partition(
              width: leftWidth,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(left: 30.0, right: 15.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 20),
                    // Datos Personales
                    _Category(title: StringConst.PERSONAL_DATA, color: teal),
                    _IconText(
                        iconData: 0xe0be, text: myCustomEmail, isLink: true),
                    _IconText(iconData: 0xe0b0, text: myCustomPhone),
                    _IconText(
                        iconData: 0xe8b4,
                        text:
                            '${city ?? ''}\n${province ?? ''}\n${country?.toUpperCase() ?? ''}'),

                    pw.SizedBox(height: 20),
                    // Referencias
                    if (myReferences != null && myReferences.isNotEmpty) ...[
                      _Category(title: StringConst.REFERENCES, color: teal),
                      for (var ref in myReferences)
                        _ReferenceBlock(
                          name: '${ref.certifierName}',
                          position: '${ref.certifierPosition}',
                          company: '${ref.certifierCompany}',
                          contact: '${ref.email} / ${ref.phone}',
                        ),
                    ],

                    pw.SizedBox(height: 20),
                    // Competencias
                    if (competenciesNames != null &&
                        competenciesNames.isNotEmpty) ...[
                      _Category(title: StringConst.COMPETENCIES, color: teal),
                      pw.Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: competenciesNames
                            .map((name) => _CompetencyChip(title: name))
                            .toList(),
                      ),
                    ],

                    pw.SizedBox(height: 20),
                    // Datos de Interés
                    if (myDataOfInterest != null &&
                        myDataOfInterest.isNotEmpty) ...[
                      _Category(
                          title: StringConst.DATA_OF_INTEREST, color: teal),
                      for (var item in myDataOfInterest)
                        _BulletItem(text: item),
                    ],

                    pw.SizedBox(height: 20),
                    // Idiomas
                    if (languagesNames != null &&
                        languagesNames.isNotEmpty) ...[
                      _Category(title: StringConst.LANGUAGES, color: teal),
                      for (var lang in languagesNames)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(
                            '${lang.name.toUpperCase()} | ${lang.speakingLevel == 1 ? 'PRINCIPIANTE' : lang.speakingLevel == 2 ? 'MEDIO' : 'AVANZADO'}',
                            style: const pw.TextStyle(
                                fontSize: 8, color: greyBody),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            // Right Column
            pw.Partition(
              width: rightWidth,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(left: 15.0, right: 30.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 20),
                    // Experiencias Profesionales
                    if (myExperiences != null && myExperiences.isNotEmpty) ...[
                      _TimelineCategory(
                          title: StringConst.MY_PROFESIONAL_EXPERIENCES,
                          color: teal),
                      for (var exp in myExperiences)
                        _ExperienceBlock(
                          title: exp.activity ?? '',
                          subtitle: '${exp.position} - ${exp.organization}',
                          date:
                              '${exp.startDate != null ? formatter.format(exp.startDate!.toDate()) : '-'} / ${exp.endDate != null ? formatter.format(exp.endDate!.toDate()) : 'Actualmente'}',
                          location: exp.location ?? '',
                          activities: exp.professionActivitiesText,
                        ),
                    ],

                    pw.SizedBox(height: 20),
                    // Experiencias Personales
                    if (myPersonalExperiences != null &&
                        myPersonalExperiences.isNotEmpty) ...[
                      _TimelineCategory(
                          title: StringConst.MY_PERSONAL_EXPERIENCES,
                          color: teal),
                      for (var exp in myPersonalExperiences)
                        _ExperienceBlock(
                          title: exp.activity ?? '',
                          subtitle: exp.organization ?? '',
                          date:
                              '${exp.startDate != null ? formatter.format(exp.startDate!.toDate()) : '-'} / ${exp.endDate != null ? formatter.format(exp.endDate!.toDate()) : 'Actualmente'}',
                          location: exp.location ?? '',
                        ),
                    ],

                    pw.SizedBox(height: 20),
                    // Formación
                    if (myEducation != null && myEducation.isNotEmpty) ...[
                      _TimelineCategory(
                          title: StringConst.EDUCATION, color: teal),
                      for (var edu in myEducation)
                        _ExperienceBlock(
                          title: edu.nameFormation ?? '',
                          subtitle: edu.institution ?? '',
                          date:
                              '${edu.startDate != null ? formatter.format(edu.startDate!.toDate()) : '-'} / ${edu.endDate != null ? formatter.format(edu.endDate!.toDate()) : 'Actualmente'}',
                          location: edu.location ?? '',
                        ),
                    ],

                    pw.SizedBox(height: 20),
                    // Cursos y Certificados
                    if (mySecondaryEducation != null &&
                        mySecondaryEducation.isNotEmpty) ...[
                      _TimelineCategory(
                          title: 'CURSOS Y CERTIFICADOS', color: teal),
                      for (var edu in mySecondaryEducation)
                        _ExperienceBlock(
                          title: edu.nameFormation ?? '',
                          subtitle: edu.institution ?? '',
                          date:
                              '${edu.startDate != null ? formatter.format(edu.startDate!.toDate()) : '-'} / ${edu.endDate != null ? formatter.format(edu.endDate!.toDate()) : 'Actualmente'}',
                          location: edu.location ?? '',
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  return pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.zero,
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.poppinsLight(),
      bold: await PdfGoogleFonts.poppinsBold(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
  );
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title, required this.color});
  final String title;
  final PdfColor color;
  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6, top: 10),
      child: pw.Text(title.toUpperCase(),
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: color, fontSize: 11)),
    );
  }
}

class _TimelineCategory extends pw.StatelessWidget {
  _TimelineCategory({required this.title, required this.color});
  final String title;
  final PdfColor color;
  @override
  pw.Widget build(pw.Context context) {
    return pw.Stack(
      alignment: pw.Alignment.centerLeft,
      children: [
        pw.Positioned(
          left: -20.5,
          child: pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              color: white,
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: greyLight, width: 1.5),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6, top: 10),
          child: pw.Text(title.toUpperCase(),
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: color, fontSize: 12)),
        ),
      ],
    );
  }
}

class _IconText extends pw.StatelessWidget {
  _IconText({required this.iconData, required this.text, this.isLink = false});
  final int iconData;
  final String text;
  final bool isLink;
  @override
  pw.Widget build(pw.Context context) {
    if (text.isEmpty) return pw.Container();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 14,
            height: 14,
            decoration:
                const pw.BoxDecoration(color: teal, shape: pw.BoxShape.circle),
            child: pw.Center(
                child: pw.Icon(pw.IconData(iconData), size: 8, color: white)),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: isLink
                ? pw.UrlLink(
                    destination: 'mailto:$text',
                    child: pw.Text(text,
                        style:
                            const pw.TextStyle(fontSize: 8, color: greyBody)))
                : pw.Text(text,
                    style: const pw.TextStyle(fontSize: 8, color: greyBody)),
          ),
        ],
      ),
    );
  }
}

class _ReferenceBlock extends pw.StatelessWidget {
  _ReferenceBlock(
      {required this.name,
      required this.position,
      required this.company,
      required this.contact});
  final String name, position, company, contact;
  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(name,
              style: const pw.TextStyle(fontSize: 9, color: greyBody)),
          pw.Text('${position.toUpperCase()} - ${company.toUpperCase()}',
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: greyBody)),
          pw.Text(contact,
              style: const pw.TextStyle(fontSize: 8, color: greyBody)),
        ],
      ),
    );
  }
}

class _CompetencyChip extends pw.StatelessWidget {
  _CompetencyChip({required this.title});
  final String title;
  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: teal,
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child:
          pw.Text(title, style: const pw.TextStyle(color: white, fontSize: 8)),
    );
  }
}

class _BulletItem extends pw.StatelessWidget {
  _BulletItem({required this.text});
  final String text;
  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ',
              style: const pw.TextStyle(fontSize: 10, color: greyBody)),
          pw.Expanded(
              child: pw.Text(text,
                  style: const pw.TextStyle(fontSize: 8, color: greyBody))),
        ],
      ),
    );
  }
}

class _ExperienceBlock extends pw.StatelessWidget {
  _ExperienceBlock(
      {required this.title,
      required this.subtitle,
      required this.date,
      required this.location,
      this.activities});
  final String title, subtitle, date, location;
  final String? activities;
  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$date - $location',
              style: const pw.TextStyle(fontSize: 8, color: greyLight)),
          pw.Text('$title'.toUpperCase(),
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: greyBody)),
          pw.Text(subtitle,
              style: const pw.TextStyle(fontSize: 9, color: greyBody)),
          if (activities != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                activities!.split(' / ').map((a) => '• $a').join('\n'),
                style: const pw.TextStyle(fontSize: 8, color: greyBody),
              ),
            ),
        ],
      ),
    );
  }
}
