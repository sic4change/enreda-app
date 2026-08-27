import 'package:enreda_app/app/home/account/companion_data_form.dart';
import 'package:enreda_app/app/home/models/companion_data.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanionDataPage extends StatefulWidget {
  const CompanionDataPage({Key? key}) : super(key: key);

  @override
  State<CompanionDataPage> createState() => _CompanionDataPageState();
}

class _CompanionDataPageState extends State<CompanionDataPage> {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);

    return StreamBuilder<UserEnreda>(
      stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final UserEnreda user = userSnapshot.data!;

        return StreamBuilder<CompanionData?>(
          stream: database.companionDataStream(user.userId ?? auth.currentUser!.uid, user.email),
          builder: (context, companionSnapshot) {
            if (companionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final CompanionData? companionData = companionSnapshot.data;

            return CompanionDataForm(
              user: user,
              companionData: companionData,
            );
          },
        );
      },
    );
  }
}
