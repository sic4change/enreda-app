
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

Widget videoThumbnailArea(String idYoutubeVideo) {
  return Container(
    child: AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: AppColors.blue050, width: 1.0),
              image: DecorationImage(
                image: NetworkImage(
                  YoutubePlayerController.getThumbnail(
                    videoId: idYoutubeVideo,
                    quality: ThumbnailQuality.max,
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
