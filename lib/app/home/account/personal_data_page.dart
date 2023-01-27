import 'package:chips_choice/chips_choice.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:enreda_app/app/home/models/addressUser.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_chip.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/custom_raised_button.dart';
import '../../../common_widgets/flex_row_column.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({Key? key}) : super(key: key);

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  final _formKey = GlobalKey<FormState>();
  String _userId = '';
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _gender = '';
  DateTime? _birthday;
  String _country = 'España';
  String _province = 'Las Palmas';
  String _city = '';
  String _postalCode = '';
  String _role = '';
  String _unemployedType = '';
  List<String> _abilities = [];
  List<Country> _countries = [Country(name: 'España')];
  List<Province> _provinces = [Province(name: 'Las Palmas', countryId: '')];
  List<City> _cities = [
    City(name: 'Las Palmas de Gran Canaria', countryId: '', provinceId: '')
  ];
  String _countrySelected = '';
  String _provinceSelected = '';
  Set<Interest> _interests = Set.from([]);
  List<String> _interestsSelected = [];
  List<String> _specificInterest = [];
  String codeDialog = '';
  String valueText = '';
  String _phoneCode = '+34';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<User?>(
        stream: Provider.of<AuthBase>(context).authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.hasData) {
            return StreamBuilder<List<Interest>>(
                stream: database.interestStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    snapshot.data!.forEach((interest) {
                      if (!_interests.any((element) =>
                      element.interestId == interest.interestId)) {
                        _interests.add(interest);
                      }
                    });
                  }
                  return StreamBuilder<List<UserEnreda>>(
                    stream: database.userStream(auth.currentUser!.email),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      if (snapshot.hasData) {
                        final userEnreda = snapshot.data![0];
                        _userId = userEnreda.userId ?? '';
                        _email = userEnreda.email;
                        _firstName = userEnreda.firstName ?? '';
                        _lastName = userEnreda.lastName ?? '';
                        _role = userEnreda.role ?? '';
                        _abilities = userEnreda.abilities ?? [];
                        _unemployedType = userEnreda.unemployedType ?? '';
                        if (_phone.isEmpty) _phone = userEnreda.phone ?? '';
                        _phoneCode = '${userEnreda.phone?[0]}${userEnreda.phone?[1]}${userEnreda.phone?[2]}';
                        _gender = userEnreda.gender ?? '';
                        _birthday =
                        _birthday == null ? userEnreda.birthday : _birthday;
                        _postalCode = userEnreda.address?.postalCode ?? '';
                        _specificInterest = userEnreda.specificInterests;
                        if (_interestsSelected.isEmpty) {
                          _interestsSelected = userEnreda.interests;
                          List<String> interestSelectedName = [];
                          _interests
                              .where((interest) =>
                              _interestsSelected.any(
                                      (interestId) =>
                                  interestId == interest.interestId))
                              .forEach((interest) {
                            interestSelectedName.add(interest.name);
                          });
                          _interestsSelected.clear();
                          _interestsSelected.addAll(interestSelectedName);
                        }
                        return StreamBuilder<List<Country>>(
                            stream: database.countryFormatedStream(),
                            builder: (context, snapshot) {
                              _countries =
                              snapshot.hasData ? snapshot.data! : [];
                              if (_countrySelected == '') {
                                _countrySelected =
                                    userEnreda.address?.country ?? '';
                              }

                              _country = _countries
                                  .firstWhere(
                                      (country) =>
                                  country.countryId == _countrySelected,
                                  orElse: () => Country(name: ''))
                                  .name;
                              return StreamBuilder<List<Province>>(
                                  stream: database
                                      .provincesCountryStream(_countrySelected),
                                  builder: (context, snapshot) {
                                    _provinces = snapshot.hasData
                                        ? snapshot.data!
                                        .where((province) =>
                                    province.countryId ==
                                        _countrySelected)
                                        .toList()
                                        : [];
                                    if (_provinceSelected == '') {
                                      _provinceSelected =
                                          userEnreda.address?.province ?? '';
                                    }
                                    try {
                                      _province = _provinces.isNotEmpty
                                          ? _provinces
                                          .firstWhere((province) =>
                                      province.provinceId ==
                                          _provinceSelected)
                                          .name
                                          : '';
                                    } catch (e) {
                                      _province = _provinces[0].name;
                                      _provinceSelected =
                                          _provinces[0].provinceId ?? '';
                                    }
                                    return StreamBuilder<List<City>>(
                                        stream: database.citiesProvinceStream(
                                            _provinceSelected),
                                        builder: (context, snapshot) {
                                          _cities = snapshot.hasData
                                              ? snapshot.data!
                                              .where((city) =>
                                          city.provinceId ==
                                              _provinceSelected)
                                              .toList()
                                              : [];
                                          try {
                                            _city = _cities.isNotEmpty
                                                ? _cities
                                                .firstWhere((city) =>
                                            city.cityId ==
                                                userEnreda.city)
                                                .name
                                                : '';
                                          } catch (e) {
                                            _city = _cities[0].name;
                                          }
                                          return Responsive.isDesktop(context)
                                              ? Column(
                                            children: [
                                              Expanded(
                                                child:
                                                SingleChildScrollView(
                                                  padding:
                                                  EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      _buildMainDataContainer(
                                                          context,
                                                          userEnreda),
                                                      SpaceH40(),
                                                      _buildInterestsContainer(
                                                          context),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SpaceH36(),
                                              _buildSaveDataButton(
                                                  context, userEnreda),
                                            ],
                                          )
                                              : SingleChildScrollView(
                                            child: Container(
                                              margin: EdgeInsets.all(
                                                  Constants.mainPadding),
                                              child: Column(
                                                children: [
                                                  _buildMainDataContainer(
                                                      context,
                                                      userEnreda),
                                                  SpaceH40(),
                                                  _buildInterestsContainer(
                                                      context),
                                                  SpaceH36(),
                                                  _buildSaveDataButton(
                                                      context,
                                                      userEnreda),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  });
                            });
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildSaveDataButton(BuildContext context, UserEnreda userEnreda) {
    return CustomButton(
      text: 'Actualizar mis datos',
      color: Constants.turquoise,
      onPressed: () => _submit(userEnreda),
    );
  }

  Widget _buildMainDataContainer(BuildContext context, UserEnreda userEnreda) {
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Container(
      padding: EdgeInsets.all(Constants.mainPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.lightGray, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Text(
              StringConst.PERSONAL_DATA.toUpperCase(),
              style: textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Constants.penBlue,
                  fontSize: 16.0),
            ),
          ),
          _buildForm(context, userEnreda),
        ],
      ),
    );
  }

  Widget _buildInterestsContainer(BuildContext context) {
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Container(
      padding: EdgeInsets.all(Constants.mainPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.lightGray, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intereses',
            style: textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.bold,
                color: Constants.penBlue,
                fontSize: 16.0),
          ),
          SpaceH20(),
          _interests.isNotEmpty ?
          Container(
            alignment: Alignment.centerLeft,
            child: ChipsChoice<String>.multiple(
              padding: EdgeInsets.all(0.0),
              value: _interestsSelected,
              onChanged: (val) {
                if (val.isEmpty) {
                  showAlertDialog(
                    context,
                    title: 'Intereses',
                    content: 'Debes seleccionar al menos un interés',
                    defaultActionText: 'Ok',
                  );
                } else {
                  setState(() => _interestsSelected = val);
                }
              },
              choiceItems: C2Choice.listFrom<String, String>(
                source: _interests.map((e) => e.name).toList(),
                value: (i, v) => v,
                label: (i, v) => v,
                tooltip: (i, v) => v,
              ),
              choiceBuilder: (item, i) =>
                  CustomChip(
                    label: item.label,
                    selected: item.selected,
                    onSelect: item.select!,
                  ),
              wrapped: true,
              runSpacing: 8,
            ),
          ) : Container(),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserEnreda userEnreda) {
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomFlexRowColumn(
          childLeft: _buildFormField(
            context: context,
            title: 'Nombre',
            child: TextFormField(
              initialValue: _firstName,
              style: textTheme.bodyText1
                  ?.copyWith(fontSize: fontSize, color: Constants.chatDarkGray),
              decoration: InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.name,
              onSaved: (value) => _firstName = value ?? _firstName,
              validator: (value) =>
              value == null || value.isEmpty
                  ? 'El nombre no puede estar vacío'
                  : null,
            ),
          ),
          childRight: _buildFormField(
            context: context,
            title: 'Apellidos',
            child: TextFormField(
              initialValue: _lastName,
              style: textTheme.bodyText1
                  ?.copyWith(fontSize: fontSize, color: Constants.chatDarkGray),
              decoration: InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.name,
              onSaved: (value) => _lastName = value ?? _lastName,
              validator: (value) =>
              value == null || value.isEmpty
                  ? 'El apellido no puede estar vacío'
                  : null,
            ),
          ),
        ),
        CustomFlexRowColumn(
          childLeft: _buildFormField(
            context: context,
            title: 'Género',
            child: DropdownButtonFormField<String>(
              value: _gender,
              iconEnabledColor: Constants.turquoise,
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: textTheme.bodyText1
                  ?.copyWith(fontSize: fontSize, color: Constants.chatDarkGray),
              items:
              ['Mujer', 'Hombre', 'Otro', 'Prefiero no decirlo'].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => _gender = value ?? _gender,
              onSaved: (value) => _gender = value ?? _gender,
              validator: (value) =>
              value == null || value.isEmpty
                  ? 'El género no puede estar vacío'
                  : null,
            ),
          ),
          childRight: _countries.isNotEmpty
              ? _buildFormField(
            context: context,
            title: 'País',
            child: DropdownButtonFormField<String>(
              value: _country,
              iconEnabledColor: Constants.turquoise,
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: textTheme.bodyText1
                  ?.copyWith(fontSize: fontSize, color: Constants.chatDarkGray),
              items: _countries.map((value) {
                return DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.name),
                );
              }).toList(),
              onChanged: (value) {
                _country = value ?? _country;
                setState(() {
                  if (_countrySelected !=
                      _countries
                          .firstWhere((country) => country.name == _country)
                          .countryId) {
                    _countrySelected = _countries
                        .firstWhere(
                            (country) => country.name == _country)
                        .countryId ??
                        '--';
                    _provinceSelected = 'empty';
                  }
                });
              },
              onSaved: (value) => _country = value ?? _country,
              validator: (value) =>
              value == null || value.isEmpty
                  ? 'El país no puede estar vacío'
                  : null,
            ),
          )
              : Container(),
        ),
        CustomFlexRowColumn(
          childLeft: _buildFormField(
            context: context,
            title: 'Provincia',
            child: DropdownButtonFormField<String>(
              value: _province,
              iconEnabledColor: Constants.turquoise,
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: textTheme.bodyText1
                  ?.copyWith(fontSize: fontSize, color: Constants.chatDarkGray),
              items: _provinces.map((value) {
                return DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.name),
                );
              }).toList(),
              onChanged: (value) {
                _province = value ?? _province;
                setState(() {
                  if (_provinceSelected !=
                      _provinces
                          .firstWhere((province) => province.name == _province)
                          .provinceId) {
                    _provinceSelected = _provinces
                        .firstWhere((province) => province.name == _province)
                        .provinceId ??
                        '--';
                  }
                });
              },
              onSaved: (value) => _province = value ?? _province,
              validator: (value) =>
              value == null || value.isEmpty
                  ? 'La provincia no puede estar vacía'
                  : null,
            ),
          ),
          childRight: _buildFormField(
            context: context,
            title: 'Municipio',
            child: DropdownButtonFormField<String>(
              value: _city,
              iconEnabledColor: Constants.turquoise,
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: textTheme.bodyText1
                  ?.copyWith(fontSize: fontSize, color: Constants.chatDarkGray),
              items: _cities.map((value) {
                return DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.name),
                );
              }).toList(),
              onChanged: (value) => _city = value ?? _city,
              onSaved: (value) => _city = value ?? _city,
              validator: (value) =>
              value == null || value.isEmpty
                  ? 'El municipio no puede estar vacío'
                  : null,
            ),
          ),
        ),
        CustomFlexRowColumn(
          childLeft: _buildFormField(
            context: context,
            title: 'Código postal',
            child: TextFormField(
              initialValue: _postalCode,
              style: textTheme.bodyText1
                  ?.copyWith(fontSize: fontSize, color: Constants.chatDarkGray),
              decoration: InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onSaved: (value) => _postalCode = value ?? _postalCode,
            ),
          ),
          childRight: _buildFormField(
            context: context,
            prefix: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Constants.chatDarkGray,
                  size: 18.0,
                ),
                SpaceW8(),
              ],
            ),
            title: 'Fecha de nacimiento',
            child: DateTimePicker(
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: textTheme.bodyText1
                  ?.copyWith(fontSize: fontSize, color: Constants.chatDarkGray),
              locale: Locale('es', 'ES'),
              dateMask: 'dd/MM/yyyy',
              initialValue: _birthday.toString(),
              firstDate: new DateTime(DateTime
                  .now()
                  .year - 100,
                  DateTime
                      .now()
                      .month, DateTime
                      .now()
                      .day),
              lastDate: new DateTime(DateTime
                  .now()
                  .year - 16,
                  DateTime
                      .now()
                      .month, DateTime
                      .now()
                      .day),
              onChanged: (dateTime) {
                setState(() => _birthday = DateTime.parse(dateTime));
              },
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'La fecha de nacimiento no puede estar vacía';
                return null;
              },
            ),
          ),
        ),
        CustomFlexRowColumn(
          childLeft: TextFormField(
            decoration: InputDecoration(
              labelText: StringConst.FORM_PHONE,
              prefixIcon: CountryCodePicker(
                onChanged: _onCountryChange,
                initialSelection: _phoneCode == '+34' ? 'ES' : _phoneCode == '+51' ? 'PE' : 'GT',
                countryFilter: ['ES', 'PE', 'GT'],
                showFlagDialog: true,
              ),
              focusColor: Constants.turquoise,
              labelStyle: textTheme.button?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: AppColors.greyUltraLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: AppColors.greyUltraLight,
                  width: 1.0,
                ),
              ),
            ),
            initialValue: _phone.indexOf(' ') < 0 ? _phone.substring(3) : _phone.substring(_phone.indexOf(' ') + 1),
            validator: (value) =>
            value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
            onSaved: (value) => this._phone = _phoneCode +' '+ value!,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.phone,
            style: textTheme.button?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
          ),
          childRight: Container(),
        ),
      ]),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    this._phoneCode =  countryCode.toString();
  }

  Widget _buildFormField({required BuildContext context,
    required String title,
    required Widget child,
    Widget? prefix}) {
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (prefix != null) prefix,
            Text(
              title,
              style: textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.bold,
                color: Constants.chatDarkGray,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
        SpaceH8(),
        child,
        SpaceH12(),
      ],
    );
  }

  Future<void> _submit(UserEnreda userEnreda) async {
    if (_validateAndSaveForm()) {
      List<String> interestsSelectedId = [];
      _interests
          .where((interest) =>
          _interestsSelected
              .any((interestName) => interest.name == interestName))
          .forEach((interest) {
        interestsSelectedId.add(interest.interestId!);
      });

      final updatedUserEnreda = userEnreda.copyWith(
          userId: _userId,
          firstName: _firstName,
          lastName: _lastName,
          email: _email,
          phone: _phone,
          gender: _gender,
          interests: interestsSelectedId,
          specificInterests: _specificInterest,
          address: Address(
              country: _countries
                  .firstWhere((country) => country.name == _country)
                  .countryId,
              province: _provinces
                  .firstWhere((province) => province.name == _province)
                  .provinceId,
              city: _cities
                  .firstWhere((city) => city.name == _city)
                  .cityId,
              postalCode: _postalCode),
          birthday: _birthday,
          role: _role,
          abilities: _abilities,
          unemployedType: _unemployedType);
      try {
        final database = Provider.of<Database>(context, listen: false);
        await database.setUserEnreda(updatedUserEnreda);
        showAlertDialog(
          context,
          title: 'Actualizado',
          content: 'Se han actualizado los datos de tu usuario',
          defaultActionText: 'Ok',
        );
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: 'Error al actualizar el recurso', exception: e);
      }
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }

    return false;
  }
}
