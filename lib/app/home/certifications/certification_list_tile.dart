import 'dart:io';

import 'package:enreda_app/app/home/certifications/pdf/pdf_api.dart';
import 'package:enreda_app/app/home/certifications/pdf/pdf_viewer_page.dart';
import 'package:enreda_app/app/home/models/certificate.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CertificationListTile extends StatelessWidget {
  const CertificationListTile({Key? key, required this.certificate, this.onTap})
      : super(key: key);
  final Certificate certificate;
  final VoidCallback? onTap;

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30.0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Constants.lightViolet,
        ),
        child: Row(
          children: <Widget>[
        InkWell(
          mouseCursor: MaterialStateMouseCursor.clickable,
          onTap: () => _launchURL(context, 'certificates/${certificate.certificateId}/certificatePic'),
          child: CircleAvatar(
            radius: 30,
          backgroundColor: Constants.lightViolet,
          backgroundImage:  certificate.certificate == null ? NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/enreda-d3b41.appspot.com/o/no_certificate.png?alt=media&token=619e1053-355c-4709-bd36-267d72732f89') :
          NetworkImage('https://firebasestorage.googleapis.com/v0/b/enreda-d3b41.appspot.com/o/certificate.png?alt=media&token=a7a2e838-a6a8-4a8d-83ca-f8e790a2dd79'),
      ),
        ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(certificate.resourceName??'',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Constants.textDark
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(certificate.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Constants.textPrimary,
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(certificate.finished ? 'Completado': 'No completado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: certificate.finished ? Constants.blueLight : Constants.salmonDark,
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    DateFormat('dd/MM/yyyy').format(certificate.date),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Constants.salmonDark),
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  _launchURL(BuildContext context, String url) async {
    final file = await PDFApi.loadFirebase(url);

    if (file == null) return;
    openPDF(context, file);

  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  );
  
}
