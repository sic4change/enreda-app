import 'package:enreda_app/app/home/models/scope.dart';
import 'package:enreda_app/app/home/models/size.dart';
import 'addressUser.dart';

class SocialEntity {
  SocialEntity({
    this.socialEntityId,
    required this.name,
    this.email,
    this.contactPhone,
    this.contactMobilePhone,
    this.contactEmail,
    this.entityPhone,
    this.entityMobilePhone,
    this.address,
    this.country,
    this.province,
    this.city,
    this.postalCode,
    this.website,
    this.scope,
    this.size,
    this.photo,
    this.types,
  });

  final String? socialEntityId;
  final String name;
  final String? email;
  final String? contactPhone;
  final String? contactMobilePhone;
  final String? contactEmail;
  final String? entityPhone;
  final String? entityMobilePhone;
  final String? country;
  final String? province;
  final String? city;
  final Address? address;
  final String? postalCode;
  final String? website;
  final Scope? scope;
  final SizeOrg? size;
  final String? photo;
  final List<String>? types;

  factory SocialEntity.fromMap(Map<String, dynamic> data, String documentId) {

    final Address address = Address(
        country: data['address']['country'],
        province: data['address']['province'],
        city: data['address']['city'],
        postalCode: data['address']['postalCode']
    );

    final String name = data['name'];
    final String? socialEntityId = data['socialEntityId'];
    final String email = data['email']??"";

    final String contactPhone = data['contactPhone']??"";
    final String contactMobilePhone = data['contactMobilePhone']??"";
    final String contactEmail = data['contactEmail']??"";
    final String entityPhone = data['entityPhone']??"";
    final String entityMobilePhone = data['entityMobilePhone']??"";

    String photo;
    try {
      photo = data['logoPic']['src'];
    } catch (e) {
      photo = '';
    }

    final String website = data['website']??"";

    final List<String> types = [];
    if (data['types'] != null) {
      data['types'].forEach((type) {types.add(type.toString());});
    }

    return SocialEntity(
        socialEntityId: socialEntityId,
        name: name,
        email: email,
        contactPhone: contactPhone,
        contactMobilePhone: contactMobilePhone,
        contactEmail: contactEmail,
        entityPhone: entityPhone,
        entityMobilePhone: entityMobilePhone,
        address: address,
        website: website,
        photo: photo,
        types: types,
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SocialEntity &&
            other.socialEntityId == socialEntityId);
  }

  Map<String, dynamic> toMap() {
    return {
      'socialEntityId': socialEntityId,
      'name': name,
      'email': email,
      'contactPhone': contactPhone,
      'contactMobilePhone': contactMobilePhone,
      'contactEmail': contactEmail,
      'entityPhone': entityPhone,
      'entityMobilePhone': entityMobilePhone,
      'address': address?.toMap(),
      'website': website,
      'types': types,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => socialEntityId.hashCode;

}