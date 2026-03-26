import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/company.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';

class ResourceMetadata {
  final Map<String, String> countryNames;
  final Map<String, String> provinceNames;
  final Map<String, String> cityNames;
  final Map<String, String> organizerNames;
  final Map<String, String?> organizerImages;

  ResourceMetadata({
    this.countryNames = const {},
    this.provinceNames = const {},
    this.cityNames = const {},
    this.organizerNames = const {},
    this.organizerImages = const {},
  });

  factory ResourceMetadata.fromLists({
    List<Country>? countries,
    List<Province>? provinces,
    List<City>? cities,
    List<dynamic>? organizers,
  }) {
    final countryNames = <String, String>{};
    countries?.forEach((c) {
      if (c.countryId != null) countryNames[c.countryId!] = c.name;
    });

    final provinceNames = <String, String>{};
    provinces?.forEach((p) {
      if (p.provinceId != null) provinceNames[p.provinceId!] = p.name;
    });

    final cityNames = <String, String>{};
    cities?.forEach((c) {
      if (c.cityId != null) cityNames[c.cityId!] = c.name;
    });

    final organizerNames = <String, String>{};
    final organizerImages = <String, String?>{};

    organizers?.forEach((o) {
      String id = '';
      String name = '';
      String? image;

      if (o is Organization) {
        id = o.organizationId ?? '';
        name = o.name;
        image = o.photo;
      } else if (o is SocialEntity) {
        id = o.socialEntityId ?? '';
        name = o.name;
        image = o.photo;
      } else if (o is Company) {
        id = o.companyId ?? '';
        name = o.name;
        image = o.photo;
      } else if (o is UserEnreda) {
        id = o.userId ?? '';
        name = '${o.firstName} ${o.lastName}';
        image = o.photo;
      }

      if (id.isNotEmpty) {
        organizerNames[id] = name;
        organizerImages[id] = image;
      }
    });

    return ResourceMetadata(
      countryNames: countryNames,
      provinceNames: provinceNames,
      cityNames: cityNames,
      organizerNames: organizerNames,
      organizerImages: organizerImages,
    );
  }
}
