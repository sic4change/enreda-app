import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_app/app/home/curriculum/pdf_generator/data.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/language.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../values/strings.dart';
import '../../../../values/values.dart';
import '../../models/experience.dart';


const PdfColor lilac = PdfColor.fromInt(0xFF6768AB);
const PdfColor lightLilac = PdfColor.fromInt(0xFFF4F5FB);
const PdfColor altLilac = PdfColor.fromInt(0xF798AB7);
const PdfColor blue = PdfColor.fromInt(0xFF002185);
const PdfColor grey = PdfColor.fromInt(0xFF535A5F);
const PdfColor greyLight = PdfColor.fromInt(0xFFC6C6C6);
const leftWidth = 200.0;
const rightWidth = 300.0;

Future<Uint8List> generateResume1(
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

  final profileImage = url == ""
      ? pw.MemoryImage(
    (await rootBundle.load(ImagePath.USER_DEFAULT)).buffer.asUint8List(),
  )
      : pw.MemoryImage(
    (await NetworkAssetBundle(Uri.parse(url)).load(url)).buffer.asUint8List(),
  );

  final pageTheme = await _myPageTheme(format);
  final DateFormat formatter = DateFormat('yyyy');
  List<String>? dataOfInterest = myDataOfInterest;
  List<Language>? languages = languagesNames;

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      build: (pw.Context context) => [
        pw.Partitions(
          children: [
            pw.Partition(
              width: leftWidth,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Container(
                    height: pageTheme.pageFormat.availableHeight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Text('${user?.firstName} ${user?.lastName}',
                            textScaleFactor: 3,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(fontWeight: pw.FontWeight.bold, color: altLilac, lineSpacing: 0)),
                        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                        pw.Text(myMaxEducation.toUpperCase() ?? '',
                            textScaleFactor: 1,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                fontWeight: pw.FontWeight.normal,
                                color: grey)),
                        pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            myCustomEmail != "" ?
                            _Category(title: StringConst.PERSONAL_DATA) : pw.Container(),
                            myCustomEmail != "" ?
                            pw.Row(
                              children: [
                                pw.Icon(pw.IconData(0xe0be), size: 10.0, color:grey),
                                pw.SizedBox(width: 4),
                                _UrlText(myCustomEmail, 'mailto: $myCustomEmail')
                              ],
                            ) : pw.Container(),
                            myCustomPhone != "" ?
                            pw.Row(
                                children: [
                                  pw.Icon(pw.IconData(0xe0b0), size: 10.0, color:grey),
                                  pw.SizedBox(width: 4),
                                  pw.Text(myCustomPhone,
                                      textScaleFactor: 0.8,
                                      style: pw.Theme.of(context)
                                          .defaultTextStyle
                                          .copyWith(
                                          fontWeight: pw.FontWeight.normal,
                                          color: grey)) ,
                                ]
                            ) : pw.Container(),
                            city != "" || province != "" || country != "" ?
                            pw.Row(
                                children: [
                                  pw.Icon(pw.IconData(0xe8b4), size: 10.0, color:grey),
                                  pw.SizedBox(width: 4),
                                  pw.Text('${city ?? ''}, ${province ?? ''}, ${country ?? ''}',
                                      textScaleFactor: 0.8,
                                      style: pw.Theme.of(context)
                                          .defaultTextStyle
                                          .copyWith(
                                          fontWeight: pw.FontWeight.normal,
                                          color: grey)),
                                  // _UrlText(
                                  //     'wholeprices.ca', 'https://wholeprices.ca'),
                                ]
                            ) : pw.Container(),
                            pw.SizedBox(height: 10),
                            competenciesNames != null && competenciesNames.isNotEmpty ? _Category(title: StringConst.COMPETENCIES) : pw.Container(),
                            for (var data in competenciesNames!)
                              _BlockSimpleList(
                                title: data.toUpperCase(),
                              ),
                            pw.SizedBox(height: 5),
                            languagesNames != null && languagesNames.isNotEmpty ? _Category(title: StringConst.LANGUAGES) : pw.Container(),
                            for (var data in languages!)
                              _BlockSimpleList(
                                title: data.name,
                                dotsSpeaking: data.speakingLevel,
                                dotsWriting: data.writingLevel,
                              ),
                            pw.SizedBox(height: 5),
                            myDataOfInterest != null && myDataOfInterest.isNotEmpty ? _Category(title: StringConst.DATA_OF_INTEREST) : pw.Container(),
                            for (var data in dataOfInterest!)
                              _BlockSimpleList(
                                title: data,
                              ),
                            pw.SizedBox(height: 5),
                            aboutMe != null && aboutMe != "" ?
                            _BlockSimple(
                              title: StringConst.ABOUT_ME,
                              description: aboutMe,) : pw.Container(),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                        myReferences != null && myReferences.isNotEmpty ? _Category(title: StringConst.PERSONAL_REFERENCES) : pw.Container(),
                        for (var reference in myReferences!)
                          _BlockIcon(
                            title: '${reference.certifierName}',
                            description1: '${reference.certifierPosition} - ${reference.certifierCompany}',
                            description2: '${reference.email}',
                            description3: '${reference.phone}',
                          ),
                        // pw.BarcodeWidget(
                        //   data: 'mailto:<${user?.email}>?subject=&body=',
                        //   width: 60,
                        //   height: 60,
                        //   barcode: pw.Barcode.qrCode(),
                        //   drawText: false,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.Partition(
              width: rightWidth,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    height: pageTheme.pageFormat.availableHeight,
                    padding: const pw.EdgeInsets.only(left: 30, right: 30),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Center(
                            child: pw.Column(
                                children: [
                                  myPhoto == true ? pw.ClipOval(
                                    child: pw.Container(
                                      width: 120,
                                      height: 120,
                                      color: lightLilac,
                                      child: pw.Image(profileImage, fit: pw.BoxFit.fitWidth),
                                    ),
                                  ) : pw.Container(),
                                ]
                            )
                        ),
                        pw.SizedBox(height: 40),
                        myExperiences != null && myExperiences.isNotEmpty ? _Category(title: StringConst.MY_PROFESIONAL_EXPERIENCES) : pw.Container(),
                        for (var experience in myExperiences!)
                          _Block(
                            title: (experience.activity != null) ? experience.activity : '',
                            organization: experience.organization != "" && experience.organization != null && experience.position != "" && experience.position != null ? '${experience.position} - ${experience.organization}'
                                : experience.organization != null || experience.organization != "" ? experience.organization :  experience.position != null && experience.position != "" ? experience.position : "",
                            showDescriptionDate: idSelectedDateExperience!.contains(experience.id),
                            descriptionDate:'${experience.startDate != null ? formatter.format(experience.startDate!.toDate())
                                : '-'} / ${experience.endDate != null ? formatter.format(experience.endDate!.toDate()) : 'Actualmente'}',
                            descriptionPlace: '${experience.location}',
                            descriptionActivities: experience.professionActivitiesText!
                                .split(' / ')
                                .where((item) => item.isNotEmpty) // Filter out empty items.
                                .map((item) => '• $item')         // Prefix each item with a bullet point.
                                .join('\n'),
                          ),
                        pw.SizedBox(height: 5),

                        myPersonalExperiences != null && myPersonalExperiences.isNotEmpty ? _Category(title: StringConst.MY_PERSONAL_EXPERIENCES) : pw.Container(),
                        for (var experience in myPersonalExperiences!)
                          _Block(
                            title: experience.subtype == 'Responsabilidades familiares' || experience.subtype == "Compromiso social" ? experience.subtype :
                            experience.activityRole != null && experience.activity != null && experience.subtype != null
                                ? '${experience.subtype} - ${experience.activityRole} - ${experience.activity}'
                                : experience.activityRole != null && experience.activity != null ? '${experience.activityRole} - ${experience.activity}' :
                            experience.activity != null && experience.subtype != null ? '${experience.subtype} - ${experience.activity}' :
                            experience.activity != null ? experience.activity : '',
                            organization: experience.organization != "" && experience.organization != null && experience.position != "" && experience.position != null ? '${experience.position} - ${experience.organization}'
                                : experience.organization != null || experience.organization != "" ? experience.organization :  experience.position != null && experience.position != "" ? experience.position : "",
                            showDescriptionDate: idSelectedDatePersonalExperience!.contains(experience.id),
                            descriptionDate:'${experience.startDate != null ? formatter.format(experience.startDate!.toDate())
                                : '-'} / ${experience.endDate != null ? formatter.format(experience.endDate!.toDate()) : 'Actualmente'}',
                            descriptionPlace: '${experience.location}',
                          ),
                        pw.SizedBox(height: 5),

                        myEducation!.isNotEmpty ? _Category(title: StringConst.EDUCATION) : pw.Container(),
                        for (var education in myEducation)
                          _Block(
                            title: education.institution != null && education.nameFormation != null && education.nameFormation != ''
                                ? '${education.institution} - ${education.nameFormation}'
                                : education.institution == null ? education.nameFormation : education.institution,
                            organization: education.organization != "" && education.organization != null ? education.organization : '',
                            showDescriptionDate: idSelectedDateEducation!.contains(education.id),
                            descriptionDate:'${education.startDate != null ? formatter.format(education.startDate!.toDate())
                                : '-'} / ${education.endDate != null ? formatter.format(education.endDate!.toDate()) : 'Actualmente'}',
                            descriptionPlace: '${education.location}',
                          ),
                        pw.SizedBox(height: 5),

                        mySecondaryEducation!.isNotEmpty ? _Category(title: StringConst.SECONDARY_EDUCATION) : pw.Container(),
                        for (var education in mySecondaryEducation)
                          _Block(
                            title: education.institution != null && education.nameFormation != null && education.nameFormation != ''
                                ? '${education.institution} - ${education.nameFormation}'
                                : education.institution == null ? education.nameFormation : education.institution,
                            organization: education.organization != "" && education.organization != null ? education.organization : '',
                            showDescriptionDate: idSelectedDateSecondaryEducation!.contains(education.id),
                            descriptionDate:'${education.startDate != null ? formatter.format(education.startDate!.toDate())
                                : '-'} / ${education.endDate != null ? formatter.format(education.endDate!.toDate()) : 'Actualmente'}',
                            descriptionPlace: '${education.location}',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  final bgShape = await rootBundle.loadString('images/cv-dots-1.svg');
  final bgShape2 = await rootBundle.loadString('images/cv-dots-2.svg');
  final bgShape3 = await rootBundle.loadString('images/cv-dots-3.svg');

  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 3.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  return pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.only(top: 70, left: 70, right: 50, bottom: 10),
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.latoRegular(),
      bold: await PdfGoogleFonts.alataRegular(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Container(
              width: 250,
              height: 250,
              child: pw.Positioned(
                child: pw.SvgImage(svg: bgShape),
                left: 0,
                top: 0,
              ),
            ),
            pw.Positioned(
              child: pw.SvgImage(svg: bgShape2),
              right: 0,
              top: 0,
            ),
            pw.Positioned(
              child: pw.SvgImage(svg: bgShape3),
              right: 0,
              bottom: 0,
            ),
          ],
        ),
      );
    },
  );
}

class _Block extends pw.StatelessWidget {
  _Block({
    this.title,
    this.organization,
    this.descriptionDate,
    this.descriptionPlace,
    this.showDescriptionDate,
    this.descriptionActivities,
  });

  final String? title;
  final String? organization;
  final String? descriptionDate;
  final String? descriptionPlace;
  final bool? showDescriptionDate;
  final String? descriptionActivities;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                title != null ? pw.Expanded(
                  child: pw.Text(
                      title!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.bold,
                          color: grey)),
                ) : pw.Container()
              ]),
          organization != null ? pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Text(
                      organization!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.bold,
                          color: grey)),
                )
              ]) : pw.Container(),
          descriptionDate != null && (showDescriptionDate ?? true) ? pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(descriptionDate!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.normal,
                          color: grey)),
                ]),
          ) : pw.Container(),
          descriptionPlace != null ? pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(descriptionPlace!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.normal,
                          color: grey)),
                ]),
          ) : pw.Container(),
          descriptionActivities != null ? pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text('Actividades realizadas:',
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.bold,
                          color: grey)),
                  pw.Text(descriptionActivities!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.normal,
                          color: grey)),
                ]),
          ) : pw.Container(),
          pw.SizedBox(height: 8),
        ]);
  }
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title});

  final String title;


  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
          title.toUpperCase(),
          textScaleFactor: 1,
          style: pw.Theme.of(context)
              .defaultTextStyle
              .copyWith(
              fontWeight: pw.FontWeight.bold,
              color: altLilac)),
    );
  }
}

class _Percent extends pw.StatelessWidget {
  _Percent({
    required this.size,
    required this.value,
    required this.title,
  });

  final double size;

  final double value;

  final pw.Widget title;

  static const fontSize = 1.2;

  PdfColor get color => lilac;

  static const backgroundColor = PdfColors.grey300;

  static const strokeWidth = 5.0;

  @override
  pw.Widget build(pw.Context context) {
    final widgets = <pw.Widget>[
      pw.Container(
        width: size,
        height: size,
        child: pw.Stack(
          alignment: pw.Alignment.center,
          fit: pw.StackFit.expand,
          children: <pw.Widget>[
            pw.Center(
              child: pw.Text(
                '${(value * 100).round().toInt()}%',
                textScaleFactor: fontSize,
              ),
            ),
            pw.CircularProgressIndicator(
              value: value,
              backgroundColor: backgroundColor,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ],
        ),
      )
    ];

    widgets.add(title);

    return pw.Column(children: widgets);
  }
}

class _UrlText extends pw.StatelessWidget {
  _UrlText(this.text, this.url);

  final String text;
  final String url;

  @override
  pw.Widget build(pw.Context context) {
    return pw.UrlLink(
        destination: url,
        child: pw.Text(text,
            textScaleFactor: 0.8,
            style: pw.Theme.of(context)
                .defaultTextStyle
                .copyWith(
                fontWeight: pw.FontWeight.normal,
                color: grey))
    );
  }
}

class _BlockSimple extends pw.StatelessWidget {
  _BlockSimple({
    this.title,
    this.description,
  });

  final String? title;
  final String? description;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                title != null ? pw.Expanded(
                  child:
                  pw.Text(
                      title!.toUpperCase(),
                      textScaleFactor: 1,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.bold,
                          color: altLilac)),
                ) : pw.Container()
              ]),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  description != null ? pw.Text(description!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.normal,
                          color: grey)) : pw.Container(),
                ]),
          ),
          pw.SizedBox(height: 5),
        ]);
  }
}

class _BlockSimpleList extends pw.StatelessWidget {
  _BlockSimpleList({
    this.title,
    this.dotsSpeaking,
    this.dotsWriting,
  });

  final String? title;
  late int? dotsSpeaking;
  late int? dotsWriting;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Container(
                  width: 3,
                  height: 3,
                  margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                  decoration: const pw.BoxDecoration(
                    color: lilac,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                title != null ? pw.Expanded(
                  child:
                  pw.Text(
                      title!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.normal)),
                ) : pw.Container(),
              ]),
          dotsSpeaking != null && dotsWriting != null ? pw.Container() : pw.SizedBox(height: 8),
          dotsSpeaking != null && dotsWriting != null ?
          pw.Column(
              children: [
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(width: 10),
                      pw.Text('Oral:  ', textScaleFactor: 0.8, style: pw.Theme.of(context).defaultTextStyle.copyWith(fontWeight: pw.FontWeight.normal)),
                      _Dots(dotsNumber: dotsSpeaking),
                      pw.SizedBox(width: 10),
                      pw.Text('Escrito:  ', textScaleFactor: 0.8, style: pw.Theme.of(context).defaultTextStyle.copyWith(fontWeight: pw.FontWeight.normal)),
                      _Dots(dotsNumber: dotsWriting
                      ),
                    ]
                )
              ]
          ) : pw.Container()
        ]);
  }
}

class _Dots extends pw.StatelessWidget {
  _Dots({
    this.dotsNumber,
  });

  final int? dotsNumber;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        buildDotRow(),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget buildDotRow() {
    List<pw.Widget> dots = [];
    for (int i = 0; i < 3; i++) {
      PdfColor color = i < (dotsNumber ?? 0) ? lilac : greyLight;
      dots.add(buildDot(color));
    }
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: dots,
    );
  }

  pw.Widget buildDot(PdfColor color) {
    return pw.Container(
      width: 6,
      height: 6,
      margin: const pw.EdgeInsets.only(top: 10, left: 2, right: 5),
      decoration: pw.BoxDecoration(
        color: color,
        shape: pw.BoxShape.circle,
      ),
    );
  }
}


class _BlockIcon extends pw.StatelessWidget {
  _BlockIcon({
    this.title,
    this.description1,
    this.description2,
    this.description3,
  });

  final String? title;
  final String? description1;
  final String? description2;
  final String? description3;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              title != null ? pw.Expanded(
                child: pw.Text(
                    title!,
                    textScaleFactor: 0.9,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(
                        fontWeight: pw.FontWeight.bold,
                        color: grey)),
              ) : pw.Container()
            ]),
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              description1 != null ? pw.Expanded(
                child: pw.Text(
                    description1!.toUpperCase(),
                    textScaleFactor: 0.8,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(
                        fontWeight: pw.FontWeight.bold,
                        color: grey)),
              ) : pw.Container()
            ]),
        description2 != "" ?
        pw.Row(
          children: [
            pw.Icon(pw.IconData(0xe0be), size: 10.0, color:grey),
            pw.SizedBox(width: 4),
            _UrlText(description2!, 'mailto: $description1')
          ],
        ) : pw.Container(),
        description3 != "" ?
        pw.Row(
            children: [
              pw.Icon(pw.IconData(0xe0b0), size: 10.0, color:grey),
              pw.SizedBox(width: 4),
              pw.Text(description3!,
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(
                      fontWeight: pw.FontWeight.normal,
                      color: grey)) ,
            ]
        ) : pw.Container(),
        pw.SizedBox(height: 5),
      ],
    );
  }
}


