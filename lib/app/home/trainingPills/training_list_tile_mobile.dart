import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ListTileMobile extends StatefulWidget {
  const ListTileMobile({Key? key, required this.trainingPill, this.onTap})
      : super(key: key);
  final TrainingPill trainingPill;
  final VoidCallback? onTap;

  @override
  State<ListTileMobile> createState() => _ListTileMobileState();
}

class _ListTileMobileState extends State<ListTileMobile>  with MaterialStateMixin {
  late YoutubePlayerController _controller;
  bool _isVideoVisible = false;
  late String urlYoutubeVideo;
  late String idYoutubeVideo;

  @override
  void initState() {
    super.initState();
    urlYoutubeVideo = widget.trainingPill.urlVideo;
    //idYoutubeVideo = urlYoutubeVideo.substring(urlYoutubeVideo.length - 11);
    idYoutubeVideo = YoutubePlayerController.convertUrlToId(urlYoutubeVideo) ?? "";
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
    _initializeVideo(idYoutubeVideo);
  }

  _initializeVideo(String id) async {
    // Generate a new controller and set as global _controller
    final controller = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
      ),
    );
    setState(() {
      _controller = controller;
      _isVideoVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 12, 13, md: 12);
    return YoutubePlayerControllerProvider(
    controller: _controller,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 8.0),
                    child: playAreaMobile()),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        widget.trainingPill.trainingPillCategoryName!.toUpperCase(),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        style: textTheme.titleSmall?.copyWith(
                          color: Constants.lilac,
                          height: 1.5,
                          fontWeight: FontWeight.normal,
                          fontSize:  13,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        widget.trainingPill.title,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          letterSpacing: 1,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greyTxtAlt,
                        ),
                      ),
                    ),
                    YoutubeValueBuilder(
                        builder: (context, value) {
                          return IconButton(
                            icon: Icon(
                              value.playerState == PlayerState.playing
                                  ? Icons.pause
                                  : Icons.play_circle_filled,
                              color: AppColors.primaryText1,
                            ),
                            onPressed: () {
                              value.playerState == PlayerState.playing
                                  ? context.ytController.enterFullScreen()
                                  : context.ytController.exitFullScreen();
                            },
                          );
                        },
                      ),
                    ],
                ),
              ]
          ),

        ],
      ),
    ),
  );
  }


Widget playAreaMobile() {
  String urlYoutubeVideo = widget.trainingPill.urlVideo;
  String idYoutubeVideo =
  urlYoutubeVideo.substring(urlYoutubeVideo.length - 11);

    return Stack(
      children: [
        YoutubeValueBuilder(
          controller: _controller,
          builder: (context, value) {
            return Card(
              child: YoutubePlayer(
                key: ObjectKey(_controller),
                aspectRatio: 16 / 9,
                enableFullScreenOnVerticalDrag: true,
                controller: _controller
                  ..setFullScreenListener(
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
                  ),
              ),
            );
          },
        ),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 20,
                    )
                  ],
                  image: DecorationImage(
                    image: NetworkImage(
                      YoutubePlayerController.getThumbnail(
                        videoId: idYoutubeVideo,
                        quality: ThumbnailQuality.max,
                      ),
                    ),
                    fit: BoxFit.fitWidth,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}