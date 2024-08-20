import 'dart:typed_data';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Future<Uint8List?> fetchImageBytes(String url) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'origin': 'https://enredawebapp.web.app/',
        'x-requested-with': 'XMLHttpRequest',
      },
    );
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
  } catch (e) {
    print(e);
  }
  return null;
}

class NetworkImageWithHeaders extends StatelessWidget {
  final String url;

  const NetworkImageWithHeaders({required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: fetchImageBytes(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(snapshot.data!);
          } else {
            return Center(child: CustomTextSmall(text: 'Failed to load image', color: Colors.white,));
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}