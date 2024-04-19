import 'dart:async';
import 'dart:html' as html;

Future downloadDocument (String urlDocument, String documentName) async {
  html.AnchorElement anchorElement = html.AnchorElement(href: urlDocument);
  anchorElement.download = documentName;
  anchorElement.click();
}
