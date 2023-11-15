
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

///
class PlayPauseButtonBar extends StatelessWidget {
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          YoutubeValueBuilder(
            builder: (context, value) {
              return IconButton(
                icon: Icon(
                  value.playerState == PlayerState.playing
                      ? Icons.pause
                      : Icons.play_circle_filled,
                  size: 35,
                ),
                onPressed: () {
                  value.playerState == PlayerState.playing
                      ? context.ytController.pauseVideo()
                      : context.ytController.playVideo();
                },
              );
            },
          ),
          // ValueListenableBuilder<bool>(
          //   valueListenable: _isMuted,
          //   builder: (context, isMuted, _) {
          //     return IconButton(
          //       icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up, size: 35),
          //       onPressed: () {
          //         _isMuted.value = !isMuted;
          //         isMuted
          //             ? context.ytController.unMute()
          //             : context.ytController.mute();
          //       },
          //     );
          //   },
          // ),
          Spacer(),
        ],
      ),
    );
  }
}