import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:enreda_app/app/home/curriculum/pdf_generator/cv_multiple_pages.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/language.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';
import 'package:enreda_app/values/values.dart';
import '../../../../utils/const.dart';
import '../../models/experience.dart';
import 'data.dart';
import 'package:enreda_app/utils/responsive.dart';

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

    if (Responsive.isMobile(context)) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: null, // No internal AppBar on mobile to avoid double AppBars
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back & Download Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(ImagePath.ARROW_B, height: 30),
                    ),
                    InkWell(
                      onTap: () async {
                        final bytes = await _generatePdf(PdfPageFormat.a4);
                        final appDocDir = await getApplicationDocumentsDirectory();
                        final appDocPath = appDocDir.path;
                        final filename = '${widget.user?.firstName ?? ""} ${widget.user?.lastName ?? ""} CV.pdf'.trim();
                        final file = File('$appDocPath/$filename');
                        await file.writeAsBytes(bytes);
                        await OpenFilex.open(file.path);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D0CE),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Descargar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.download, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info Banner
                Row(
                  children: [
                    SvgPicture.asset(
                      ImagePath.ICON_EXCLAMATION,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Elige una plantilla para descargar tu currículum.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 16),

                // Template Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(examplesMultiplePages.length, (index) {
                    final isSelected = _selectedTemplateIndex == index;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTemplateIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFA7E4E1) : Colors.white,
                              border: Border.all(color: const Color(0xFF005B5B), width: 1.5),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: const Color(0xFF005B5B),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    examplesMultiplePages[index].name,
                                    style: const TextStyle(
                                      color: Color(0xFF005B5B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // PDF Preview Area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: PdfPreview(
                        key: ValueKey(_selectedTemplateIndex),
                        build: (format) => _generatePdf(format),
                        useActions: false,
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        canDebug: false,
                        initialPageFormat: PdfPageFormat.a4,
                        onPrinted: _showPrintedToast,
                        onShared: _showSharedToast,
                        scrollViewDecoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
            child: Container(
              color: const Color(0xFFF5F7FB),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 660),
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            ImagePath.ICON_EXCLAMATION,
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Elige una plantilla para descargar tu currículum.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PdfPreview(
                      key: ValueKey(_selectedTemplateIndex),
                      maxPageWidth: 700,
                      build: (format) => _generatePdf(format),
                      useActions: false,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      initialPageFormat: PdfPageFormat.a4,
                      onPrinted: _showPrintedToast,
                      onShared: _showSharedToast,
                      scrollViewDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
