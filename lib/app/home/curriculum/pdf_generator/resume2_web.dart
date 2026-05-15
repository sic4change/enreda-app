import 'dart:async';
import 'package:enreda_app/app/home/curriculum/pdf_generator/data.dart';
import 'package:enreda_app/app/home/curriculum/pdf_generator/resume_purple_web.dart';
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

const PdfColor teal = PdfColor.fromInt(0xFF004D5E); // Primary
const PdfColor tealLight = PdfColor.fromInt(0xFF054D5E); // Chips/Accents
const PdfColor greyBody = PdfColor.fromInt(0xFF535A5F);
const PdfColor greyLight = PdfColor.fromInt(0xFFADADAD);
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);

const leftWidth = 212.0;
const rightWidth = 383.0; // 595 - 212 = 383
const double headerHeight = 250.0;
const double headerHeightDivider = 255.0;
const double dividerLeftPos = 212.0; // Updated to approx width/2.8 for A4

Future<Uint8List> generateResume2(
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
  List<String> competenciesNames,
  List<Language> languagesNames,
  String? aboutMe,
  List<String> myDataOfInterest,
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

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      header: (pw.Context context) {
        return pw.SizedBox(height: 30); // Standard padding for all pages top
      },
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
        // Header Content for Page 1
        pw.Container(
          height: headerHeight,
          padding: const pw.EdgeInsets.only(top: 20, left: 30, right: 30),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left: Names and About Me
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${user?.firstName?.toUpperCase() ?? ''}',
                      style: pw.TextStyle(
                        fontSize: 36,
                        color: teal,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${user?.lastName?.toUpperCase() ?? ''}',
                      style: pw.TextStyle(
                        fontSize: 24,
                        color: teal,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                    if (aboutMe != null && aboutMe.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 20),
                      pw.Text(
                        StringConst.ABOUT_ME.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: teal,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        aboutMe,
                        maxLines: 4,
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: greyBody,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Right: Photo
              if (myPhoto)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 5),
                  child: pw.Container(
                      width: 152,
                      height: 152,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: teal, width: 0.75),
                      ),
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(12),
                        child: pw.Container(
                          width: 140,
                          height: 140,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(color: teal, width: 0.75),
                          ),
                          child: pw.ClipOval(
                            child:
                                pw.Image(profileImageWeb, fit: pw.BoxFit.cover),
                          ),
                        ),
                      )),
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
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    //pw.SizedBox(height: 40),
                    // Datos Personales
                    _Category(title: StringConst.PERSONAL_DATA, color: teal),
                    _IconText(
                        iconData: 0xe0be, text: myCustomEmail, isLink: true),
                    _IconText(iconData: 0xe0b0, text: myCustomPhone),
                    _IconText(
                        iconData: 0xe8b4,
                        text:
                            '${city ?? ''} & ${province ?? ''}\n${country?.toUpperCase() ?? ''}'),

                    pw.SizedBox(height: 10),
                    // Referencias
                    if (myReferences != null && myReferences.isNotEmpty) ...[
                      _Category(title: StringConst.REFERENCES, color: teal),
                      for (var ref in myReferences)
                        _ReferenceBlock(
                          name: '${ref.certifierName}',
                          position: '${ref.certifierPosition}',
                          company: '${ref.certifierCompany}',
                          contact: [ref.phone, ref.email]
                              .whereType<String>()
                              .where((s) =>
                                  s.trim().isNotEmpty && s.trim() != '+34')
                              .join(' / '),
                        ),
                    ],

                    pw.SizedBox(height: 10),
                    // Competencias
                    if (competenciesNames.isNotEmpty) ...[
                      _Category(title: StringConst.COMPETENCIES, color: teal),
                      for (var name in competenciesNames)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: _CompetencyChip(title: name),
                        ),
                    ],

                    pw.SizedBox(height: 10),
                    // Datos de Interés
                    if (myDataOfInterest.isNotEmpty) ...[
                      _Category(
                          title: StringConst.DATA_OF_INTEREST, color: teal),
                      for (var item in myDataOfInterest)
                        _BulletItem(text: item),
                    ],

                    pw.SizedBox(height: 10),
                    if (languagesNames != null &&
                        languagesNames.isNotEmpty) ...[
                      _Category(
                          title: StringConst.LANGUAGES, color: primary900),
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
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    //pw.SizedBox(height: 40),
                    // Experiencias Profesionales
                    if ((myExperiences ?? []).isNotEmpty) ...[
                      _Category(
                          title: StringConst.MY_PROFESIONAL_EXPERIENCES,
                          color: teal),
                      for (var exp in (myExperiences ?? []))
                        _ExperienceBlock(
                          title: exp.activity ?? '',
                          subtitle:
                              '${exp.position ?? ""} ${(exp.position ?? "").isNotEmpty && (exp.organization ?? "").isNotEmpty ? "- " : ""}${exp.organization ?? ""}',
                          date:
                              '${exp.startDate != null ? formatter.format(exp.startDate!.toDate()) : '-'} / ${exp.endDate != null ? formatter.format(exp.endDate!.toDate()) : 'Actualmente'}',
                          location: exp.location ?? '',
                          activities: exp.professionActivitiesText,
                        ),
                    ],

                    pw.SizedBox(height: 10),
                    // Experiencias Personales
                    if ((myPersonalExperiences ?? []).isNotEmpty) ...[
                      _Category(
                          title: StringConst.MY_PERSONAL_EXPERIENCES,
                          color: teal),
                      for (var exp in (myPersonalExperiences ?? []))
                        _ExperienceBlock(
                          title: exp.activity ?? '',
                          subtitle: exp.organization ?? '',
                          date:
                              '${exp.startDate != null ? formatter.format(exp.startDate!.toDate()) : '-'} / ${exp.endDate != null ? formatter.format(exp.endDate!.toDate()) : 'Actualmente'}',
                          location: exp.location ?? '',
                        ),
                    ],

                    pw.SizedBox(height: 10),
                    // Formación
                    if ((myEducation ?? []).isNotEmpty) ...[
                      _Category(title: StringConst.EDUCATION, color: teal),
                      for (var edu in (myEducation ?? []))
                        _ExperienceBlock(
                          title: edu.nameFormation ?? '',
                          subtitle: edu.institution ?? '',
                          date:
                              '${edu.startDate != null ? formatter.format(edu.startDate!.toDate()) : '-'} / ${edu.endDate != null ? formatter.format(edu.endDate!.toDate()) : 'Actualmente'}',
                          location: edu.location ?? '',
                        ),
                    ],

                    pw.SizedBox(height: 10),
                    // Cursos y Certificados
                    if ((mySecondaryEducation ?? []).isNotEmpty) ...[
                      _Category(title: 'CURSOS Y CERTIFICADOS', color: teal),
                      for (var edu in (mySecondaryEducation ?? []))
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
  format = format.applyMargin(left: 0, top: 0, right: 0, bottom: 0);
  final double dividerPos = format.width / 3;

  return pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.zero,
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.poppinsLight(),
      bold: await PdfGoogleFonts.poppinsBold(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            // Vertical Divider with 30px padding top/bottom
            if (context.pageNumber == 1)
              pw.Positioned(
                top: headerHeightDivider + 7.5,
                left: 30,
                right: 30,
                child: pw.Container(
                  height: 0.75,
                  color: teal,
                ),
              ),
            pw.Positioned(
              top: context.pageNumber == 1 ? headerHeightDivider : 30,
              bottom: 30,
              left: dividerPos,
              child: _VerticalTimelineShape(teal),
            ),

            // Horizontal Divider (Page 1) with 30px padding left/right
          ],
        ),
      );
    },
  );
}

pw.Widget _buildDot() {
  return pw.Container(
    width: 16,
    height: 16,
    decoration: pw.BoxDecoration(
      color: white,
      shape: pw.BoxShape.circle,
      border: pw.Border.all(color: teal, width: 0.75),
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
            decoration: const pw.BoxDecoration(
                color: tealLight, shape: pw.BoxShape.circle),
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: white, // Same as sidebar background
        border: pw.Border.all(color: darkTeal, width: 1),
        borderRadius:
            pw.BorderRadius.circular(12), // Reduced for single-line text
      ),
      child: pw.Text(
        title,
        textScaleFactor: 0.75,
        style: pw.Theme.of(context).defaultTextStyle.copyWith(
              fontWeight: pw.FontWeight.normal,
              color: darkTeal,
            ),
      ),
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
          if (activities != null && activities!.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Actividades realizadas:',
                      style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: greyBody)),
                  pw.Text(
                    activities!
                        .split(' / ')
                        .where((element) => element.trim().isNotEmpty)
                        .map((a) => '• $a')
                        .join('\n'),
                    style: const pw.TextStyle(fontSize: 8, color: greyBody),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _VerticalTimelineShape extends pw.StatelessWidget {
  _VerticalTimelineShape(this.color);

  final PdfColor color;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      width: 20,
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          // Vertical line
          pw.Container(
            width: 0.75,
            height: double.infinity,
            color: color,
          ),
          // Circles distributed vertically
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildDot(),
              _buildDot(),
              _buildDot(),
              _buildDot(),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDot() {
    return pw.Container(
      width: 15,
      height: 15,
      decoration: pw.BoxDecoration(
        color: white,
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: color, width: 0.75),
      ),
    );
  }
}
