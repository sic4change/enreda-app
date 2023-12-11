import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:enreda_app/app/home/curriculum/pdf_generator/data.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
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
const PdfColor blue = PdfColor.fromInt(0xFF002185);
const sep = 120.0;

Future<Uint8List> generateResume(
    PdfPageFormat format,
    CustomData data,
    UserEnreda? user,
    String? city,
    String? province,
    String? country,
    List<Experience>?
    myExperiences,
    List<Experience>? myEducation,
    List<String>? competenciesNames,
    List<String>? languagesNames,
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
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<String>? dataOfInterest = myDataOfInterest;
  List<String>? languages = languagesNames;

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      build: (pw.Context context) => [
        pw.Partitions(
          children: [
            pw.Partition(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Container(
                    padding: const pw.EdgeInsets.only(left: 20, bottom: 20, right: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Text('${user?.firstName} ${user?.lastName}',
                            textScaleFactor: 2,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(fontWeight: pw.FontWeight.bold, color: blue)),
                        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                        pw.Text(myMaxEducation,
                            textScaleFactor: 1.2,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                fontWeight: pw.FontWeight.bold,
                                color: lilac)),
                        pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: <pw.Widget>[
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget>[
                                pw.Text(city ?? ''),
                                pw.Text(province ?? ''),
                                pw.Text(country ?? ''),
                              ],
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget>[
                                myCustomPhone != "" ? pw.Text(myCustomPhone) : pw.Container(),
                                myCustomEmail != "" ? _UrlText(myCustomEmail,
                                    'mailto: $myCustomEmail') : pw.Container(),
                                // _UrlText(
                                //     'wholeprices.ca', 'https://wholeprices.ca'),
                              ],
                            ),
                            pw.Padding(padding: pw.EdgeInsets.zero)
                          ],
                        ),
                      ],
                    ),
                  ),
                  myExperiences != null && myExperiences.isNotEmpty ? _Category(title: StringConst.EXPERIENCES) : pw.Container(),
                  for (var experience in myExperiences!)
                    _Block(
                      title: experience.activityRole != null &&
                          experience.activity != null
                          ? '${experience.activityRole} - ${experience.activity}'
                          : experience.position == ""
                          ? experience.activity
                          : experience.organization == ""
                          ? experience.position
                          : '${experience.position} - ${experience.organization}',
                      description:'${experience.location}, ${formatter.format(experience.startDate.toDate())} - ${experience.endDate != null
                          ? formatter.format(experience.endDate!.toDate())
                          : 'Actualmente'}',
                    ),
                  pw.SizedBox(height: 20),
                  myEducation!.isNotEmpty ? _Category(title: StringConst.EDUCATION) : pw.Container(),
                  for (var education in myEducation)
                    _Block(
                      title: education.activityRole == null
                          ? education.activity
                          : '${education.activityRole} - ${education.activity}',
                      description:'${education.location}, ${formatter.format(education.startDate.toDate())} - ${education.endDate != null
                          ? formatter.format(education.endDate!.toDate())
                          : 'Actualmente'}',
                    ),
                  competenciesNames != null && competenciesNames.isNotEmpty ? _Category(title: StringConst.COMPETENCIES) : pw.Container(),
                  for (var data in competenciesNames!)
                    _Block(
                      description: data,
                    ),
                  aboutMe != null && aboutMe != "" ? _Category(title: StringConst.ABOUT_ME) : pw.Container(),
                  aboutMe != null && aboutMe != "" ?
                  _Block(
                    description: aboutMe != "" ? aboutMe : '',
                  ) : pw.Container(),
                  myDataOfInterest != null && myDataOfInterest.isNotEmpty ? _Category(title: StringConst.DATA_OF_INTEREST) : pw.Container(),
                  for (var data in dataOfInterest!)
                    _Block(
                      description: data,
                    ),
                  languagesNames != null && languagesNames.isNotEmpty ? _Category(title: StringConst.LANGUAGES) : pw.Container(),
                  for (var data in languages!)
                    _Block(
                      description: data,
                    ),
                ],
              ),
            ),
            pw.Partition(
              width: sep,
              child: pw.Column(
                children: [
                  pw.Container(
                    height: pageTheme.pageFormat.availableHeight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: <pw.Widget>[
                        myPhoto == true ? pw.ClipOval(
                          child: pw.Container(
                            width: 100,
                            height: 100,
                            color: lightLilac,
                            child: pw.Image(profileImage, fit: pw.BoxFit.fitWidth),
                          ),
                        ): pw.Container(),
                        pw.BarcodeWidget(
                          data: 'mailto:<${user?.email}>?subject=&body=',
                          width: 60,
                          height: 60,
                          barcode: pw.Barcode.qrCode(),
                          drawText: false,
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
  final bgShape = await rootBundle.loadString('images/resume.svg');

  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 4.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  return pw.PageTheme(
    pageFormat: format,
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.openSansRegular(),
      bold: await PdfGoogleFonts.openSansBold(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Positioned(
              child: pw.SvgImage(svg: bgShape),
              left: 0,
              top: 0,
            ),
            pw.Positioned(
              child: pw.Transform.rotate(
                  angle: pi, child: pw.SvgImage(svg: bgShape)),
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
    required this.description,
  });

  final String? title;
  final String description;


  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Container(
                  width: 6,
                  height: 6,
                  margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                  decoration: const pw.BoxDecoration(
                    color: lilac,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                title != null ? pw.Expanded(
                  child: pw.Text(
                      title!,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.bold)),
                ) : pw.Container()
              ]),
          pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: lilac, width: 2))),
            padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
            margin: const pw.EdgeInsets.only(left: 5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(description,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.normal)),
                ]),
          ),
        ]);
  }
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title});

  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        color: lightLilac,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      margin: const pw.EdgeInsets.only(bottom: 10, top: 20),
      padding: const pw.EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: pw.Text(
        title,
        textScaleFactor: 1.5,
      ),
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
          style: const pw.TextStyle(
            decoration: pw.TextDecoration.underline,
            color: PdfColors.blue,
          )),
    );
  }
}


