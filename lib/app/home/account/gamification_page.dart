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
            //_points = userEnreda.points ?? 0;
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
                  'Puntos: ${_points}',
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

    return Text(auth.currentUser!.email!);
  }
}
