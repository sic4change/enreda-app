import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/trainingPills/pages/meta_data_section.dart';
import 'package:enreda_app/app/home/trainingPills/pages/play_pause_button.dart';
import 'package:enreda_app/app/home/trainingPills/pages/video_position_seeker.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/common_widgets/videos/video_thumbnail_area.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TrainingTooltipVideo extends StatefulWidget {
  const TrainingTooltipVideo({Key? key, required this.trainingPill})
      : super(key: key);
  final TrainingPill trainingPill;

  @override
  State<TrainingTooltipVideo> createState() => _TrainingTooltipVideoState();
}

class _TrainingTooltipVideoState extends State<TrainingTooltipVideo> {
  late YoutubePlayerController _controller;
  bool _isVideoVisible = false;
  late String urlYoutubeVideo;
  late String idYoutubeVideo;

  @override
  void initState() {
    super.initState();
    urlYoutubeVideo = widget.trainingPill.urlVideo;
    idYoutubeVideo = YoutubePlayerController.convertUrlToId(urlYoutubeVideo) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        if (!_isVideoVisible) Stack(
            children: [
              Container(
                  width: 300,
                  child: videoThumbnailArea(idYoutubeVideo)),
              Positioned(
                left: 20,
                right: 20,
                bottom: 60,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _isVideoVisible = !_isVideoVisible;
                      _initializeVideo(idYoutubeVideo);
                    });
                  },
                  icon: const Icon(
                    Icons.play_circle_fill_outlined,
                    color: Colors.white, size: 60,),),
              )
            ]
        ),
        if(_isVideoVisible) YoutubePlayerControllerProvider(
          controller: _controller,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
                        width: MediaQuery.of(context).size.width,
                        child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: playVideoArea())),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _isVideoVisible = !_isVideoVisible;
                            });
                          }
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        widget.trainingPill.trainingPillCategoryName!.toUpperCase(),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        style: textTheme.titleSmall?.copyWith(
                          height: 1.5,
                          fontWeight: FontWeight.normal,
                          fontSize:  13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SpaceH2(),
                    MetaDataSection(),
                    VideoPositionSeeker(),
                    PlayPauseButtonBar(),
                  ],
                ),

              ],
            ),
          ),
        )
      ],
    );
  }


  Widget playVideoArea() {
    return Container(
      child: YoutubePlayerControllerProvider(
        // Provides controller to all the widget below it.
          controller: _controller,
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
            enableFullScreenOnVerticalDrag: true,
          )),
    );
  }

  void _initializeVideo(String id) async {
    // Generate a new controller and set as global _controller
    final controller = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: false,
      ),
    );
    setState(() {
      _controller = controller;
      _isVideoVisible = true;
    });
    _controller..setFullScreenListener(
          (_) async {
        final videoData = await _controller.videoData;
        final startSeconds = await _controller.currentTime;
        final currentTime =
        await FullscreenYoutubePlayer.launch(
          context,
          videoId: videoData.videoId,
          startSeconds: startSeconds,
        );

        if (currentTime != null) {
          _controller.seekTo(seconds: currentTime);
        }
      },
    );
  }

}