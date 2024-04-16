import 'dart:async';
import 'dart:io';

import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class MyPreviewPdf extends StatefulWidget {
  const MyPreviewPdf({
    Key? key,
    required this.url,
    required this. title,
  }) : super(key: key);

  final String? url;
  final String? title;

  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyPreviewPdf> with SingleTickerProviderStateMixin {

  int _tab = 0;
  TabController? _tabController;
  PrintingInfo? printingInfo;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _init() async {
    final info = await Printing.info();

    _tabController = TabController(
      vsync: this,
      length: 1,
      initialIndex: _tab,
    );
    setState(() {
      printingInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    pw.RichText.debug = true;

    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary100,
        iconTheme: const IconThemeData(color: AppColors.turquoiseBlue,),
        actionsIconTheme: const IconThemeData(color: AppColors.white,),
        foregroundColor: Colors.white,
        title: CustomTextBoldCenter(title: StringConst.PREVIEW, color: AppColors.turquoiseBlue,),
        titleTextStyle: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22.0),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: CustomTextBold(title: widget.title!,)),
          ],
          labelColor: Colors.white,
          labelStyle: TextStyle(fontSize: 20),
          isScrollable: true,
        ),
      ),
      body: PdfPreviewScreen(url: widget.url,),
    );
  }
}


class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String? url;
  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  Future<Uint8List> getPdfFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      throw Exception('Error retrieving PDF: $e');
    }
  }

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.turquoiseBlue,
        content: Text('Documento impreso con éxito'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.turquoiseBlue,
        content: Text('Documento compartido con éxito'),
      ),
    );
  }

  Future<void> _saveAsFile(
      BuildContext context,
      LayoutCallback build,
      PdfPageFormat pageFormat,
      ) async {
    final bytes = await build(pageFormat);

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File('$appDocPath/miCurriculum.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    // Replace this URL with your actual PDF URL
    String pdfUrl = widget.url!;

    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        )
    ];

    return FutureBuilder<Uint8List>(
      future: getPdfFromUrl(pdfUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PdfPreview(
            maxPageWidth: 700,
            build: (format) => snapshot.data!,
            canDebug: false,
            initialPageFormat: PdfPageFormat.a4,
            actions: actions,
            onPrinted: _showPrintedToast,
            onShared: _showSharedToast,
            canChangeOrientation: false,
            // Add additional settings if required
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load PDF.'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}