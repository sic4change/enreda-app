import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/resource_actions.dart';
import 'package:enreda_app/app/home/trainingPills/build_share_training_pill.dart';
import 'package:enreda_app/app/home/trainingPills/pages/meta_data_section.dart';
import 'package:enreda_app/app/home/trainingPills/pages/play_pause_button.dart';
import 'package:enreda_app/app/home/trainingPills/pages/training_pills_actions.dart';
import 'package:enreda_app/app/home/trainingPills/pages/video_position_seeker.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/video_thumbnail_area.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TrainingPillsListTileMobile extends StatefulWidget {
  TrainingPillsListTileMobile({Key? key, required this.trainingPill, this.onTap})
      : super(key: key);
  final TrainingPill trainingPill;
  final VoidCallback? onTap;
  static ValueNotifier<bool> isFullScreen = ValueNotifier<bool>(false);

  @override
  State<TrainingPillsListTileMobile> createState() => _TrainingPillsListTileMobileState();
}

class _TrainingPillsListTileMobileState extends State<TrainingPillsListTileMobile> {
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
    return ValueListenableBuilder<bool>(
        valueListenable: TrainingPillsListTileMobile.isFullScreen,
        builder: (BuildContext context, bool value, Widget? child) {
          return Column(
            children: [
              if (!_isVideoVisible) Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 1,
                          child: videoThumbnailArea(idYoutubeVideo)),
                      Expanded(
                          flex: 1,
                          child: videoDescription(AppColors.turquoiseBlue, AppColors.blue400)),
                    ]
                ),
              ),
              if(_isVideoVisible) YoutubePlayerControllerProvider(
                controller: _controller,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bluePetrol,
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
        });
  }

  Widget videoDescription(Color? colorTitle, Color? colorText) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 13, 14, md: 13);
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Container(
      height: 105,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
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
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  fontSize:  13,
                  color: colorTitle,
                ),
              ),
            ),
            Container(
              width: 155,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.trainingPill.title,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: textTheme.titleSmall?.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    fontSize:  fontSize,
                    color: colorText,
                  ),
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10,),
                InkWell(
                    onTap: () {
                      switch (widget.trainingPill.id){
                        case TrainingPill.WHAT_IS_ENREDA_ID:
                          setGamificationFlag(context: context, flagId: UserEnreda.FLAG_PILL_WHAT_IS_ENREDA);
                          break;
                      /*
                    case TrainingPill.TRAVEL_BEGINS_ID:
                      setGamificationFlag(context: context, flagId: UserEnreda.FLAG_PILL_TRAVEL_BEGINS);
                      break;
                    */
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
                      setState(() {
                        _isVideoVisible = !_isVideoVisible;
                        _initializeVideo(idYoutubeVideo);
                      });
                    },
                    child: Image.asset(ImagePath.ICON_PLAY, width: 30, height: 30,)
                ),
                SizedBox(width: 12,),
                Text(
                  '${widget.trainingPill.duration} min',
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.normal,
                    fontSize:  fontSize,
                    color: colorText,
                  ),
                ),
                SizedBox(width: 12,),
                buildShareTrainingPill(context, widget.trainingPill, Constants.grey),
                SizedBox(width: 0,),
                auth.currentUser == null
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          icon: FaIcon(FontAwesomeIcons.heart),
                          tooltip: 'Me gusta',
                          color: Constants.darkGray,
                          iconSize: 15,
                          onPressed: () => showAlertNullUser(context),
                        )
                      : widget.trainingPill.likes.contains(auth.currentUser!.uid)
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              icon: FaIcon(FontAwesomeIcons.solidHeart),
                              tooltip: 'Me gusta',
                              color: AppColors.red,
                              iconSize: 15,
                              onPressed: () {
                                removeUserToLikeTrainingPill(
                                    context: context,
                                    trainingPill: widget.trainingPill,
                                    userId: auth.currentUser!.uid);
                              },
                            )
                          : IconButton(
                              padding: EdgeInsets.zero,
                              icon: FaIcon(FontAwesomeIcons.heart),
                              tooltip: 'Me gusta',
                              color: Constants.darkGray,
                              iconSize: 15,
                              onPressed: () {
                                addUserToLikeTrainingPill(
                                    context: context,
                                    trainingPill: widget.trainingPill,
                                    userId: auth.currentUser!.uid);
                              },
                            )
                ],
            ),
          ]
        ),
      ),
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
        showFullscreenButton: true,
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
        TrainingPillsListTileMobile.isFullScreen.value = true;
        final currentTime =
        await FullscreenYoutubePlayer.launch(
          context,
          videoId: videoData.videoId,
          startSeconds: startSeconds,
        );
        if (currentTime != null) {
          _controller.seekTo(seconds: currentTime);
        }
        TrainingPillsListTileMobile.isFullScreen.value = false;
        _controller.seekTo(seconds: currentTime!);
      },
    );

  }

}