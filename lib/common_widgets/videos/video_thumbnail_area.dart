
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
              image: DecorationImage(
                image: NetworkImage(
                  YoutubePlayerController.getThumbnail(
                    videoId: idYoutubeVideo,
                    quality: ThumbnailQuality.max,
                  ),
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    ),
  );
}