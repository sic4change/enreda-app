import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ChatPillVideo extends StatefulWidget {
  const ChatPillVideo({Key? key, required this.trainingPill, required this.onNext})
      : super(key: key);
  final TrainingPill trainingPill;
  final VoidCallback onNext;

  @override
  State<ChatPillVideo> createState() => _ChatPillVideoState();
}

class _ChatPillVideoState extends State<ChatPillVideo> {
  late YoutubePlayerController _controller;
  bool _isVideoVisible = false;
  bool _hasContinued = false;
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

    return !_isVideoVisible /*&& !_hasContinued*/? Row(
      children: [
        Expanded(
          child: EnredaButton(
              height: 45.0,
              buttonTitle: "Ver vídeo",
              buttonColor: AppColors.turquoiseBlue,
              borderRadius: const BorderRadius.all(Radius.circular(Sizes.RADIUS_18),),
              titleStyle: textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0
              ),
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _isVideoVisible = !_isVideoVisible;
                  _initializeVideo(idYoutubeVideo);

                  switch (widget.trainingPill.id){
                    case TrainingPill.WHAT_ARE_COMPETENCIES_ID:
                      setGamificationFlag(context: context, flagId: UserEnreda.FLAG_PILL_COMPETENCIES);
                      break;
                    case TrainingPill.CV_COMPETENCIES_ID:
                      setGamificationFlag(context: context, flagId: UserEnreda.FLAG_PILL_CV_COMPETENCIES);
                      break;
                    case TrainingPill.HOW_TO_DO_CV_ID:
                      setGamificationFlag(context: context, flagId: UserEnreda.FLAG_PILL_HOW_TO_DO_CV);
                      break;
                    default:
                      break;
                  }
                });
              }
          ),
        ),
        SpaceW12(),
        Expanded(
          child: !Responsive.isMobile(context) && !Responsive.isTablet(context) && !_hasContinued? EnredaButton(
              height: 45.0,
              buttonTitle: "Omitir",
              buttonColor:  AppColors.blue050,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.all(Radius.circular(Sizes.RADIUS_18),),
              titleStyle: textTheme.bodySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0
              ),
              onPressed: () {
                setState(() {
                  widget.onNext();
                  _hasContinued = !_hasContinued;
                });
              }
          ): Container(),
        ),
      ],
    ): _isVideoVisible? Column(
      children: [
        YoutubePlayerControllerProvider(
          controller: _controller,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: playVideoArea())),
          ),
        ),
        if (!Responsive.isMobile(context) && !Responsive.isTablet(context) && _isVideoVisible && !_hasContinued)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: EnredaButton(
                height: 30.0,
                buttonTitle: "Seguir",
                buttonColor: AppColors.blue100,
                titleStyle: textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0
                ),
                onPressed: () {
                  setState(() {
                    _hasContinued = !_hasContinued;
                    widget.onNext();
                  });
                }
            ),
          ),
      ],
    ): Container();
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