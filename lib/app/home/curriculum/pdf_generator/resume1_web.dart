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


const PdfColor lilac = PdfColor.fromInt(0xF8A6A83);
const PdfColor lightLilac = PdfColor.fromInt(0xFFF4F5FB);
const PdfColor blue = PdfColor.fromInt(0xFF002185);
const PdfColor grey = PdfColor.fromInt(0xFF535A5F);
const PdfColor greyDark = PdfColor.fromInt(0xFF44494B);
const PdfColor black = PdfColor.fromInt(0xF44494B);
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);
const PdfColor greyLight = PdfColor.fromInt(0xFFADADAD);
const PdfColor bluePetrol = PdfColor.fromInt(0xFF054D5E);
const PdfColor greyTitle = PdfColor.fromInt(0xFF545454);
const PdfColor leftPanel = PdfColor.fromInt(0xFFD6DAFB);
const leftWidth = 200.0;
const rightWidth = 350.0;

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
  var fontPoppins = await PdfGoogleFonts.poppinsRegular();
  var fontPoppinsBold = await PdfGoogleFonts.poppinsExtraBold();

  Future<Uint8List> imageFromUrl(String url) async {
    final uri = Uri.parse(url);
    final Response response = await get(uri);
    return response.bodyBytes;
  }

  Future<Uint8List> myFutureUint8List = imageFromUrl(url);
  Uint8List myUint8List = await myFutureUint8List;

  final profileImageWeb = url == ""
      ? pw.MemoryImage((await rootBundle.load(ImagePath.USER_DEFAULT)).buffer.asUint8List(),)
      : pw.MemoryImage(myUint8List);

  PdfPageFormat format1 = format.applyMargin(
      left: 0,
      top: 0,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);

  final pageTheme = await _myPageTheme(format1, myPhoto, profileImageWeb);
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
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Container(
                    height: pageTheme.pageFormat.availableHeight,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 30.0),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.SizedBox(height: 10),
                              pw.Text('${user?.firstName}',
                                  textScaleFactor: 1,
                                  style: pw.TextStyle(
                                      font: fontPoppinsBold,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 28,
                                      color: bluePetrol)),
                              pw.SizedBox(height: 2),
                              pw.Text('${user?.lastName}',
                                  textScaleFactor: 1,
                                  style: pw.TextStyle(
                                      font: fontPoppins,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 22,
                                      color: bluePetrol)),
                              pw.SizedBox(height: 130),
                              myCustomEmail != "" ?
                              _Category(title: StringConst.PERSONAL_DATA, color: white, fontPoppins: fontPoppins) : pw.Container(),
                              myCustomEmail != "" ?
                              pw.Row(
                                children: [
                                  pw.Container(
                                    width: 20,
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: bluePetrol,
                                    ),
                                    child: pw.Center(
                                      child: pw.Icon(pw.IconData(0xe0be), size: 10.0, color: white),
                                    ),
                                  ),
                                  pw.SizedBox(width: 4),
                                  _UrlText(myCustomEmail, 'mailto: $myCustomEmail', fontPoppins: fontPoppins)
                                ],
                              ) : pw.Container(),
                              pw.SizedBox(height: 6),
                              myCustomPhone != "" ?
                              pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 20,
                                      height: 20,
                                      decoration: pw.BoxDecoration(
                                        shape: pw.BoxShape.circle,
                                        color: bluePetrol,
                                      ),
                                      child: pw.Center(
                                        child: pw.Icon(pw.IconData(0xe0b0), size: 10.0, color: white),
                                      ),
                                    ),
                                    pw.SizedBox(width: 6),
                                    pw.Text(myCustomPhone,
                                        textScaleFactor: 0.8,
                                        style: pw.TextStyle(
                                            font: fontPoppins,
                                            fontWeight: pw.FontWeight.normal,
                                            fontSize: 12,
                                            color: greyTitle)),
                                  ]
                              ) : pw.Container(),
                              pw.SizedBox(height: 6),
                              city != "" || province != "" || country != "" ?
                              pw.Row(
                                  children: [
                                    pw.Row(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        mainAxisAlignment: pw.MainAxisAlignment.start,
                                        children: [
                                          pw.Container(
                                            width: 20,
                                            height: 20,
                                            decoration: pw.BoxDecoration(
                                              shape: pw.BoxShape.circle,
                                              color: bluePetrol,
                                            ),
                                            child: pw.Center(
                                              child: pw.Icon(pw.IconData(0xe8b4), size: 10.0, color: white),
                                            ),
                                          ),
                                          pw.SizedBox(width: 5),
                                          pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text('${city ?? ''}',
                                                    textScaleFactor: 0.8,
                                                    style: pw.TextStyle(
                                                        font: fontPoppins,
                                                        fontWeight: pw.FontWeight.normal,
                                                        fontSize: 12,
                                                        color: greyTitle)),
                                                pw.Text('${province ?? ''}',
                                                    textScaleFactor: 0.8,
                                                    style: pw.TextStyle(
                                                        font: fontPoppins,
                                                        fontWeight: pw.FontWeight.normal,
                                                        fontSize: 12,
                                                        color: greyTitle)),
                                                pw.Text('${country ?? ''}',
                                                    textScaleFactor: 0.8,
                                                    style: pw.TextStyle(
                                                        font: fontPoppins,
                                                        fontWeight: pw.FontWeight.normal,
                                                        fontSize: 12,
                                                        color: greyTitle)),
                                              ]
                                          )
                                        ]
                                    ),
                                    // _UrlText(
                                    //     'wholeprices.ca', 'https://wholeprices.ca'),
                                  ]
                              ) : pw.Container(),
                              pw.SizedBox(height: 6),
                              aboutMe != null && aboutMe != "" ?
                              _BlockSimple(
                                title: StringConst.ABOUT_ME,
                                fontPoppins: fontPoppins,
                                description: aboutMe,) : pw.Container(),
                              pw.SizedBox(height: 10),
                              myDataOfInterest != null && myDataOfInterest.isNotEmpty ? _Category(title: StringConst.DATA_OF_INTEREST, color: white, fontPoppins: fontPoppins) : pw.Container(),
                              pw.Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: <pw.Widget>[
                                    for (var data in dataOfInterest!)
                                      _BlockRoundedList(
                                          title: data,
                                          color: white,
                                          fontPoppins: fontPoppins
                                      ),
                                  ]
                              ),
                              pw.SizedBox(height: 10),
                              languagesNames != null && languagesNames.isNotEmpty ? _Category(title: StringConst.LANGUAGES, color: white, fontPoppins: fontPoppins) : pw.Container(),
                              for (var data in languages!)
                                _BlockSimpleList(
                                    title: data.name,
                                    color: white,
                                    dotsSpeaking: data.speakingLevel,
                                    dotsWriting: data.writingLevel,
                                    fontPoppins: fontPoppins,
                                    languages: true
                                ),
                              // pw.Center(
                              //   child: pw.BarcodeWidget(
                              //       data: 'mailto:<${user?.email}>?subject=&body=',
                              //       width: 60,
                              //       height: 60,
                              //       barcode: pw.Barcode.qrCode(),
                              //       drawText: false,
                              //       color: white
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
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
                    padding: const pw.EdgeInsets.only(left: 50, right: 30),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Text(myMaxEducation.toUpperCase() ?? '',
                            //textScaleFactor: 1,
                            style: pw.TextStyle(
                                font: fontPoppins,
                                fontWeight: pw.FontWeight.normal,
                                fontSize: 20,
                                color: greyTitle)),
                        pw.SizedBox(height: 30),
                        myExperiences != null && myExperiences.isNotEmpty ? _Category(title: StringConst.MY_PROFESIONAL_EXPERIENCES, color: bluePetrol, fontPoppins: fontPoppins) : pw.Container(),
                        for (var experience in myExperiences!)
                          _Block(
                            title: (experience.activity != null) ? experience.activity : '',
                            organization: experience.organization != "" && experience.organization != null && experience.position != "" && experience.position != null ? '${experience.position} - ${experience.organization}'
                                : experience.organization != null || experience.organization != "" ? experience.organization :  experience.position != null && experience.position != "" ? experience.position : "",
                            showDescriptionDate: idSelectedDateExperience!.contains(experience.id),
                            descriptionDate:'${experience.startDate != null ? formatter.format(experience.startDate!.toDate())
                                : '-'} / ${experience.endDate != null ? formatter.format(experience.endDate!.toDate()) : 'Actualmente'}',
                            descriptionPlace: '${experience.location}',
                            descriptionActivities:
                            experience.professionActivitiesText != null ? experience.professionActivitiesText!
                                .split(' / ')
                                .where((item) => item.isNotEmpty) // Filter out empty items.
                                .map((item) => '• $item')         // Prefix each item with a bullet point.
                                .join('\n') :
                            experience.professionActivities
                                .where((item) => item.isNotEmpty) // Filter out empty items.
                                .map((item) => '• $item')         // Prefix each item with a bullet point.
                                .join('\n'),
                            fontPoppins: fontPoppins,
                          ),
                        pw.SizedBox(height: 5),

                        myPersonalExperiences != null && myPersonalExperiences.isNotEmpty ? _Category(title: StringConst.MY_PERSONAL_EXPERIENCES, color: lilac, fontPoppins: fontPoppins) : pw.Container(),
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
                            fontPoppins: fontPoppins,
                          ),
                        pw.SizedBox(height: 5),

                        myEducation!.isNotEmpty ? _Category(title: StringConst.EDUCATION, color: lilac, fontPoppins: fontPoppins) : pw.Container(),
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
                            fontPoppins: fontPoppins,
                          ),
                        pw.SizedBox(height: 5),

                        mySecondaryEducation!.isNotEmpty ? _Category(title: StringConst.SECONDARY_EDUCATION, color: lilac, fontPoppins: fontPoppins) : pw.Container(),
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
                            fontPoppins: fontPoppins,
                          ),
                        pw.SizedBox(height: 5),
                        myReferences != null && myReferences.isNotEmpty ? _Category(title: StringConst.REFERENCES, color: white, fontPoppins: fontPoppins) : pw.Container(),
                        for (var reference in myReferences!)
                          _BlockIcon(
                            title: '${reference.certifierName}',
                            description1: '${reference.certifierPosition} - ${reference.certifierCompany}',
                            description2: '${reference.email}',
                            description3: '${reference.phone}',
                            fontPoppins: fontPoppins,
                          ),
                        pw.SizedBox(height: 5),
                        competenciesNames != null && competenciesNames.isNotEmpty ? _Category(title: StringConst.COMPETENCIES, color: white, fontPoppins: fontPoppins) : pw.Container(),
                        for (var data in competenciesNames!)
                          _BlockSimpleList(
                              title: data,
                              color: greyTitle,
                              fontPoppins: fontPoppins
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

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format, bool myPhoto, profileImageWeb) async {
  final bgShape = await rootBundle.loadString('images/polygon.svg');
  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 2.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  return pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.only(top: 50, left: 0.0, right: 20, bottom: 10),
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.latoRegular(),
      bold: await PdfGoogleFonts.aliceRegular(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Container(
              width: 220,
              decoration: pw.BoxDecoration(
                color: leftPanel,
                shape: pw.BoxShape.rectangle,
              ),
              child: pw.Positioned(
                child: pw.Container(),
                left: 0,
                top: 0,
                bottom: 0,
              ),
            ),
            pw.Positioned(
              child: pw.Container(
                  child: pw.SvgImage(svg: bgShape),
                  width: 200,
                  height: 400
              ),
              left: 0,
              top: 10,
            ),
            myPhoto == true ?
            pw.Positioned(
              right: 360,
              top: 160,
              child: pw.Container(
                  padding: const pw.EdgeInsets.all(8.0),
                  decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(
                        color: white,
                      )
                  ),
                  child: pw.ClipOval(
                    child: pw.Container(
                      width: 80,
                      height: 80,
                      child: pw.Image(profileImageWeb, fit: pw.BoxFit.cover),
                    ),
                  )
              ),
            ) : pw.Container(),
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
    required this.fontPoppins,
  });

  final String? title;
  final String? organization;
  final String? descriptionDate;
  final String? descriptionPlace;
  final bool? showDescriptionDate;
  final String? descriptionActivities;
  final pw.Font fontPoppins;


  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          organization != null ? pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Text(
                      organization!,
                      textScaleFactor: 1,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.bold,
                          color: greyTitle)),
                )
              ]) : pw.Container(),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  (showDescriptionDate ?? true) ? pw.Text(descriptionDate!,
                      textScaleFactor: 0.8,
                      style: pw.TextStyle(
                          font: fontPoppins,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 12,
                          color: greyTitle))
                      : pw.Container(),
                ]),
          ),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(descriptionPlace!,
                      textScaleFactor: 0.8,
                      style: pw.TextStyle(
                          font: fontPoppins,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 12,
                          color: greyTitle)),
                ]),
          ),
          descriptionActivities != null ? pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text('Actividades realizadas:',
                      textScaleFactor: 0.8,
                      style: pw.TextStyle(
                          font: fontPoppins,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: greyTitle)),
                  pw.Text(descriptionActivities!,
                      textScaleFactor: 0.8,
                      style: pw.TextStyle(
                          font: fontPoppins,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 12,
                          color: greyTitle)),
                ]),
          ) : pw.Container(),
          pw.SizedBox(height: 8),
        ]);
  }
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title, required this.color, required this.fontPoppins});

  final String title;
  final PdfColor color;
  final pw.Font fontPoppins;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
          title.toUpperCase(),
          textScaleFactor: 1,
          style: pw.TextStyle(
              font: fontPoppins,
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
              color: bluePetrol)),
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
  _UrlText(this.text, this.url,{required this.fontPoppins});

  final String text;
  final String url;
  final pw.Font fontPoppins;

  @override
  pw.Widget build(pw.Context context) {
    return pw.UrlLink(
      destination: url,
      child: pw.Text(text,
          textScaleFactor: 0.8,
          style: pw.TextStyle(
              font: fontPoppins,
              fontWeight: pw.FontWeight.normal,
              fontSize: 12,
              color: greyTitle)),
    );
  }
}

class _BlockSimple extends pw.StatelessWidget {
  _BlockSimple({
    this.title,
    this.description,
    required this.fontPoppins,
  });

  final String? title;
  final String? description;
  final pw.Font fontPoppins;

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
                    _Category(title: title!, color: bluePetrol, fontPoppins: fontPoppins)
                ) : pw.Container()
              ]),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  description != null ? pw.Text(description!,
                      textScaleFactor: 0.8,
                      style: pw.TextStyle(
                          font: fontPoppins,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 12,
                          color: greyTitle)) : pw.Container(),
                ]),
          ),
          pw.SizedBox(height: 5),
        ]);
  }
}

class _BlockSimpleList extends pw.StatelessWidget {
  _BlockSimpleList({
    this.title,
    this.color,
    this.dotsSpeaking,
    this.dotsWriting,
    required this.fontPoppins,
    this.languages = false,
  });

  final String? title;
  final PdfColor? color;
  late int? dotsSpeaking;
  late int? dotsWriting;
  final pw.Font fontPoppins;
  late bool languages;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                !languages ? pw.Container(
                  width: 3,
                  height: 3,
                  margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                  decoration: const pw.BoxDecoration(
                    color: bluePetrol,
                    shape: pw.BoxShape.circle,
                  ),
                ) : pw.Container(),
                title != null ? pw.Expanded(
                  child:
                  pw.Text(
                      title!,
                      textScaleFactor: 0.8,
                      style: pw.TextStyle(
                          font: fontPoppins,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 12,
                          color: greyTitle)),
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
                      pw.Text('Oral:  ', textScaleFactor: 0.8, style: pw.TextStyle(
                          font: fontPoppins,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 12,
                          color: greyTitle)),
                      _Dots(dotsNumber: dotsSpeaking),
                      pw.SizedBox(width: 10),
                      pw.Text('Escrito:  ', textScaleFactor: 0.8, style: pw.TextStyle(
                          font: fontPoppins,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 12,
                          color: greyTitle)),
                      _Dots(dotsNumber: dotsWriting
                      ),
                    ]
                )
              ]
          ) : pw.Container()
        ]);
  }
}

class _BlockRoundedList extends pw.StatelessWidget {
  _BlockRoundedList({
    this.title,
    this.color,
    required this.fontPoppins,
  });

  final String? title;
  final PdfColor? color;
  final pw.Font fontPoppins;

  @override
  pw.Widget build(pw.Context context) {
    return title != null ? pw.Container(
      decoration: pw.BoxDecoration(
          shape: pw.BoxShape.rectangle,
          borderRadius: pw.BorderRadius.circular(14),
          color: bluePetrol
      ),
      child:
      pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text(
            title!,
            textScaleFactor: 0.8,
            style: pw.TextStyle(
                font: fontPoppins,
                fontWeight: pw.FontWeight.normal,
                fontSize: 12,
                color: white)),
      ),
    ) : pw.Container();
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
      PdfColor color = i < (dotsNumber ?? 0) ? greyTitle : greyLight;
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
    required this.fontPoppins
  });

  final String? title;
  final String? description1;
  final String? description2;
  final String? description3;
  final pw.Font fontPoppins;

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
                    style: pw.TextStyle(
                        font: fontPoppins,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: greyTitle)),
              ) : pw.Container()
            ]),
        pw.SizedBox(height: 4),
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              description1 != null ? pw.Expanded(
                child: pw.Text(
                    description1!.toUpperCase(),
                    textScaleFactor: 0.8,
                    style: pw.TextStyle(
                        font: fontPoppins,
                        fontWeight: pw.FontWeight.normal,
                        fontSize: 12,
                        color: greyTitle)),
              ) : pw.Container()
            ]),
        pw.SizedBox(height: 4),

        pw.Row(
          children: [
            description2 != "" ? _UrlText(description2!, 'mailto: $description1', fontPoppins: fontPoppins) : pw.Container(),
            pw.SizedBox(width: 4),
            (description2 != ""  && description3 != '') ?
            pw.Text('/', style: pw.TextStyle(
                font: fontPoppins,
                fontWeight: pw.FontWeight.normal,
                fontSize: 12,
                color: greyTitle)) : pw.Container(),
            pw.SizedBox(width: 4),
            description3 != "" ? pw.Text(description3!,
                textScaleFactor: 0.8,
                style: pw.TextStyle(
                    font: fontPoppins,
                    fontWeight: pw.FontWeight.normal,
                    fontSize: 12,
                    color: greyTitle)) : pw.Container(),
          ],
        ),
        description3 != "" ?
        pw.Row(
            children: [
              pw.Icon(pw.IconData(0xe0b0), size: 10.0, color:white),
              pw.SizedBox(width: 4),
              pw.Text(description3!,
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(
                      fontWeight: pw.FontWeight.normal,
                      color: white)) ,
            ]
        ) : pw.Container(),
        pw.SizedBox(height: 8),
      ],
    );
  }
}