import 'package:enreda_app/app/home/account/personal_data_form.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/services/location_cache.dart';
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

    return StreamBuilder<UserEnreda>(
      stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final UserEnreda user = snapshot.data!;
        final userInterestsIds = user.interests;

        // Load interests from cache if available; fall back to individual fetches
        final cachedInterests = LocationCache.instance.interests;
        final cachedSpecificInterests = LocationCache.instance.specificInterests;

        if (userInterestsIds.isEmpty) {
          // No interests to resolve — render immediately
          return PersonalDataForm(
            user: user,
            interestsSet: cachedInterests.toSet(),
            userInterestsSelectedName: [],
            specificInterestsSet: cachedSpecificInterests.toSet(),
          );
        }

        if (cachedInterests.isNotEmpty && cachedSpecificInterests.isNotEmpty) {
          // Both in cache — zero extra reads
          final userInterests = cachedInterests
              .where((i) => userInterestsIds.contains(i.interestId))
              .toSet();
          final selectedNames = userInterests.map((i) => i.name).toList();
          return PersonalDataForm(
            user: user,
            interestsSet: cachedInterests.toSet(),
            userInterestsSelectedName: selectedNames,
            specificInterestsSet: cachedSpecificInterests.toSet(),
          );
        }

        // Cache miss: fetch once and render
        return FutureBuilder<List<List<dynamic>>>(
          future: Future.wait([
            database.interestStream().first,
            database.specificInterestsStream().first,
          ]),
          builder: (context, futureSnapshot) {
            if (!futureSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final List<Interest> allInterests =
                (futureSnapshot.data![0] as List<Interest>);
            final List<SpecificInterest> allSpecificInterests =
                (futureSnapshot.data![1] as List<SpecificInterest>);

            // Populate cache for future use
            LocationCache.instance.setInterests(allInterests);
            LocationCache.instance.setSpecificInterests(allSpecificInterests);

            final userInterests = allInterests
                .where((i) => userInterestsIds.contains(i.interestId))
                .toSet();
            final selectedNames = userInterests.map((i) => i.name).toList();

            return PersonalDataForm(
              user: user,
              interestsSet: allInterests.toSet(),
              userInterestsSelectedName: selectedNames,
              specificInterestsSet: allSpecificInterests.toSet(),
            );
          },
        );
      },
    );
  }
}