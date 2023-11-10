import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../common_widgets/show_alert_dialog.dart';


bool _checkAnonymousUser(BuildContext context) {
  try {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return auth.currentUser!.isAnonymous;
  } catch (e) {
    print(e.toString());
    return true;
  }
}

_showAlertUserAnonymousLike(BuildContext context) async {
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

Future<void> addUserToLikeTrainingPill(
    {required BuildContext context,
      required String userId,
      required TrainingPill trainingPill}) async {
  if (_checkAnonymousUser(context)) {
    _showAlertUserAnonymousLike(context);
  } else {
    final database = Provider.of<Database>(context, listen: false);
    trainingPill.likes.add(userId);
    await database.setTrainingPill(trainingPill);
  }
}

Future<void> removeUserToLikeTrainingPill(
    {required BuildContext context,
      required String userId,
      required TrainingPill trainingPill}) async {
  final database = Provider.of<Database>(context, listen: false);
  trainingPill.likes.remove(userId);
  await database.setTrainingPill(trainingPill);
}

Future<void> shareTrainingPill(TrainingPill trainingPill) async {
  await Share.share(
    StringConst.SHARE_TEXT_PILLS(trainingPill.title, trainingPill.id),
    subject: StringConst.APP_NAME,
  );
}
