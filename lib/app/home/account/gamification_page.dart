import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/account/gamification_certificate.dart';
import 'package:enreda_app/app/home/curriculum/tooltip_video/training_tooltip_video.dart';
import 'package:enreda_app/app/home/models/gamificationFlags.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/precached_avatar.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Gamification extends StatefulWidget {
  const Gamification({super.key});

  @override
  State<Gamification> createState() => _GamificationState();
}

class _GamificationState extends State<Gamification> {
  String _firstName = '';
  String _lastName = '';
  int _points = 0;
  Map<String,bool> _gamificationFlags = {};
  List<GamificationFlag> _gamificationValues = [];
  late TextTheme textTheme;
  bool _allTasksDone = false;
  String userFullName = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    textTheme = Theme.of(context).textTheme;

    return StreamBuilder(
        stream: database.userStream(auth.currentUser!.email),
        builder: (context, snapshot){
          if (!snapshot.hasData) return Container();
          if(snapshot.hasData){
            final userEnreda = snapshot.data![0];
            _firstName = userEnreda.firstName ?? '';
            _lastName = userEnreda.lastName ?? '';
            userFullName = _firstName + ' ' + _lastName;
            _gamificationFlags = userEnreda.gamificationFlags;
            _points = 0;
            _gamificationFlags.forEach((key, value) {
              if(value == true){
                _points++;
                print(_points);
              }
            });
            print(_gamificationFlags);
            print('Puntos finales: $_points');
            return StreamBuilder(
              stream: database.gamificationFlagsStream(),
              builder: (context, snapshot){
                if(!snapshot.hasData) return Container();
                if(snapshot.hasData){
                  _gamificationValues = snapshot.data!;
                  _gamificationValues.forEach((element) {print(element.description);});

                  if (_gamificationFlags.length == _gamificationValues.length
                      && !_gamificationFlags.containsValue(false)){
                    _allTasksDone = true;
                  }

                  return Responsive.isDesktop(context)
                      ? _gamificationWeb()
                      : _gamificationMobile();
                }
                else{
                  return Container();
                }
              }
            );
          }
          else{
            return Container();
          }
        });
  }

  Widget _gamificationWeb(){
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            runSpacing: 20,
            spacing: 20,
            children: [
              _getStar('BRONCE'),
              _getStar('PLATA'),
              _getStar('ORO'),
            ],
          ),
          SpaceH20(),

          _allTasksDone ? _getCertificateButtonWeb(userFullName) : Container(),

          SpaceH20(),

          Wrap(
              children: [
                for(var item in _gamificationValues) _getStepTile(item),
              ]
          ),
        ],
      ),
    );
  }

  Widget _gamificationMobile(){
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            runSpacing: 15,
            spacing: 15,
            children: [
              _getStarMobile('BRONCE'),
              _getStarMobile('PLATA'),
              _getStarMobile('ORO'),
            ],
          ),
          SpaceH12(),
          for(var item in _gamificationValues) _getStepTileMobile(item),
          SpaceH12(),
          _allTasksDone ? _getCertificateButtonMobile(userFullName) : Container(),
        ],
      ),
    );
  }

  Widget _getStar(String order){
    int completedStars = 0;
    Color colorStar = Colors.black;
    String textStar = '';
    switch(order){
      case 'BRONCE':
        textStar = StringConst.BRONZE_STAR;
        colorStar = AppColors.bronze;
        if(_points >= 5){
          completedStars = 5;
        }
        else{
          completedStars = _points;
        }
      case 'PLATA':
        textStar = StringConst.SILVER_STAR;
        colorStar = AppColors.silver;
        if(_points <= 5){
          completedStars = 0;
        }
        else if(_points >= 10){
          completedStars = 5;
        }
        else{
          completedStars = _points - 5;
        }
      case 'ORO':
        textStar = StringConst.GOLD_STAR;
        colorStar = AppColors.gold;
        if(_points <= 10){
          completedStars = 0;
        }
        else if(_points >= 15){
          completedStars = 6;
        }
        else{
          completedStars = _points - 10;
        }
    }
    return Container(
      width: 220,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black,
          width: 1,
        )
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 2),
            child: Container(
              height: 60,
              width: 60,
              decoration: ShapeDecoration(
                color: (order == 'ORO' ? completedStars == 6 : completedStars == 5) ? colorStar : Colors.transparent,
                shape: StarBorder(
                  pointRounding: 0.2,
                  valleyRounding: 0.1,
                  side: BorderSide(
                      color: colorStar,
                      width: 2)
                ),
              ),
            ),
          ),
          Text(textStar),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[for(int index = 1; index<=5; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: ShapeDecoration(
                      color: completedStars >= index ? colorStar : Colors.transparent,
                      shape: StarBorder(
                          pointRounding: 0.2,
                          valleyRounding: 0.1,
                          side: BorderSide(
                              color: colorStar,
                              width: 1)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getStarMobile(String order){
    int completedStars = 0;
    Color colorStar = Colors.black;
    String textStar = '';
    switch(order){
      case 'BRONCE':
        textStar = StringConst.BRONZE_STAR;
        colorStar = AppColors.bronze;
        if(_points >= 5){
          completedStars = 5;
        }
        else{
          completedStars = _points;
        }
      case 'PLATA':
        textStar = StringConst.SILVER_STAR;
        colorStar = AppColors.silver;
        if(_points <= 5){
          completedStars = 0;
        }
        else if(_points >= 10){
          completedStars = 5;
        }
        else{
          completedStars = _points - 5;
        }
      case 'ORO':
        textStar = StringConst.GOLD_STAR;
        colorStar = AppColors.gold;
        if(_points <= 10){
          completedStars = 0;
        }
        else if(_points >= 15){
          completedStars = 5;
        }
        else{
          completedStars = _points - 10;
        }
    }
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.starsBackgroundColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 2),
            child: Container(
              height: 60,
              width: 60,
              decoration: ShapeDecoration(
                color: completedStars == 5 ? colorStar : Colors.transparent,
                shape: StarBorder(
                    pointRounding: 0.2,
                    valleyRounding: 0.1,
                    side: BorderSide(
                        color: colorStar,
                        width: 2)
                ),
              ),
            ),
          ),
          Text(
            textStar,
            style: TextStyle(
              fontSize: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[for(int index = 1; index<=5; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: ShapeDecoration(
                      color: completedStars >= index ? colorStar : Colors.transparent,
                      shape: StarBorder(
                          pointRounding: 0.2,
                          valleyRounding: 0.1,
                          side: BorderSide(
                              color: colorStar,
                              width: 1)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getStepTile(GamificationFlag item){
    bool completed = (_gamificationFlags[item.id]) ?? false;
    String pillId = item.id == UserEnreda.FLAG_PILL_WHAT_IS_ENREDA? TrainingPill.WHAT_IS_ENREDA_ID:
    item.id == UserEnreda.FLAG_PILL_COMPETENCIES? TrainingPill.WHAT_ARE_COMPETENCIES_ID:
    item.id == UserEnreda.FLAG_PILL_HOW_TO_DO_CV? TrainingPill.HOW_TO_DO_CV_ID:
    item.id == UserEnreda.FLAG_PILL_CV_COMPETENCIES? TrainingPill.CV_COMPETENCIES_ID: "";

    return InkWell(
      onTap: pillId.isNotEmpty? () => showDialog(context: context, useRootNavigator: false, builder: (dialogContext) =>
          Dialog(
            backgroundColor: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTrainingTooltipVideo(dialogContext, pillId),
              ],
            ),)): null,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: completed ? LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.yellowDark,
                    AppColors.yellowLight,
                  ]
              )
                  :
              LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.greyMissing,
                    AppColors.greyMissingLight,
                  ]
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child:
                    !kIsWeb ? CachedNetworkImage(
                        width: 40,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        alignment: Alignment.center,
                        imageUrl: completed ? item.iconEnabled : item.iconDisabled)
                        : PrecacheCompetencyCard(
                      imageUrl: completed ? item.iconEnabled : item.iconDisabled,
                      imageWidth: 40,
                    )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Text(
                    textAlign: TextAlign.center,
                    item.description,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: completed ? FontWeight.w500 : FontWeight.w400,
                      color: AppColors.greenDark,
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }

  Widget _getStepTileMobile(GamificationFlag item){
    double width = MediaQuery.of(context).size.width;
    bool completed = (_gamificationFlags[item.id]) ?? false;
    String pillId = item.id == UserEnreda.FLAG_PILL_WHAT_IS_ENREDA? TrainingPill.WHAT_IS_ENREDA_ID:
      item.id == UserEnreda.FLAG_PILL_COMPETENCIES? TrainingPill.WHAT_ARE_COMPETENCIES_ID:
      item.id == UserEnreda.FLAG_PILL_HOW_TO_DO_CV? TrainingPill.HOW_TO_DO_CV_ID:
      item.id == UserEnreda.FLAG_PILL_CV_COMPETENCIES? TrainingPill.CV_COMPETENCIES_ID: "";

    return InkWell(
      onTap: pillId.isNotEmpty? () => showDialog(context: context, useRootNavigator: false, builder: (dialogContext) =>
          Dialog(
            backgroundColor: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTrainingTooltipVideo(dialogContext, pillId),
              ],
            ),)): null,
      child: Column(
        children: [
          Divider(
            color: AppColors.starsBackgroundColor,
          ),
          Container(
              height: 50,
              width: width*0.95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23.5),
                gradient: completed ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.yellowDark,
                      AppColors.yellowLight,
                    ]
                )
                    : LinearGradient(colors: [Colors.transparent, Colors.transparent]),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 30, right: 12),
                      child: !kIsWeb ? CachedNetworkImage(
                          width: 32,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          alignment: Alignment.center,
                          imageUrl: completed ? item.iconEnabled : item.iconDisabled)
                          : PrecacheCompetencyCard(
                        imageUrl: completed ? item.iconEnabled : item.iconDisabled,
                        imageWidth: 40,
                      )
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2, right: 4),
                      child: Text(
                        item.description,
                        softWrap: true,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: completed ? FontWeight.w300 : FontWeight.w500,
                          color: AppColors.greenDark,
                        ),
                      ),
                    ),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget _getCertificateButtonWeb(String userFullName){
    return Center(
      child: Column(
        children: [
          _getCertificateImage(),
          SpaceH24(),

          EnredaButton(
              buttonTitle: "Descárgatelo",
              width: 150,
              height: 35,
              borderRadius:
              BorderRadius.all(
                Radius.circular(20),
              ),
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GamificationCertificate(name: userFullName,)
                    )
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _getCertificateButtonMobile(String userFullName){
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        width: width*0.95,
        height: 290,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.yellowDark,
              width: 3,
            )
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              _getCertificateImage(),
              SpaceH20(),

              EnredaButton(
                  buttonTitle: "Descárgatelo",
                  width: width*0.85,
                  height: 70,
                  borderRadius:
                  BorderRadius.all(
                    Radius.circular(15),
                  ),
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GamificationCertificate(name: userFullName)
                        )
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCertificateImage(){
    return Container(
      height: 160,
      width: 330,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage(ImagePath.WALL_STARS),
          fit: BoxFit.cover,
        )
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '¡Felicidades!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.greenDark,
              ),
            ),

            Text(
              '¡Has conseguido tu certificado!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.greenDark,
              ),
            ),

            SpaceH12(),

            Container(
              height: 100,
              width: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage(ImagePath.CERTIFICATE_ICON),
                  fit: BoxFit.cover,
                )
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildTrainingTooltipVideo(BuildContext context, String pillId) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<TrainingPill>(
        stream: database.trainingPillStreamById(pillId),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            TrainingPill trainingPill = snapshot.data!;
            trainingPill.setTrainingPillCategoryName();
            return Container(
              key: Key('trainingPill-${trainingPill.id}'),
              child: TrainingTooltipVideo(
                trainingPill: trainingPill,
                maxi: !Responsive.isMobile(context),
              ),
            );
          } else
            return Container();
        });
  }
}
