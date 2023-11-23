import 'package:enreda_app/app/home/curriculum/pdf_generator/resume1_mobile.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Gamification extends StatefulWidget {
  const Gamification({super.key});

  @override
  State<Gamification> createState() => _GamificationState();
}

class _GamificationState extends State<Gamification> {
  String _userId = '';
  String _firstName = '';
  String _lastName = '';
  int _points = 10;
  Map<String,bool> _gamificationFlags = {};
  late TextTheme textTheme;

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
            _userId = userEnreda.userId ?? '';
            _firstName = userEnreda.firstName ?? '';
            _lastName = userEnreda.lastName ?? '';
            _gamificationFlags = userEnreda.gamificationFlags ?? {};
            ///TO DO  / Ajustar al campo correcto del usuario que contenga el contador de recursos
            _points = userEnreda.points ?? 0;
            _gamificationFlags.forEach((key, value) {
              print(key);
            });
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
                  SpaceH30(),
                  Wrap(
                    children: [
                      _getStepTile(UserEnreda.FLAG_PILL_TRAVEL_BEGINS),
                      _getStepTile(UserEnreda.FLAG_PILL_COMPETENCIES),
                      _getStepTile(UserEnreda.FLAG_PILL_CV_COMPETENCIES),
                      _getStepTile(UserEnreda.FLAG_PILL_HOW_TO_DO_CV),
                      _getStepTile(UserEnreda.FLAG_CHAT),
                      _getStepTile(UserEnreda.FLAG_EVALUATE_COMPETENCY),
                      _getStepTile(UserEnreda.FLAG_CV_FORMATION),
                      _getStepTile(UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION),
                      _getStepTile(UserEnreda.FLAG_CV_PERSONAL),
                      _getStepTile(UserEnreda.FLAG_CV_PROFESSIONAL),
                      _getStepTile(UserEnreda.FLAG_CV_ABOUT_ME),
                      _getStepTile(UserEnreda.FLAG_CV_PHOTO),
                      _getStepTile(UserEnreda.FLAG_CV_DATA_OF_INTEREST),
                    ]
                  ),
                  SpaceH12(),
                  Wrap(
                    alignment: WrapAlignment.center,
                     children: _gamificationFlags.entries.map((entry){
                       return Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Container(
                           height: 70,
                           width: 200,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.all(Radius.circular(8)),
                             color: entry.value ? Colors.greenAccent : Colors.grey,
                           ),
                           child: Center(
                             child:
                               Padding(
                                 padding: const EdgeInsets.all(4.0),
                                 child: Text(
                                     _getDescription(entry.key, entry.value,),
                                   textAlign: TextAlign.center,
                                 ),
                               )
                           ),
                         ),
                       );
                       return Text(entry.key);


                     }).toList()
                  ),
                ],
              ),
            );
            return Column(
              children: [
                Text(
                  '$_firstName $_lastName',
                  style:
                    textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Constants.grey,
                      fontSize: 14.0
                    ),
                ),
                SpaceH8(),
                Text(
                  'Puntos: ${_gamificationFlags['chat']}',
                  style:
                  textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Constants.penLightBlue,
                    fontSize: 14.0
                  ),
                ),

              ],
            );
          }
          else{
            return Container();
          }
        });
  }

  String _getDescription(String key, bool value){
    switch(key){
      case UserEnreda.FLAG_PILL_TRAVEL_BEGINS:
        return value ? '¡Felicidades! Ya has visto la píldora del inicio de viaje' :'Aún tienes que consumir la píldora del inicio del viaje';
      case UserEnreda.FLAG_PILL_COMPETENCIES:
        return value ? '¡Felicidades! Ya has visto la píldora sobre competencias' : 'Tienes pendiente ver la píldora de las competencias';
      case UserEnreda.FLAG_CHAT:
        return value ? 'Buen trabajo utilizando el chat' : 'Prueba a usar el chat';
      case UserEnreda.FLAG_EVALUATE_COMPETENCY:
        return value ? 'Has evaluado correctamente una competencia' : 'Todavia no has evaluado ninguna competencia';
      case UserEnreda.FLAG_PILL_CV_COMPETENCIES:
        return value ? '¡Genial! Ya has visto la píldora sobre las competencias del curriculum' : 'Echale un vistazo a la píldora sobre las competencias del curriculum';
      case UserEnreda.FLAG_PILL_HOW_TO_DO_CV:
        return value ? 'Seguro que has aprendido todo lo relacionado con tu curriculum' : 'Intenta ver la píldora del curriculum para no tener ninguna duda';
      case UserEnreda.FLAG_CV_FORMATION:
        return value ? 'Ya has incluido alguna formación a tu curriculum. ¡Bien hecho!' : 'Tu curriculum necesita alguna formación';
      case UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION:
        return value ? 'Tu curriculum está mucho más completo gracias a la formación complementaria' : 'Seguro que una formación complementaria le aportaría mucho a tu curriculum';
      case UserEnreda.FLAG_CV_PERSONAL:
        return value ? 'Ahora se te conocerá mejor gracias a las experiencias personales' : 'Las experiencias personales aportan valor al curriculum. Prueba a incluir alguna';
      case UserEnreda.FLAG_CV_PROFESSIONAL:
        return value ? '!Ya has incluido una experiencia profesional!' : 'Es importante incluir alguna experiencia profesional al curriculum';
      case UserEnreda.FLAG_CV_ABOUT_ME:
        return value ? 'Tu curriculum es mucho más personal con esa descripción ¡Genial!' : 'Agrega una pequeña descripción sobre ti a tu curriculum';
      case UserEnreda.FLAG_CV_PHOTO:
        return value ? 'Buen trabajo agregando una foto al curriculum ' : 'Prueba a incluir una foto a tu curriculum';
      case UserEnreda.FLAG_JOIN_RESOURCE:
        return value ? '¡Bien hecho uniendote a un recurso!' : 'Te sería muy útil unirte a un recurso';
      default:
        return '';
    }

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
          completedStars = 5;
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

  Widget _getStepTile(String step){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: 140,
        height: 160,
        decoration: BoxDecoration(
          color: (_gamificationFlags[step] ?? false) ? AppColors.yellowDark : AppColors.greymissing,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Icon(
                Icons.access_time_filled_sharp,
                color: Colors.grey,
                size: 40,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
              child: Text(
                textAlign: TextAlign.center,
                _getDescription(step, (_gamificationFlags[step] ?? false),
                )
              ),
            )
          ],
        )
      ),
    );
  }

}
