import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnredaContactPage extends StatefulWidget {
  const EnredaContactPage({Key? key}) : super(key: key);

  @override
  State<EnredaContactPage> createState() => _EnredaContactPageState();
}

class _EnredaContactPageState extends State<EnredaContactPage> {
  String? _assignedEntityId;
  UserEnreda? _assignedUser;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return RoundedContainer(
      child: StreamBuilder<User?>(
          stream: Provider.of<AuthBase>(context).authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            if (snapshot.hasData) {
              return StreamBuilder<List<UserEnreda>>(
                stream: database.userStream(auth.currentUser!.email),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  if (snapshot.hasData) {
                    final userEnreda = snapshot.data![0];
                    _assignedEntityId = userEnreda.assignedEntityId;
                    return  StreamBuilder<UserEnreda>(
                      stream: database.userAssignedIdStream(_assignedEntityId!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
                        if (snapshot.hasData) {
                          final assignedUser = snapshot.data!;
                          _assignedUser = assignedUser;
                          return Container();
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          })
    );
  }

}
