import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_app/app/home/curriculum/pdf_generator/cv_multiple_pages.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/language.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';
import '../../../../utils/const.dart';
import '../../models/experience.dart';
import 'data.dart';

class MyCvMultiplePages extends StatefulWidget {
  const MyCvMultiplePages({
    Key? key,
    required this.user,
    required this.city,
    required this.province,
    required this.country,
    required this.myExperiences,
    required this.myPersonalExperiences,
    required this.myEducation,
    required this.mySecondaryEducation,
    required this.idSelectedDateEducation,
    required this.idSelectedDateSecondaryEducation,
    required this.idSelectedDateExperience,
    required this.idSelectedDatePersonalExperience,
    required this.competenciesNames,
    required this.languagesNames,
    required this.aboutMe,
    required this.myDataOfInterest,
    required this.myCustomEmail,
    required this.myCustomPhone,
    required this.myPhoto,
    required this.myCustomReferences,
    required this.myMaxEducation,
  }) : super(key: key);

  final UserEnreda? user;
  final String? city;
  final String? province;
  final String? country;
  final List<Experience>? myExperiences;
  final List<Experience>? myPersonalExperiences;
  final List<Experience>? myEducation;
  final List<Experience>? mySecondaryEducation;
  final List<String>? idSelectedDateEducation;
  final List<String>? idSelectedDateSecondaryEducation;
  final List<String>? idSelectedDateExperience;
  final List<String>? idSelectedDatePersonalExperience;
  final List<String> competenciesNames;
  final List<Language> languagesNames;
  final String? aboutMe;
  final List<String> myDataOfInterest;
  final String myCustomEmail;
  final String myCustomPhone;
  final String myMaxEducation;
  final bool myPhoto;
  final List<CertificationRequest>? myCustomReferences;

  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyCvMultiplePages> {
  int _selectedTemplateIndex = 0;
  PrintingInfo? printingInfo;
  var _data = const CustomData();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });
  }

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Constants.penLightBlue,
        content: Text('Documento impreso con éxito'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Constants.penLightBlue,
        content: Text('Documento compartido con éxito'),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    return await examplesMultiplePages[_selectedTemplateIndex].builder(
      format,
      _data,
      widget.user!,
      widget.city!,
      widget.province!,
      widget.country!,
      widget.myExperiences!,
      widget.myPersonalExperiences,
      widget.myEducation!,
      widget.mySecondaryEducation,
      widget.idSelectedDateEducation,
      widget.idSelectedDateSecondaryEducation,
      widget.idSelectedDateExperience,
      widget.idSelectedDatePersonalExperience,
      widget.competenciesNames,
      widget.languagesNames,
      widget.aboutMe,
      widget.myDataOfInterest,
      widget.myCustomEmail,
      widget.myCustomPhone,
      widget.myPhoto,
      widget.myCustomReferences,
      widget.myMaxEducation,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 71,
        backgroundColor: tealColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Hide default back button
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            // Custom Back Button
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Volver atrás',
                  style: TextStyle(
                    color: tealColor.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Print Button
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () async {
                await Printing.layoutPdf(
                    onLayout: (format) => _generatePdf(format));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'IMPRIMIR',
                      style: TextStyle(
                        color: tealColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.print, color: tealColor, size: 20),
                  ],
                ),
              ),
            ),
          ),
          // Download Button
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () async {
                final bytes = await _generatePdf(PdfPageFormat.a4);
                await Printing.sharePdf(
                    bytes: bytes,
                    filename:
                        '${widget.user?.firstName ?? ""} ${widget.user?.lastName ?? ""} CV.pdf'
                            .trim());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'DESCARGAR',
                      style: TextStyle(
                        color: tealColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.download, color: tealColor, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: examplesMultiplePages.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTemplateIndex == index;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTemplateIndex = index;
                          });
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFFA7E4E1)
                                : Colors.transparent, // Highlight color
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                              topLeft: Radius.circular(25),
                              bottomLeft: Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: tealColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                examplesMultiplePages[index].name,
                                style: TextStyle(
                                  color: tealColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Separator line
          Container(width: 1, color: Colors.grey[300]),
          // PDF Preview Area
          Expanded(
            child: PdfPreview(
              key: ValueKey(_selectedTemplateIndex),
              maxPageWidth: 700,
              build: (format) => _generatePdf(format),
              // We hide the default actions since we have custom ones in AppBar
              // Or we can keep them for functionality if the custom ones are just for show/external trigger.
              // Given the constraints, let's keep default actions visible for now or hide if we implement the logic.
              // The user asked for design, let's trust PdfPreview's own toolbar for actual functional heavy lifting for now
              // but hiding it to match the "clean" look of the screenshot might be desired.
              // The screenshot shows NO PdfPreview toolbar.
              // So we should try: useActions: false.
              useActions: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              initialPageFormat: PdfPageFormat.a4,
              onPrinted: _showPrintedToast,
              onShared: _showSharedToast,
              // To make our custom buttons work, we would need to generate the PDF and call Printing.layoutPdf or similar.
              // But PdfPreview wraps a lot of that.
              // For this iteration, we focus on the UI layout. Functionality of custom buttons to trigger PdfPreview actions
              // is complex without accessing its state. We will leave standard functionality accessible via PdfPreview if we don't hide it,
              // or just impl the UI as requested.
              // The screenshot implies the PdfPreview is just the document viewer.
            ),
          ),
        ],
      ),
    );
  }
}
