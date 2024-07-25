import 'package:enreda_app/app/home/cupertino_scaffold.dart';
import 'package:enreda_app/app/home/cupertino_scaffold_anonymous.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/show_toast.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/adaptive.dart';
import '../../../utils/functions.dart';
import '../../../values/values.dart';
import '../../anallytics/analytics.dart';

Future<void> addUserToLike(
    {required BuildContext context,
    required String userId,
    required Resource resource}) async {
    final database = Provider.of<Database>(context, listen: false);
    resource.likes.add(userId);
    await database.setResource(resource);
  }

Future<void> removeUserToLike(
    {required BuildContext context,
    required String userId,
    required Resource resource}) async {
    final database = Provider.of<Database>(context, listen: false);
    resource.likes.remove(userId);
    await database.setResource(resource);
}

Future<void> addUserToResource(
    {required BuildContext context,
    required String userId,
    required Resource resource}) async {
  final database = Provider.of<Database>(context, listen: false);
  resource.participants.add(userId);
  resource.assistants = resource.participants.length.toString();
  await database.setResource(resource);
  showToast(context,
      title: 'Se ha apuntado satisfactoriamente al recurso',
      color: AppColors.primaryColor);
  sendResourceAnalyticsEvent(context, "enreda_app_subscribe_resource", resource.resourceTypeName!);
}

Future<void> removeUserToResource(
    {required BuildContext context,
    required String userId,
    required Resource resource}) async {
  final database = Provider.of<Database>(context, listen: false);
  resource.participants.remove(userId);
  resource.assistants = resource.participants.length.toString();
  await database.setResource(resource);
  showToast(context,
      title: 'Ha sido eliminado satisfactoriamente al recurso',
      color: AppColors.primaryColor);
}

Future<void> shareResource(Resource resource) async {
  await Share.share(
    StringConst.SHARE_TEXT(resource.title, resource.resourceId),
    subject: StringConst.APP_NAME,
  );
}

void showAlertNullUser(BuildContext context) async {
  final isSmallScreen = Responsive.isMobile(context);
  final signIn = await showAlertDialog(context,
      title: '¿Te interesa este recurso?',
      content:
          'Solo los usuarios registrados pueden acceder a los recursos internos. ¿Deseas entrar como usuario registrado?',
      cancelActionText: 'Cancelar',
      defaultActionText: 'Entrar');
  if (signIn == true) {
    if(!isSmallScreen) {
      WebHome.selectedIndex.value = 0;
    }
    if(isSmallScreen) {
      CupertinoScaffoldAnonymous.controller.index = 2;
    }
  }
}

Future<dynamic> showContactDialog(
    {required BuildContext context, required Resource resource}) {
  double fontSize = responsiveSize(context, 15, 20, md: 18);
  return showCustomDialog(context,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: Constants.mainPadding,
          ),
          Text(
              StringConst.INTERESTED,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Constants.darkGray,
                fontSize: fontSize,
              )),
          SizedBox(
            height: Constants.mainPadding * 1.5,
          ),
          if (resource.contactEmail != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail,
                  color: Constants.darkLilac,
                  size: fontSize,
                ),
                SpaceH8(),
                TextButton(
                    onPressed: () => launchURL('mailto:${resource.contactEmail}?subject=Inscripción ${resource.title}'),
                    child: Text(
                        resource.contactEmail!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Constants.darkLilac,
                          fontSize: fontSize,
                        )
                    ),
                ),
              ],
            ),
          if (resource.contactEmail != null && resource.contactPhone != null)
            SizedBox(
              height: Constants.mainPadding,
            ),
          if (resource.contactPhone != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone,
                  color: Constants.darkLilac,
                  size: fontSize,
                ),
                SpaceH8(),
                kIsWeb
                    ? Text(
                        resource.contactPhone!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Constants.darkLilac,
                        fontSize: fontSize,
                      )
                )
                    :
                  TextButton(
                      onPressed: () => launchURL("tel://${resource.contactPhone}"),
                      child: Text(
                          resource.contactPhone!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Constants.darkLilac,
                            fontSize: fontSize,
                          )),
                  )
              ],
            ),
        ],
      ),
      defaultActionText: 'Ok',
  onDefaultActionPressed: (context) => Navigator.of(context).pop(true));
}
