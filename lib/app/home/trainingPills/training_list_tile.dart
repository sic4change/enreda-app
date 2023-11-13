import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/resources/resource_actions.dart';
import 'package:enreda_app/app/home/trainingPills/build_share_training_pill.dart';
import 'package:enreda_app/app/home/trainingPills/pages/training_pills_actions.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../services/auth.dart';

class TrainingPillListTile extends StatefulWidget {
  const TrainingPillListTile({Key? key, required this.trainingPill, this.onTap})
      : super(key: key);
  final TrainingPill trainingPill;
  final VoidCallback? onTap;

  @override
  State<TrainingPillListTile> createState() => _TrainingPillListTileState();
}

class _TrainingPillListTileState extends State<TrainingPillListTile> {
  late YoutubePlayerController _controller;
  bool _isVideoVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? _trainingPillListMobile()
        : _trainingPillListDesktop();
  }

  Widget _trainingPillListMobile() {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 12, 13, md: 12);
    String urlYoutubeVideo = widget.trainingPill.urlVideo;
    String idYoutubeVideo =
        urlYoutubeVideo.substring(urlYoutubeVideo.length - 11);
    //String idYoutubeVideo = YoutubePlayerController.convertUrlToId(urlYoutubeVideo) ?? "";
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Constants.white,
      ),
      child: Row(
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
                      fontSize: 13,
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
                Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          setState(() {
                            _isVideoVisible = !_isVideoVisible;
                            _initializeVideo(idYoutubeVideo);
                          });
                        },
                        icon: Icon(Icons.play_circle_filled),
                        color: AppColors.primaryText1,
                        iconSize: 27),
                    Text('${widget.trainingPill.duration} min',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.greyTxtAlt,
                        ))
                  ],
                ),
              ],
            ),
          ]),
    );
  }

  Widget _trainingPillListDesktop() {
    final auth = Provider.of<AuthBase>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 12, 13, md: 12);
    double sidePadding = responsiveSize(context, 15, 20, md: 17);
    final isBigScreen = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyBorder, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Constants.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyBorder,
                  spreadRadius: 0.2,
                  blurRadius: 1,
                  offset: Offset(0, 0),
                )
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: playAreaDesktop(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(sidePadding),
                                child: Text(
                                  widget.trainingPill.trainingPillCategoryName!,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  style: textTheme.titleSmall?.copyWith(
                                    color: Constants.lilac,
                                    height: 1.5,
                                    fontWeight: FontWeight.normal,
                                    fontSize: isBigScreen ? 18 : 15,
                                    //fontSize: fontSize,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: sidePadding,
                                    left: sidePadding,
                                    bottom: sidePadding / 2),
                                child: Text(
                                  widget.trainingPill.title.toUpperCase(),
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  style: TextStyle(
                                    letterSpacing: 1,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blueDark,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: sidePadding),
                                child: Text(
                                  widget.trainingPill.description,
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.greyTxtAlt,
                                    height: 1.5,
                                    fontWeight: FontWeight.normal,
                                    fontSize: fontSize,
                                    //fontSize: fontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: sidePadding, vertical: sidePadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Spacer(),
                            buildShareTrainingPill(
                                context, widget.trainingPill, Constants.grey),
                            SpaceW4(),
                            auth.currentUser == null
                                ? IconButton(
                                    icon: FaIcon(FontAwesomeIcons.heart),
                                    tooltip: 'Me gusta',
                                    color: Constants.darkGray,
                                    iconSize: 20,
                                    onPressed: () => showAlertNullUser(context),
                                  )
                                : widget.trainingPill.likes.contains(auth.currentUser!.uid)
                                    ? IconButton(
                                        icon:
                                            FaIcon(FontAwesomeIcons.solidHeart),
                                        tooltip: 'Me gusta',
                                        color: AppColors.red,
                                        iconSize: 20,
                                        onPressed: () {
                                          removeUserToLikeTrainingPill(
                                              context: context,
                                              trainingPill: widget.trainingPill,
                                              userId: auth.currentUser!.uid);
                                        },
                                      )
                                    : IconButton(
                                        icon: FaIcon(FontAwesomeIcons.heart),
                                        tooltip: 'Me gusta',
                                        color: Constants.darkGray,
                                        onPressed: () {
                                          addUserToLikeTrainingPill(
                                              context: context,
                                              trainingPill: widget.trainingPill,
                                              userId: auth.currentUser!.uid);
                                        },
                                      ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget playAreaMobile() {
    String urlYoutubeVideo = widget.trainingPill.urlVideo;
    String idYoutubeVideo =
        urlYoutubeVideo.substring(urlYoutubeVideo.length - 11);
    if (!_isVideoVisible)
      return AspectRatio(
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
                  fit: BoxFit.fitWidth,
                ),
                borderRadius: Responsive.isMobile(context)
                    ? BorderRadius.circular(10)
                    : BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
              ),
            ),
          ],
        ),
      );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
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

  Widget playAreaDesktop() {
    String urlYoutubeVideo = widget.trainingPill.urlVideo;
    String idYoutubeVideo =
        urlYoutubeVideo.substring(urlYoutubeVideo.length - 11);
    if (!_isVideoVisible)
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: InkWell(
          onTap: () async {
            setState(() {
              setState(() {
                _isVideoVisible = !_isVideoVisible;
                _initializeVideo(idYoutubeVideo);
              });
            });
          },
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
                    fit: BoxFit.fitWidth,
                  ),
                  borderRadius: Responsive.isMobile(context)
                      ? BorderRadius.circular(10)
                      : BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                ),
              ),
              Center(
                child: Icon(
                  Icons.play_circle_rounded,
                  color: AppColors.black100.withOpacity(0.7),
                  size: 70,
                ),
              ),
            ],
          ),
        ),
      );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: YoutubePlayerControllerProvider(
          // Provides controller to all the widget below it.
          controller: _controller,
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          )),
    );
  }

  _initializeVideo(String id) {
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
      if (_isVideoVisible == false) {
        _isVideoVisible = true;
      }
    });
  }
}
