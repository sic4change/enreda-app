import 'dart:async';

import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/resources/resource_actions.dart';
import 'package:enreda_app/app/home/trainingPills/build_share_training_pill.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../services/database.dart';
import '../../../common_widgets/show_alert_dialog.dart';
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
              ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: playArea(),
              ),
              Expanded(
                flex: 2,
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
                                    fontSize:  isBigScreen ? 18 : 15,
                                    //fontSize: fontSize,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: sidePadding, left: sidePadding),
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
                                padding: EdgeInsets.all(sidePadding),
                                child: Text(
                                  widget.trainingPill.description,
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.greyTxtAlt,
                                    height: 1.5,
                                    fontWeight: FontWeight.normal,
                                    fontSize:  fontSize,
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
                        padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: sidePadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              mouseCursor: MaterialStateMouseCursor.clickable,
                              onTap: widget.onTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.greyTxtAlt, width: 1),
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Constants.white
                                ),
                                child: Text('Ver más', style: TextStyle(
                                  letterSpacing: 1,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greyTxtAlt,
                                ),),
                              ),
                            ),
                            Spacer(),
                            buildShareTrainingPill(context, widget.trainingPill, Constants.grey),
                            SpaceW4(),
                            auth.currentUser == null
                                ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.heart),
                              tooltip: 'Me gusta',
                              color: Constants.darkGray,
                              iconSize: 20,
                              onPressed: () => showAlertNullUser(context),
                            )
                                : widget.trainingPill.likes
                                .contains(auth.currentUser!.uid)
                                ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.solidHeart),
                              tooltip: 'Me gusta',
                              color: AppColors.red,
                              iconSize: 20,
                              onPressed: () {
                                _removeUserToLike(widget.trainingPill,
                                    auth.currentUser!.uid);
                              },
                            )
                                : IconButton(
                              icon: FaIcon(FontAwesomeIcons.heart),
                              tooltip: 'Me gusta',
                              color: Constants.darkGray,
                              onPressed: () {
                                _addUserToLike(widget.trainingPill);
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

  Future<void> _addUserToLike(TrainingPill trainingPill) async {
    if (_checkAnonymousUser()) {
      _showAlertUserAnonymousLike();
    } else {
      final auth = Provider.of<AuthBase>(context, listen: false);
      final database = Provider.of<Database>(context, listen: false);
      trainingPill.likes.add(auth.currentUser!.uid);
      await database.setTrainingPill(trainingPill);
    }
  }

  Future<void> _removeUserToLike(TrainingPill trainingPill, String userId) async {
    final database = Provider.of<Database>(context, listen: false);
    trainingPill.likes.remove(userId);
    await database.setTrainingPill(trainingPill);
  }

  bool _checkAnonymousUser() {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      return auth.currentUser!.isAnonymous;
    } catch (e) {
      print(e.toString());
      return true;
    }
  }

  _showAlertUserAnonymousLike() async {
    final didRequestSignOut = await showAlertDialog(context,
        title: '¿Te interesa este recurso?',
        content:
        'Solo los usuarios registrados pueden guardar como favoritos los recursos. ¿Desea entrar como usuario registrado?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Entrar');
    if (didRequestSignOut == true) {
      _signOut(context);
      Navigator.of(context).pop();
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Widget playArea() {
    if (!_isVideoVisible)
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImagePath.PLACEHOLDER_VIDEO),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              ),
            ),
            Center(
              child:  IconButton(
                onPressed: () async {
                  setState(() {
                    _isVideoVisible = !_isVideoVisible;
                    _initializeVideo(widget.trainingPill.urlVideo);
                  });
                },
                icon: Icon(Icons.play_circle_rounded, color: AppColors.greyTxtAlt.withOpacity(0.9), size: 55,),
              ),
            )
          ],
        ),
      );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: YoutubePlayerControllerProvider( // Provides controller to all the widget below it.
        controller: _controller,
        child: YoutubePlayerIFrame(
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }

  _initializeVideo(String id) {
    // Generate a new controller and set as global _controller
    final controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        autoPlay: true,
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ), initialVideoId: id,
    );
    setState(() {
      _controller = controller;
      if (_isVideoVisible == false) {
        _isVideoVisible = true;
      }
    });
  }

}
