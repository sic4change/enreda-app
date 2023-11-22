import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
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
  int _points = 0;
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
            //_points = userEnreda.points ?? 0;
            _gamificationFlags.forEach((key, value) {
              print(key);
            });
            return Wrap(
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

}
