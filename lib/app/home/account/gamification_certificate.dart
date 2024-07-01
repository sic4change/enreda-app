import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class GamificationCertificate extends StatefulWidget {
  const GamificationCertificate({super.key, required this.name});

  final String name;

  @override
  State<GamificationCertificate> createState() => _GamificationCertificateState();
}

class _GamificationCertificateState extends State<GamificationCertificate> {

  @override
  Widget build(BuildContext context) {

    TextTheme textTheme = Theme.of(context).textTheme;
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary100,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: AppColors.primary900,),
            title: const Text('Mi certificado'),
            titleTextStyle: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary900,
                fontSize: 22.0),
          ),
          body: PdfPreview(
            maxPageWidth: 700,
            build: (format) => _generatePdf(format, 'title'),
            canDebug: false,
            onPrinted: _showPrintedToast,
            onShared: _showSharedToast,
            canChangeOrientation: false,
            canChangePageFormat: false,
          ),
        );
      }
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    /*
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final certificateImage = pw.MemoryImage((await rootBundle.load(ImagePath.WALL_STARS)).buffer.asUint8List(),);

    await imageFromAssetBundle(ImagePath.WALL_STARS);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Container(
            height: 1414,
            width: 2000,
            decoration: pw.BoxDecoration(
                image: pw.DecorationImage(
                  image: pw.Image(certificateImage) as pw.ImageProvider,

                  fit: pw.BoxFit.cover,
                )
            ),
          );
        },
      ),
    );

    return pdf.save();*/

    final lorem = pw.LoremText();
    final pdf = pw.Document();

    final libreBaskerville = await PdfGoogleFonts.libreBaskervilleRegular();
    final libreBaskervilleItalic = await PdfGoogleFonts.libreBaskervilleItalic();
    final libreBaskervilleBold = await PdfGoogleFonts.libreBaskervilleBold();
    final robotoLight = await PdfGoogleFonts.robotoLight();
    final medail = await rootBundle.loadString(ImagePath.MEDAIL);
    final swirls = await rootBundle.loadString(ImagePath.SWIRLS);
    final swirls1 = await rootBundle.loadString(ImagePath.SWIRLS1);
    final swirls2 = await rootBundle.loadString(ImagePath.SWIRLS2);
    final swirls3 = await rootBundle.loadString(ImagePath.SWIRLS3);
    final garland = await rootBundle.loadString(ImagePath.GARLAND);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Spacer(flex: 2),
            pw.RichText(
              text: pw.TextSpan(
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 25,
                  ),
                  children: [
                    const pw.TextSpan(text: 'CERTIFICADO '),
                    pw.TextSpan(
                      text: 'de',
                      style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                    const pw.TextSpan(text: ' ENREDA'),
                  ]),
            ),
            pw.Spacer(),
            pw.Text(
              'ACREDITA QUE',
              style: pw.TextStyle(
                font: robotoLight,
                fontSize: 10,
                letterSpacing: 2,
                wordSpacing: 2,
              ),
            ),
            pw.SizedBox(
              width: 300,
              child: pw.Divider(color: PdfColors.grey, thickness: 1.5),
            ),
            pw.Text(
              ///TO DO
              widget.name,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 20,
              ),
            ),
            pw.SizedBox(
              width: 300,
              child: pw.Divider(color: PdfColors.grey, thickness: 1.5),
            ),
            pw.Text(
              'HA COMPLETADO SATISFACTORIAMENTE LA',
              style: pw.TextStyle(
                font: robotoLight,
                fontSize: 10,
                letterSpacing: 2,
                wordSpacing: 2,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.SvgImage(
                  svg: swirls,
                  height: 10,
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Text(
                    'Gamificación de enreda',
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Transform(
                  transform: Matrix4.diagonal3Values(-1, 1, 1),
                  adjustLayout: true,
                  child: pw.SvgImage(
                    svg: swirls,
                    height: 10,
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            pw.SvgImage(
              svg: swirls2,
              width: 150,
            ),
            pw.Spacer(),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Flexible(
                  child: pw.Text(
                    lorem.paragraph(40),
                    style: const pw.TextStyle(fontSize: 6),
                    textAlign: pw.TextAlign.justify,
                  ),
                ),
                pw.SizedBox(width: 100),
                pw.SvgImage(
                  svg: medail,
                  width: 100,
                ),
              ],
            ),
          ],
        ),
        pageTheme: pw.PageTheme(
          //pageFormat: pageFormat,
          theme: pw.ThemeData.withFont(
            base: libreBaskerville,
            italic: libreBaskervilleItalic,
            bold: libreBaskervilleBold,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              margin: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: const PdfColor.fromInt(0xffe435), width: 1),
              ),
              child: pw.Container(
                margin: const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: const PdfColor.fromInt(0xffe435), width: 5),
                ),
                width: double.infinity,
                height: double.infinity,
                child: pw.Stack(
                  alignment: pw.Alignment.center,
                  children: [
                    pw.Positioned(
                      top: 5,
                      child: pw.SvgImage(
                        svg: swirls1,
                        height: 60,
                      ),
                    ),
                    pw.Positioned(
                      bottom: 5,
                      child: pw.Transform(
                        transform: Matrix4.diagonal3Values(1, -1, 1),
                        adjustLayout: true,
                        child: pw.SvgImage(
                          svg: swirls1,
                          height: 60,
                        ),
                      ),
                    ),
                    pw.Positioned(
                      top: 5,
                      left: 5,
                      child: pw.SvgImage(
                        svg: swirls3,
                        height: 160,
                      ),
                    ),
                    pw.Positioned(
                      top: 5,
                      right: 5,
                      child: pw.Transform(
                        transform: Matrix4.diagonal3Values(-1, 1, 1),
                        adjustLayout: true,
                        child: pw.SvgImage(
                          svg: swirls3,
                          height: 160,
                        ),
                      ),
                    ),
                    pw.Positioned(
                      bottom: 5,
                      left: 5,
                      child: pw.Transform(
                        transform: Matrix4.diagonal3Values(1, -1, 1),
                        adjustLayout: true,
                        child: pw.SvgImage(
                          svg: swirls3,
                          height: 160,
                        ),
                      ),
                    ),
                    pw.Positioned(
                      bottom: 5,
                      right: 5,
                      child: pw.Transform(
                        transform: Matrix4.diagonal3Values(-1, -1, 1),
                        adjustLayout: true,
                        child: pw.SvgImage(
                          svg: swirls3,
                          height: 160,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                        top: 120,
                        left: 80,
                        right: 80,
                        bottom: 80,
                      ),
                      child: pw.SvgImage(
                        svg: garland,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return pdf.save();
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


}
