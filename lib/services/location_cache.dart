import 'package:enreda_app/app/home/models/ability.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/company.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/competencyCategory.dart';
import 'package:enreda_app/app/home/models/competencySubCategory.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/dedication.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/gamificationFlags.dart';
import 'package:enreda_app/app/home/models/gender.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/keepLearningOptions.dart';
import 'package:enreda_app/app/home/models/nature.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/personalDocumentType.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/question.dart';
import 'package:enreda_app/app/home/models/resourceCategory.dart';
import 'package:enreda_app/app/home/models/scope.dart';
import 'package:enreda_app/app/home/models/size.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/app/home/models/timeSearching.dart';
import 'package:enreda_app/app/home/models/timeSpentWeekly.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/services/database.dart';

/// Singleton cache for static/rarely-changing Firestore collections.
/// Fetches each collection once per session and reuses from memory.
class LocationCache {
  LocationCache._();
  static final LocationCache instance = LocationCache._();

  // Location Data
  List<Country>? _countries;
  List<Province>? _provinces;
  List<City>? _allCities;
  Map<String, List<City>> _citiesByProvince = {};

  Future<void>? _warmUpFuture;
  Future<void>? _lightWarmUpFuture;

  // Organizations/Organizers
  List<dynamic>? _organizers;

  // Taxonomy / Metadata
  List<Competency>? _competencies;
  List<CompetencyCategory>? _competencyCategories;
  List<ResourceCategory>? _resourceCategories;
  List<GamificationFlag>? _gamificationFlags;
  List<PersonalDocumentType>? _personalDocumentTypes;
  List<TrainingPill>? _trainingPills;

  // Metadata for forms
  List<Ability>? _abilities;
  List<Dedication>? _dedications;
  List<Education>? _educations;
  List<Gender>? _genders;
  List<KeepLearningOption>? _keepLearningOptions;
  List<Nature>? _natures;
  List<Scope>? _scopes;
  List<SizeOrg>? _sizeOrgs;
  List<String>? _nations;
  List<TimeSearching>? _timeSearchings;
  List<TimeSpentWeekly>? _timeSpentWeeklies;
  List<SocialEntity>? _socialEntities;
  List<Question>? _questions;

  // User-level data (cached on first access)
  List<Interest>? _interests;
  List<SpecificInterest>? _specificInterests;

  bool get hasCountries => _countries != null;
  bool get hasProvinces => _provinces != null;
  bool get hasCities => _allCities != null;
  bool get hasOrganizers => _organizers != null;
  bool get hasCompetencies => _competencies != null;

  List<Country> get countries => _countries ?? [];
  List<Province> get provinces => _provinces ?? [];
  List<City> get allCities => _allCities ?? [];
  List<dynamic> get organizers => _organizers ?? [];
  List<Competency> get competencies => _competencies ?? [];
  List<CompetencyCategory> get competencyCategories => _competencyCategories ?? [];
  List<ResourceCategory> get resourceCategories => _resourceCategories ?? [];
  List<GamificationFlag> get gamificationFlags => _gamificationFlags ?? [];
  List<PersonalDocumentType> get personalDocumentTypes => _personalDocumentTypes ?? [];
  List<TrainingPill> get trainingPills => _trainingPills ?? [];
  List<Interest> get interests => _interests ?? [];
  List<SpecificInterest> get specificInterests => _specificInterests ?? [];
  List<Ability> get abilities => _abilities ?? [];
  List<Dedication> get dedications => _dedications ?? [];
  List<Education> get educations => _educations ?? [];
  List<Gender> get genders => _genders ?? [];
  List<KeepLearningOption> get keepLearningOptions => _keepLearningOptions ?? [];
  List<Nature> get natures => _natures ?? [];
  List<Scope> get scopes => _scopes ?? [];
  List<SizeOrg> get sizeOrgs => _sizeOrgs ?? [];
  List<String> get nations => _nations ?? [];
  List<TimeSearching> get timeSearchings => _timeSearchings ?? [];
  List<TimeSpentWeekly> get timeSpentWeeklies => _timeSpentWeeklies ?? [];
  List<SocialEntity> get socialEntities => _socialEntities ?? [];
  List<Question> get questions => _questions ?? [];

  void setInterests(List<Interest> v) => _interests = v;
  void setSpecificInterests(List<SpecificInterest> v) => _specificInterests = v;

  TrainingPill? trainingPillById(String pillId) {
    try {
      return _trainingPills?.firstWhere((p) => p.id == pillId);
    } catch (_) {
      return null;
    }
  }

  List<Province> provincesForCountry(String countryId) =>
      (_provinces ?? []).where((p) => p.countryId == countryId).toList();

  List<City> citiesForProvince(String provinceId) =>
      _citiesByProvince[provinceId] ?? [];

  /// Loads ALL static metadata in parallel, preventing redundant fetch.
  Future<void> warmUpAll(Database database) async {
    if (_warmUpFuture != null) {
      return _warmUpFuture;
    }
    _warmUpFuture = _doWarmUpAll(database);
    try {
      await _warmUpFuture;
    } finally {
      // Keep completed future if you want subsequent requests to instantly return,
      // but typically we don't clear it unless clear() is called, so it acts as a lock.
    }
  }

  Future<void> _doWarmUpAll(Database database) async {
    final futures = <Future>[];

    if (_countries == null) {
      futures.add(database.countryFormatedStream().first.then((v) => _countries = v));
    }
    if (_provinces == null) {
      futures.add(database.provincesStream().first.then((v) => _provinces = v));
    }
    if (_organizers == null) {
      futures.add(Future.wait([
        database.organizationsStream().first,
        database.socialEntitiesStream().first,
        database.companiesStream().first,
      ]).then((results) {
        final orgs = results[0] as List<Organization>;
        final se = results[1] as List<SocialEntity>;
        final comp = results[2] as List<Company>;
        _socialEntities = se;
        _organizers = [...orgs, ...se, ...comp];
      }));
    }
    if (_competencies == null) {
      futures.add(database.competenciesStream().first.then((v) => _competencies = v));
    }
    if (_competencyCategories == null) {
      futures.add(database.competenciesCategoriesStream().first.then((v) => _competencyCategories = v));
    }
    if (_resourceCategories == null) {
      futures.add(database.getCategoriesResources().first.then((v) => _resourceCategories = v));
    }
    if (_gamificationFlags == null) {
      futures.add(database.gamificationFlagsStream().first.then((v) => _gamificationFlags = v));
    }
    if (_personalDocumentTypes == null) {
      futures.add(database.personalDocumentTypeStream().first.then((v) => _personalDocumentTypes = v));
    }
    if (_trainingPills == null) {
      futures.add(database.trainingPillStream().first.then((v) => _trainingPills = v));
    }

    // Form metadata warm-up
    if (_abilities == null) futures.add(database.abilityStream().first.then((v) => _abilities = v));
    if (_dedications == null) futures.add(database.dedicationStream().first.then((v) => _dedications = v));
    if (_educations == null) futures.add(database.educationStream().first.then((v) => _educations = v));
    if (_genders == null) futures.add(database.genderStream().first.then((v) => _genders = v));
    if (_keepLearningOptions == null) futures.add(database.keepLearningOptionsStream().first.then((v) => _keepLearningOptions = v));
    if (_natures == null) futures.add(database.natureStream().first.then((v) => _natures = v));
    if (_scopes == null) futures.add(database.scopeStream().first.then((v) => _scopes = v));
    if (_sizeOrgs == null) futures.add(database.sizeStream().first.then((v) => _sizeOrgs = v));
    if (_nations == null) futures.add(database.nationsSpanishStream().first.then((v) => _nations = v));
    if (_timeSearchings == null) futures.add(database.timeSearchingStream().first.then((v) => _timeSearchings = v));
    if (_timeSpentWeeklies == null) futures.add(database.timeSpentWeeklyStream().first.then((v) => _timeSpentWeeklies = v));
    if (_questions == null) futures.add(database.questionsStream().first.then((v) => _questions = v));
    if (_interests == null) futures.add(database.interestStream().first.then((v) => _interests = v));
    if (_specificInterests == null) futures.add(database.specificInterestsStream().first.then((v) => _specificInterests = v));

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Lightweight warm-up for forms.
  Future<void> warmUp(Database database) async {
    if (_lightWarmUpFuture != null) {
      return _lightWarmUpFuture;
    }
    _lightWarmUpFuture = _doWarmUp(database);
    await _lightWarmUpFuture;
  }

  Future<void> _doWarmUp(Database database) async {
    final futures = <Future>[];
    if (_countries == null) {
      futures.add(database.countryFormatedStream().first.then((v) => _countries = v));
    }
    if (_provinces == null) {
      futures.add(database.provincesStream().first.then((v) => _provinces = v));
    }
    
    // Form metadata warm-up
    if (_abilities == null) futures.add(database.abilityStream().first.then((v) => _abilities = v));
    if (_dedications == null) futures.add(database.dedicationStream().first.then((v) => _dedications = v));
    if (_educations == null) futures.add(database.educationStream().first.then((v) => _educations = v));
    if (_genders == null) futures.add(database.genderStream().first.then((v) => _genders = v));
    if (_keepLearningOptions == null) futures.add(database.keepLearningOptionsStream().first.then((v) => _keepLearningOptions = v));
    if (_natures == null) futures.add(database.natureStream().first.then((v) => _natures = v));
    if (_scopes == null) futures.add(database.scopeStream().first.then((v) => _scopes = v));
    if (_sizeOrgs == null) futures.add(database.sizeStream().first.then((v) => _sizeOrgs = v));
    if (_nations == null) futures.add(database.nationsSpanishStream().first.then((v) => _nations = v));
    if (_timeSearchings == null) futures.add(database.timeSearchingStream().first.then((v) => _timeSearchings = v));
    if (_timeSpentWeeklies == null) futures.add(database.timeSpentWeeklyStream().first.then((v) => _timeSpentWeeklies = v));
    if (_questions == null) futures.add(database.questionsStream().first.then((v) => _questions = v));
    if (_socialEntities == null) futures.add(database.socialEntitiesStream().first.then((v) => _socialEntities = v));
    if (_interests == null) futures.add(database.interestStream().first.then((v) => _interests = v));
    if (_specificInterests == null) futures.add(database.specificInterestsStream().first.then((v) => _specificInterests = v));

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Returns cached cities for a province.
  Future<List<City>> getCitiesForProvince(Database database, String provinceId) async {
    if (_allCities != null) {
      _citiesByProvince.putIfAbsent(
          provinceId, () => _allCities!.where((c) => c.provinceId == provinceId).toList());
      return _citiesByProvince[provinceId]!;
    }
    if (!_citiesByProvince.containsKey(provinceId)) {
      final cities = await database.citiesProvinceStream(provinceId).first;
      _citiesByProvince[provinceId] = cities;
    }
    return _citiesByProvince[provinceId]!;
  }

  void clear() {
    _countries = null;
    _provinces = null;
    _allCities = null;
    _organizers = null;
    _competencies = null;
    _competencyCategories = null;
    _resourceCategories = null;
    _gamificationFlags = null;
    _personalDocumentTypes = null;
    _trainingPills = null;
    _interests = null;
    _specificInterests = null;
    _abilities = null;
    _dedications = null;
    _educations = null;
    _genders = null;
    _keepLearningOptions = null;
    _natures = null;
    _scopes = null;
    _sizeOrgs = null;
    _nations = null;
    _timeSearchings = null;
    _timeSpentWeeklies = null;
    _socialEntities = null;
    _questions = null;
    _citiesByProvince = {};
    _warmUpFuture = null;
    _lightWarmUpFuture = null;
  }
}

