library globals;

import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';

Resource? currentResource;
SocialEntity? organizerCurrentResource;
String? interestsNamesCurrentResource;
String? competenciesNamesCurrentResource;
Set<Interest> selectedInterestsCurrentResource = {};
Set<Competency> selectedCompetenciesCurrentResource = {};
List<String> interestsCurrentResource = [];
UserEnreda? currentParticipant;
UserEnreda? currentSocialEntityUser;
SocialEntity? currentSocialEntity;