import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/company.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/competencyCategory.dart';
import 'package:enreda_app/app/home/models/competencySubCategory.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/gamificationFlags.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/personalDocumentType.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resourceCategory.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
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

  // Organizations/Organizers
  List<dynamic>? _organizers;

  // Taxonomy / Metadata
  List<Competency>? _competencies;
  List<CompetencyCategory>? _competencyCategories;
  List<ResourceCategory>? _resourceCategories;
  List<GamificationFlag>? _gamificationFlags;
  List<PersonalDocumentType>? _personalDocumentTypes;

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

  List<Province> provincesForCountry(String countryId) =>
      (_provinces ?? []).where((p) => p.countryId == countryId).toList();

  List<City> citiesForProvince(String provinceId) =>
      _citiesByProvince[provinceId] ?? [];

  /// Loads ALL static metadata in parallel.
  Future<void> warmUpAll(Database database) async {
    final futures = <Future>[];

    if (_countries == null) {
      futures.add(database.countryFormatedStream().first.then((v) => _countries = v));
    }
    if (_provinces == null) {
      futures.add(database.provincesStream().first.then((v) => _provinces = v));
    }
    if (_allCities == null) {
      futures.add(database.citiesStream().first.then((v) {
        _allCities = v;
        for (final city in v) {
          if (city.provinceId != null) {
            _citiesByProvince.putIfAbsent(city.provinceId!, () => []).add(city);
          }
        }
      }));
    }
    if (_organizers == null) {
      futures.add(Future.wait([
        database.organizationsStream().first,
        database.socialEntitiesStream().first,
        database.companiesStream().first,
      ]).then((results) {
        _organizers = [
          ...results[0] as List<Organization>,
          ...results[1] as List<SocialEntity>,
          ...results[2] as List<Company>,
        ];
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

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Lightweight warm-up for forms.
  Future<void> warmUp(Database database) async {
    final futures = <Future>[];
    if (_countries == null) {
      futures.add(database.countryFormatedStream().first.then((v) => _countries = v));
    }
    if (_provinces == null) {
      futures.add(database.provincesStream().first.then((v) => _provinces = v));
    }
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
    _citiesByProvince = {};
  }
}

