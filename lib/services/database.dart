import 'dart:typed_data';

import 'package:enreda_app/app/home/models/ability.dart';
import 'package:enreda_app/app/home/models/certificate.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/contact.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/dedication.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/app/home/models/filterResource.dart';
import 'package:enreda_app/app/home/models/gender.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/mentorUser.dart';
import 'package:enreda_app/app/home/models/nature.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/organizationUser.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/scope.dart';
import 'package:enreda_app/app/home/models/size.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/app/home/models/timeSearching.dart';
import 'package:enreda_app/app/home/models/timeSpentWeekly.dart';
import 'package:enreda_app/app/home/models/unemployedUser.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/models/chatQuestion.dart';
import 'package:enreda_app/common_widgets/remove_diacritics.dart';
import 'package:enreda_app/services/api_path.dart';
import 'package:enreda_app/services/firestore_service.dart';
import 'package:enreda_app/utils/resourceTypeMapping.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../app/home/models/certificationRequest.dart';
import '../app/home/models/resourcePicture.dart';
import '../app/home/models/activity.dart';
import '../app/home/models/question.dart';

abstract class Database {
  Stream<Resource> resourceStream(String resourceId);
  Stream<List<Resource>> resourcesStream();
  //Stream<List<Resource>> filteredResourcesStream(FilterResource filter);
  Stream<List<Resource>> filteredResourcesCategoryStream(FilterResource filter);
  Stream<List<Resource>> myResourcesStream(String userId);
  Stream<List<Resource>> likeResourcesStream(String userId);
  Stream<List<Resource>> recommendedResourcesStream(UserEnreda? user);
  Stream<UserEnreda> enredaUserStream(String userId);
  Stream<List<Certificate>> myCertificatesStream(String userId);
  Stream<List<Organization>> organizationsStream();
  Stream<Organization> organizationStream(String organizationId);
  Stream<UserEnreda> mentorStream(String mentorId);
  Stream<List<Country>> countriesStream();
  Stream<List<Country>> countryFormatedStream();
  Stream<Country> countryStream(String? countryId);
  Stream<List<Province>> provincesStream();
  Stream<Province> provinceStream(String? provinceId);
  Stream<List<Province>> provincesCountryStream(String? countryId);
  Stream<List<City>> citiesStream();
  Stream<City> cityStream(String? cityId);
  Stream<ResourcePicture> resourcePictureStream(String? resourcePictureId);
  Stream<List<City>> citiesProvinceStream(String? provinceId);
  Stream<List<UserEnreda>> userStream(String? email);
  Stream<UserEnreda> userEnredaStreamByUserId(String? userId);
  Stream<List<Nature>> natureStream();
  Stream<List<Scope>> scopeStream();
  Stream<List<SizeOrg>> sizeStream();
  Stream<List<Ability>> abilityStream();
  Stream<List<Dedication>> dedicationStream();
  Stream<List<TimeSearching>> timeSearchingStream();
  Stream<List<TimeSpentWeekly>> timeSpentWeeklyStream();
  Stream<List<Education>> educationStream();
  Stream<List<Gender>> genderStream();
  Stream<List<Interest>> interestStream();
  Stream<List<SpecificInterest>> specificInterestStream(String? interestId);
  Stream<List<UserEnreda>> checkIfUserEmailRegistered(String email);
  Stream<List<Question>> questionsStream();
  Stream<Question> questionStream(String id);
  Stream<List<Choice>> choicesStream(String path, String? typeId, String? subtypeId);
  Stream<List<Experience>> myExperiencesStream(String userId);
  Stream<List<Competency>> competenciesStream();
  Stream<Competency> competencyStream(String id);
  Stream<Activity> activtyStream(String id);
  Stream<List<ChatQuestion>> chatQuestionsStream(String userId);
  Stream<CertificationRequest> certificationRequestStream(String certificationRequestId);

  Future<void> setUserEnreda(UserEnreda userEnreda);
  Future<void> addUserEnreda(UserEnreda userEnreda);
  Future<void> deleteUser(UserEnreda userEnreda);
  Future<void> uploadUserAvatar(String userId, Uint8List data);
  Future<void> addContact(Contact contact);
  Future<void> addResource(Resource resource);
  Future<void> setResource(Resource resource);
  Future<void> deleteResource(Resource resource);
  Future<void> addUnemployedUser(UnemployedUser unemployedUser);
  Future<void> addMentorUser(MentorUser mentorUser);
  Future<void> addOrganizationUser(OrganizationUser organizationUser);
  Future<void> addOrganization(Organization organization);
  Future<void> addChatQuestion(ChatQuestion chatQuestion);
  Future<void> updateChatQuestion(ChatQuestion chatQuestion);
  Future<void> addExperience(Experience experience);
  Future<void> updateExperience(Experience experience);
  Future<void> deleteExperience(Experience experience);
  Future<void> addCertificationRequest(CertificationRequest certificationRequest);
  Future<void> updateCertificationRequest(CertificationRequest certificationRequest, bool selected);
}

class FirestoreDatabase implements Database {
  FirestoreDatabase();

  final _service = FirestoreService.instance;

  @override
  Future<void> addResource(Resource resource) =>
      _service.addData(path: APIPath.resources(), data: resource.toMap());

  @override
  Future<void> setResource(Resource resource) => _service.updateData(
      path: APIPath.resource(resource.resourceId), data: resource.toMap());

  @override
  Future<void> deleteResource(Resource resource) =>
      _service.deleteData(path: APIPath.resource(resource.resourceId));

  @override
  Stream<List<Resource>> resourcesStream() {
    return _service.collectionStream(
      path: APIPath.resources(),
      queryBuilder: (query) => query
          .where('status', isEqualTo: 'Disponible')
          .where('trust', isEqualTo: true),
      builder: (data, documentId) => Resource.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.maximumDate.compareTo(rhs.maximumDate),
    );
  }

  // @override
  // Stream<List<Resource>> filteredResourcesStream(FilterResource filter) {
  //   return _service.filteredCollectionStream(
  //     path: APIPath.resources(),
  //     queryBuilder: (query) {
  //       query = query
  //           .where('status', isEqualTo: 'Disponible')
  //           .where('trust', isEqualTo: true);
  //       return query;
  //     },
  //     builder: (data, documentId) {
  //       final searchTextResource =
  //           removeDiacritics((data['searchText'] ?? '').toLowerCase());
  //       final searchListResource = searchTextResource.split(';');
  //       final searchTextFilter =
  //           removeDiacritics(filter.searchText.toLowerCase());
  //       final searchListFilter = searchTextFilter.split(' ');
  //       bool isValid = true;
  //       if (filter.searchText != '') {
  //         searchListFilter.forEach((filterElement) {
  //           if (!searchListResource.any(
  //               (resourceElement) => resourceElement.contains(filterElement))) {
  //             isValid = false;
  //           }
  //         });
  //       }
  //       if (filter.resourceTypes.isNotEmpty &&
  //           !filter.resourceTypes
  //               .contains(getResourceTypeName(data['resourceType'])))
  //         isValid = false;
  //
  //       return isValid ? Resource.fromMap(data, documentId) : null;
  //     },
  //     sort: (lhs, rhs) {
  //       int cmp = 0;
  //       if ((rhs.modality == StringConst.FACE_TO_FACE ||
  //               rhs.modality == StringConst.BLENDED) &&
  //           (lhs.modality != StringConst.FACE_TO_FACE &&
  //               lhs.modality != StringConst.BLENDED)) cmp = 1;
  //       if ((lhs.modality == StringConst.FACE_TO_FACE ||
  //               lhs.modality == StringConst.BLENDED) &&
  //           (rhs.modality != StringConst.FACE_TO_FACE &&
  //               rhs.modality != StringConst.BLENDED)) cmp = -1;
  //
  //       if (cmp != 0) return cmp;
  //
  //       return lhs.maximumDate.compareTo(rhs.maximumDate);
  //     },
  //   );
  // }

  @override
  Stream<List<Resource>> filteredResourcesCategoryStream(FilterResource filter) {
    return _service.filteredCollectionStream(
      path: APIPath.resources(),
      queryBuilder: (query) {
        query = query
            .where('status', isEqualTo: 'Disponible')
            .where('trust', isEqualTo: true);
        return query;
      },
      builder: (data, documentId) {
        final searchTextResource =
        removeDiacritics((data['searchText'] ?? '').toLowerCase());
        final searchListResource = searchTextResource.split(';');
        final searchTextFilter =
        removeDiacritics(filter.searchText.toLowerCase());
        final searchListFilter = searchTextFilter.split(' ');
        bool isValid = true;
        if (filter.searchText != '') {
          searchListFilter.forEach((filterElement) {
            if (!searchListResource.any(
                    (resourceElement) => resourceElement.contains(filterElement))) {
              isValid = false;
            }
          });
        }
        if (filter.resourceCategories.isNotEmpty &&
            !filter.resourceCategories
                .contains(getResourceCategoryName(data['resourceCategory'])))
          isValid = false;

        return isValid ? Resource.fromMap(data, documentId) : null;
      },
      sort: (lhs, rhs) {
        int cmp = 0;
        if ((rhs.modality == StringConst.FACE_TO_FACE ||
            rhs.modality == StringConst.BLENDED) &&
            (lhs.modality != StringConst.FACE_TO_FACE &&
                lhs.modality != StringConst.BLENDED)) cmp = 1;
        if ((lhs.modality == StringConst.FACE_TO_FACE ||
            lhs.modality == StringConst.BLENDED) &&
            (rhs.modality != StringConst.FACE_TO_FACE &&
                rhs.modality != StringConst.BLENDED)) cmp = -1;

        if (cmp != 0) return cmp;

        return lhs.maximumDate.compareTo(rhs.maximumDate);
      },
    );
  }

  @override
  Stream<List<Resource>> myResourcesStream(String userId) =>
      _service.collectionStream(
        path: APIPath.resources(),
        queryBuilder: (query) =>
            query.where('participants', arrayContains: userId),
        builder: (data, documentId) => Resource.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.maximumDate.compareTo(rhs.maximumDate),
      );

  @override
  Stream<List<Resource>> likeResourcesStream(String userId) =>
      _service.collectionStream(
        path: APIPath.resources(),
        queryBuilder: (query) => query.where('likes', arrayContains: userId),
        builder: (data, documentId) => Resource.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.maximumDate.compareTo(rhs.maximumDate),
      );

  @override
  Stream<List<Resource>> recommendedResourcesStream(UserEnreda? user) {
    return _service.filteredCollectionStream(
      path: APIPath.resources(),
      queryBuilder: (query) {
        query = query
            .where('status', isEqualTo: 'Disponible')
            .where('trust', isEqualTo: true);
        return query;
      },
      builder: (data, documentId) {
        var interests = data['interests'];

        if (interests != null && user != null) {
          for (var interest in interests) {
            if (user.interests.contains(interest))
              return Resource.fromMap(data, documentId);
          }
        }

        return null;
      },
      sort: (lhs, rhs) => lhs.maximumDate.compareTo(rhs.maximumDate),
    );
  }

  @override
  Stream<Resource> resourceStream(String resourceId) =>
      _service.documentStream<Resource>(
        path: APIPath.resource(resourceId),
        builder: (data, documentId) => Resource.fromMap(data, documentId),
      );

  @override
  Stream<UserEnreda> enredaUserStream(String userId) =>
      _service.documentStream<UserEnreda>(
        path: APIPath.user(userId),
        builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      );

  @override
  Stream<List<Organization>> organizationsStream() => _service.collectionStream(
        path: APIPath.organizations(),
        queryBuilder: (query) => query.where('trust', isEqualTo: true),
        builder: (data, documentId) => Organization.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  Stream<Organization> organizationStream(String organizationId) =>
      _service.documentStream<Organization>(
        path: APIPath.organization(organizationId),
        builder: (data, documentId) => Organization.fromMap(data, documentId),
      );

  Stream<UserEnreda> mentorStream(String mentorId) =>
      _service.documentStream<UserEnreda>(
        path: APIPath.user(mentorId),
        builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      );

  @override
  Stream<List<Country>> countriesStream() => _service.collectionStream(
        path: APIPath.countries(),
        queryBuilder: (query) => query.where('coutryId', isNotEqualTo: null),
        builder: (data, documentId) => Country.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  Stream<Country> countryStream(String? countryId) =>
      _service.documentStream<Country>(
        path: APIPath.country(countryId),
        builder: (data, documentId) => Country.fromMap(data, documentId),
      );

  @override
  Stream<List<Province>> provincesStream() => _service.collectionStream(
        path: APIPath.provinces(),
        queryBuilder: (query) => query.where('provinceId', isNotEqualTo: null),
        builder: (data, documentId) => Province.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  Stream<Province> provinceStream(String? provinceId) =>
      _service.documentStream<Province>(
        path: APIPath.province(provinceId),
        builder: (data, documentId) => Province.fromMap(data, documentId),
      );

  @override
  Stream<List<City>> citiesStream() => _service.collectionStream(
        path: APIPath.cities(),
        queryBuilder: (query) => query.where('cityId', isNotEqualTo: null),
        builder: (data, documentId) => City.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  Stream<City> cityStream(String? cityId) => _service.documentStream<City>(
        path: APIPath.city(cityId),
        builder: (data, documentId) => City.fromMap(data, documentId),
      );

  Stream<ResourcePicture> resourcePictureStream(String? resourcePictureId) =>
      _service.documentStream<ResourcePicture>(
        path: APIPath.resourcePicture(resourcePictureId),
        builder: (data, documentId) =>
            ResourcePicture.fromMap(data, documentId),
      );

  @override
  Stream<List<UserEnreda>> userStream(String? email) {
    return _service.collectionStream<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) => query.where('email', isEqualTo: email),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.email.compareTo(rhs.email),
    );
  }

  Stream<UserEnreda> userEnredaStreamByUserId(String? userId) {
    return _service.documentStreamByField(
      path: APIPath.users(),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

  @override
  Stream<CertificationRequest> certificationRequestStream(String certificationRequestId) =>
      _service.documentStream<CertificationRequest>(
        path: APIPath.certificationRequest(certificationRequestId),
        builder: (data, documentId) => CertificationRequest.fromMap(data, documentId),
      );

  @override
  Future<void> addUserEnreda(UserEnreda userEnreda) =>
      _service.addData(path: APIPath.tests(), data: userEnreda.toMap());

  @override
  Future<void> setUserEnreda(UserEnreda userEnreda) {
    return _service.updateData(
        path: APIPath.user(userEnreda.userId!), data: userEnreda.toMap());
  }

  @override
  Future<void> deleteUser(UserEnreda userEnreda) {
    return _service.deleteData(path: APIPath.user(userEnreda.userId!));
  }

  @override
  Future<void> updateCertificationRequest(CertificationRequest certificationRequest, bool selected) {
    return _service.updateData(
        path: APIPath.certificationRequest(certificationRequest.certificationRequestId!), data: {
      "certified": selected});
  }

  @override
  Stream<List<Country>> countryFormatedStream() => _service.collectionStream(
        path: APIPath.countries(),
        queryBuilder: (query) => query.where('name', isNotEqualTo: 'Online'),
        builder: (data, documentId) => Country.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  @override
  Stream<List<Province>> provincesCountryStream(String? countryId) {
    if (countryId == null) return Stream<List<Province>>.empty();

    return _service.collectionStream(
      path: APIPath.provinces(),
      builder: (data, documentId) => Province.fromMap(data, documentId),
      queryBuilder: (query) => query.where('countryId', isEqualTo: countryId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );
  }

  @override
  Stream<List<City>> citiesProvinceStream(String? provinceId) =>
      _service.collectionStream(
        path: APIPath.cities(),
        builder: (data, documentId) => City.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.where('provinceId', isEqualTo: provinceId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  @override
  Stream<List<Interest>> interestStream() => _service.collectionStream(
        path: APIPath.interests(),
        queryBuilder: (query) => query.where('name', isNotEqualTo: null),
        builder: (data, documentId) => Interest.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  @override
  Stream<List<SpecificInterest>> specificInterestStream(String? interestId) =>
      _service.collectionStream(
        path: APIPath.specificInterests(),
        queryBuilder: (query) =>
            query.where('interestId', isEqualTo: interestId),
        builder: (data, documentId) =>
            SpecificInterest.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  @override
  Stream<List<Ability>> abilityStream() => _service.collectionStream(
        path: APIPath.abilities(),
        queryBuilder: (query) => query.where('name', isNotEqualTo: null),
        builder: (data, documentId) => Ability.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  @override
  Stream<List<Nature>> natureStream() => _service.collectionStream(
        path: APIPath.natures(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) => Nature.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.label.compareTo(rhs.label),
      );

  @override
  Stream<List<Scope>> scopeStream() => _service.collectionStream(
        path: APIPath.scopes(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) => Scope.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
      );

  @override
  Stream<List<SizeOrg>> sizeStream() => _service.collectionStream(
        path: APIPath.sizes(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) => SizeOrg.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
      );

  @override
  Stream<List<Dedication>> dedicationStream() => _service.collectionStream(
        path: APIPath.dedications(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) => Dedication.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.value.compareTo(rhs.value),
      );

  @override
  Stream<List<TimeSearching>> timeSearchingStream() =>
      _service.collectionStream(
        path: APIPath.timeSearching(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) => TimeSearching.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.value.compareTo(rhs.value),
      );

  @override
  Stream<List<TimeSpentWeekly>> timeSpentWeeklyStream() =>
      _service.collectionStream(
        path: APIPath.timeSpentWeekly(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) =>
            TimeSpentWeekly.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.value.compareTo(rhs.value),
      );

  @override
  Stream<List<Education>> educationStream() => _service.collectionStream(
        path: APIPath.education(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) => Education.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
      );

  @override
  Stream<List<Gender>> genderStream() => _service.collectionStream(
        path: APIPath.genders(),
        queryBuilder: (query) => query.where('name', isNotEqualTo: null),
        builder: (data, documentId) => Gender.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  Future<void> uploadUserAvatar(String userId, Uint8List data) async {
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child('users/$userId/profilePic');
    UploadTask uploadTask = firebaseStorageRef.putData(data);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) => {
            //print("Done: $value")
            _service.updateData(path: APIPath.photoUser(userId), data: {
              "profilePic": {
                'src': '$value',
                'title': 'photo.jpg',
              }
            })
          },
        );
  }

  @override
  Stream<List<Certificate>> myCertificatesStream(String userId) =>
      _service.collectionStream(
        path: APIPath.certificates(),
        queryBuilder: (query) => query.where('user', isEqualTo: userId),
        builder: (data, documentId) => Certificate.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.date.compareTo(rhs.date),
      );

  @override
  Stream<List<ChatQuestion>> chatQuestionsStream(String userId) =>
      _service.collectionStream(
        path: APIPath.chatQuestions(),
        queryBuilder: (query) => query.where('userId', isEqualTo: userId),
        builder: (data, documentId) => ChatQuestion.fromMap(data, documentId),
        sort: (lhs, rhs) => rhs.date.compareTo(lhs.date),
      );

  @override
  Future<void> addChatQuestion(ChatQuestion chatQuestion) => _service.addData(
      path: APIPath.chatQuestions(), data: chatQuestion.toMap());

  @override
  Future<void> updateChatQuestion(ChatQuestion chatQuestion) =>
      _service.updateData(
          path: APIPath.chatQuestion(chatQuestion.id!),
          data: chatQuestion.toMap());

  @override
  Stream<List<Question>> questionsStream() => _service.collectionStream(
        path: APIPath.questions(),
        builder: (data, documentId) => Question.fromMap(data, documentId),
        queryBuilder: (query) => query,
        sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
      );

  @override
  Stream<Question> questionStream(String id) =>
      _service.documentStream<Question>(
        path: APIPath.question(id),
        builder: (data, documentId) => Question.fromMap(data, documentId),
      );

  @override
  Stream<List<Choice>> choicesStream(
          String path, String? typeId, String? subtypeId) =>
      _service.collectionStream(
        path: path,
        // TODO: Think if this is the better way of loading the choices which depends on the experience type and subtype
        queryBuilder: (query) {
          if (typeId != null) query = query.where('typeId', isEqualTo: typeId);
          if (subtypeId != null)
            query = query.where('subtypeId', isEqualTo: subtypeId);

          return query;
        },
        builder: (data, documentId) => Choice.fromMap(data, documentId),
        sort: (lhs, rhs) => rhs.name.compareTo(lhs.name),
      );

  @override
  Future<void> addContact(Contact contact) =>
      _service.addData(path: APIPath.contacts(), data: contact.toMap());

  @override
  Future<void> addUnemployedUser(UnemployedUser unemployedUser) =>
      _service.addData(path: APIPath.users(), data: unemployedUser.toMap());

  @override
  Future<void> addMentorUser(MentorUser mentorUser) =>
      _service.addData(path: APIPath.users(), data: mentorUser.toMap());

  @override
  Future<void> addOrganization(Organization organization) => _service.addData(
      path: APIPath.organizations(), data: organization.toMap());

  @override
  Future<void> addOrganizationUser(OrganizationUser organizationUser) =>
      _service.addData(path: APIPath.users(), data: organizationUser.toMap());

  @override
  Future<void> addCertificationRequest(CertificationRequest certificationRequest) =>
      _service.addData(path: APIPath.certificationsRequests(), data: certificationRequest.toMap());

  @override
  Stream<List<UserEnreda>> checkIfUserEmailRegistered(String email) {
    return _service.collectionStream(
      path: APIPath.users(),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      queryBuilder: (query) => query.where('email', isEqualTo: email),
      sort: (lhs, rhs) => lhs.email.compareTo(rhs.email),
    );
  }

  @override
  Stream<List<Experience>> myExperiencesStream(String userId) =>
      _service.collectionStream(
        path: APIPath.experiences(),
        queryBuilder: (query) =>
            query.where('userId', isEqualTo: userId),
        builder: (data, documentId) => Experience.fromMap(data, documentId),
        sort: (lhs, rhs) => rhs.startDate.compareTo(lhs.startDate),
      );

  @override
  Future<void> addExperience(Experience experience) =>
      _service.addData(path: APIPath.experiences(), data: experience.toMap());

  @override
  Future<void> updateExperience(Experience experience) =>
      _service.updateData(path: '${APIPath.experiences()}/${experience.id}', data: experience.toMap());

  @override
  Future<void> deleteExperience(Experience experience) =>
      _service.deleteData(path: APIPath.experience(experience.id!));


  @override
  Stream<List<Competency>> competenciesStream() => _service.collectionStream(
        path: APIPath.competencies(),
        builder: (data, documentId) => Competency.fromMap(data, documentId),
        queryBuilder: (query) => query,
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );
/* TODO: Conseguir un stream que devuelvas Mis Competencias, así funciona pero a partir de 10 da error porque Firebase tiene límite con el whereIn en List de 10 elementos
  @override
  Stream<List<Competency>> myCompetenciesStream(UserEnreda? user) =>
      _service.collectionStream(
        path: APIPath.competencies(),
        builder: (data, documentId) => Competency.fromMap(data, documentId),
        queryBuilder: (query) {
          List<String> competenciesIds = user?.competencies.keys.toList()??[];
          if (competenciesIds.isNotEmpty) {
            return query.where('id', whereIn: user?.competencies.keys.toList());
          } else {
            return query.where('id', isEqualTo: '-1');
          }
        },
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );
*/
  @override
  Stream<Competency> competencyStream(String id) =>
      _service.documentStream<Competency>(
        path: APIPath.competency(id),
        builder: (data, documentId) => Competency.fromMap(data, documentId),
      );

  @override
  Stream<Activity> activtyStream(String id) =>
      _service.documentStream<Activity>(
        path: APIPath.activity(id),
        builder: (data, documentId) => Activity.fromMap(data, documentId),
      );
}
