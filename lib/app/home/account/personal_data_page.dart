import 'package:enreda_app/app/home/account/personal_data_form.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({Key? key}) : super(key: key);

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    List<String> userInterestsIds = [];
    Set<Interest> userInterests = Set.from([]);
    Set<Interest> interests = {};
    List<String> interestsSelectedName = [];
    return StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<UserEnreda>(
                stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  if (snapshot.hasData) {
                    UserEnreda user = snapshot.data!;
                    userInterestsIds = user.interests;
                    if (userInterestsIds.isNotEmpty) {
                      return StreamBuilder<List<Interest>>(
                          stream: database.interestStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                            if (snapshot.hasData) {
                              interests = snapshot.data!.toSet();
                              return StreamBuilder<List<Interest>>(
                                  stream: database.interestsByUserStream(userInterestsIds),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                                    if (snapshot.hasData) {
                                      userInterests = snapshot.data!.toSet();
                                      for (Interest interest in userInterests) {
                                        interestsSelectedName.add(interest.name);
                                      }
                                      return PersonalDataForm(
                                        user: user,
                                        interestsSet: interests,
                                        userInterestsSelectedName: interestsSelectedName,
                                      );
                                    }
                                    return Container();
                                  });
                            }
                            return Container();
                          });
                    }
                    return PersonalDataForm(
                      user: user,
                      interestsSet: interests,
                      userInterestsSelectedName: interestsSelectedName,
                    );
                  }
                  return Container();
                });
          }
          return Container();
        });

  }
}