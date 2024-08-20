
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

Widget videoThumbnailArea(String idYoutubeVideo) {
  return Container(
    child: AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: 'https://img.youtube.com/vi/${idYoutubeVideo}/maxresdefault.jpg',
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Image.asset(ImagePath.THUMBNAIL_DEFAULT),
            ),
          ),
        ],
      ),
    ),
  );
}