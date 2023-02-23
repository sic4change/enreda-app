import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enreda_app/app/home/models/ability.dart';
import 'package:enreda_app/app/home/models/addressUser.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/dedication.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/gender.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/interests.dart';
import 'package:enreda_app/app/home/models/motivation.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/app/home/models/timeSearching.dart';
import 'package:enreda_app/app/home/models/timeSpentWeekly.dart';
import 'package:enreda_app/app/home/models/unemployedUser.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/sign_in/email_sign_in_page.dart';
import 'package:enreda_app/app/sign_up/unemployedUser/unemployed_revision_form.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/checkbox_form.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_abilities.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_city.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_country.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_dedication.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_education.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_gender.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_interests.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_province.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_specificInterests.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_timeSearching.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_timeSpentWeekly.dart';
import 'package:enreda_app/common_widgets/custom_padding.dart';
import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/flex_row_column.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_app/common_widgets/text_form_field.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../../../../utils/responsive.dart';
import '../../../../../../values/values.dart';

const double contactBtnWidthLg = 200.0;
const double contactBtnWidthSm = 120.0;
const double contactBtnWidthMd = 150.0;

class UnemployedRegistering extends StatefulWidget {
  const UnemployedRegistering({Key? key}) : super(key: key);

  @override
  _UnemployedRegisteringState createState() => _UnemployedRegisteringState();
}

class _UnemployedRegisteringState extends State<UnemployedRegistering> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _formKeyMotivations = GlobalKey<FormState>();
  final _formKeyInterests = GlobalKey<FormState>();
  final _checkFieldKey = GlobalKey<FormState>();
  String? _email;
  String? _firstName;
  String? _lastName;
  DateTime? _birthday;
  String? _phone;
  String? _country;
  String? _province;
  String? _city;
  String? _postalCode;

  int? isRegistered;
  int usersIds = 0;
  int currentStep = 0;
  bool _isChecked = false;

  List<String> countries = [];
  List<String> provinces = [];
  List<String> cities = [];
  List abilities = [];
  List<String> interests = [];
  List<String> specificInterests = [];
  Set<Ability> selectedAbilities = {};
  Set<Interest> selectedInterests = {};
  Set<SpecificInterest> selectedSpecificInterests = {};

  String writtenEmail = '';
  Country? selectedCountry;
  Province? selectedProvince;
  City? selectedCity;
  Ability? selectedAbility;
  Dedication? selectedDedication;
  TimeSearching? selectedTimeSearching;
  TimeSpentWeekly? selectedTimeSpentWeekly;
  Education? selectedEducation;
  Gender? selectedGender;
  late String countryName;
  late String provinceName;
  late String cityName;
  String phoneCode = '+34';
  late String _formattedBirthdayDate;

  late String abilitesNames;
  late String dedicationName;
  late String timeSearchingName;
  late String timeSpentWeeklyName;
  late String educationName;
  late String genderName;
  late String interestsNames;
  late String specificInterestsNames;
  String? _abilityId;
  String? _interestId;
  int? dedicationValue;
  String? dedicationId;
  int? timeSearchingValue;
  String? timeSearchingId;
  int? timeSpentWeeklyValue;
  String? timeSpentWeeklyId;
  String? educationValue;
  String? unemployedType;

  TextEditingController textEditingControllerDateInput = TextEditingController();
  TextEditingController textEditingControllerAbilities = TextEditingController();
  TextEditingController textEditingControllerInterests = TextEditingController();
  TextEditingController textEditingControllerSpecificInterests = TextEditingController();

  int sum = 0;

  @override
  void initState() {
    super.initState();
    _email = "";
    _firstName = "";
    _lastName = "";
    _birthday = new DateTime.now();
    textEditingControllerDateInput.text = "";
    _phone = "";
    _country = "";
    _province = "";
    _city = "";
    _postalCode = "";
    countryName = "";
    provinceName = "";
    cityName = "";
    abilitesNames = "";
    dedicationName = "";
    timeSearchingName = "";
    timeSpentWeeklyName = "";
    educationName = "";
    genderName = "";
    interestsNames = "";
    specificInterestsNames = "";
    unemployedType = "";
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate() && isRegistered == 0) {
      form.save();
      return true;
    }
    return false;
  }

  bool _validateAndSaveMotivationForm() {
    final form = _formKeyMotivations.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        sum = dedicationValue! + timeSearchingValue! + timeSpentWeeklyValue!;
      });
      return true;
    }
    return false;
  }

  bool _validateAndSaveInterestsForm() {
    final form = _formKeyInterests.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool _validateCheckField() {
    final checkKey = _checkFieldKey.currentState;
    if (checkKey!.validate() && isRegistered == 0) {
      checkKey.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateCheckField()) {

      final address = Address(
        country: _country,
        province: _province,
        city: _city,
        postalCode: _postalCode,
      );

      final Dedication? dedication = new Dedication(
          label: dedicationName,
          value: dedicationValue!
      );

      final TimeSearching? timeSearching = new TimeSearching(
        label: timeSearchingName,
        value: timeSearchingValue!,
      );

      final TimeSpentWeekly? timeSpentWeekly = new TimeSpentWeekly(
          label: timeSpentWeeklyName,
          value: timeSearchingValue!
      );

      final motivation = Motivation(
        abilities: abilities,
        dedication: dedication,
        timeSearching: timeSearching,
        timeSpentWeekly: timeSpentWeekly,
      );

      final education = Education(
          label: educationName,
          value: educationValue,
          order: 0
      );

      final interestsSet = Interests(
        interests: interests,
        specificInterests: specificInterests,
      );

      if(sum >= 0 && sum <= 3)
        setState(() {
          this.unemployedType = 'T1';
        });
      if(sum >= 4 && sum <= 6)
        setState(() {
          this.unemployedType = 'T2';
        });
      if(sum >= 7 && sum <= 9)
        setState(() {
          this.unemployedType = 'T3';
        });
      if(sum > 9)
        setState(() {
          this.unemployedType = 'T4';
        });

      final unemployedUser = UnemployedUser(
          firstName: _firstName,
          lastName: _lastName,
          email: _email,
          phone: _phone,
          gender: genderName,
          birthday: _birthday,
          motivation: motivation,
          interests: interestsSet,
          education: education,
          address: address,
          role: 'Desempleado',
          unemployedType: unemployedType
      );
      try {
        final database = Provider.of<Database>(context, listen: false);
        await database.addUnemployedUser(unemployedUser);
        showAlertDialog(
          context,
          title: StringConst.FORM_SUCCESS,
          content: StringConst.FORM_SUCCESS_MAIL,
          defaultActionText: StringConst.FORM_ACCEPT,
        ).then((value) => {
          Navigator.of(this.context).push(
            MaterialPageRoute<void>(
              builder: ((context) => EmailSignInPage()),
            ),
          )
        },
        );
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: StringConst.FORM_ERROR, exception: e).then((value) => Navigator.pop(context));
      }
    }
  }

  void _onCountryChange(CountryCode countryCode) {
    this.phoneCode =  countryCode.toString();
  }

  /*
    Avoid call to database if email not properly written.
    Return empty stream if email not properly written
  */

  Widget _buildForm(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return
      Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              CustomFlexRowColumn(
                childLeft: customTextFormFieldName(context, _firstName!, StringConst.FORM_NAME, StringConst.NAME_ERROR, _name_setState),
                childRight: customTextFormFieldName(context, _lastName!, StringConst.FORM_LASTNAME, StringConst.FORM_LASTNAME_ERROR, _surname_setState),
              ),
              Flex(
                direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    flex: Responsive.isMobile(context) ? 0 : 1,
                    child: Padding(
                      padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: StringConst.FORM_PHONE,
                          prefixIcon:CountryCodePicker(
                            onChanged: _onCountryChange,
                            initialSelection: 'ES',
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
                        initialValue: _phone,
                        validator: (value) =>
                        value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
                        onSaved: (value) => this._phone = phoneCode +' '+ value!,
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
                    ),
                  ),
                  Expanded(
                      flex: Responsive.isMobile(context) ? 0 : 1,
                      child: Padding(
                        padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
                        child: TextFormField(
                          controller: textEditingControllerDateInput, //editing controller of this TextField
                          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_BIRTHDAY_ERROR,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today), //icon of text field
                            labelText: StringConst.FORM_BIRTHDAY, //label text of field
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
                          readOnly: true,  //set it true, so that user will not able to edit text
                          style: textTheme.button?.copyWith(
                            height: 1.5,
                            color: AppColors.greyDark,
                            fontWeight: FontWeight.w400,
                            fontSize: fontSize,
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: new DateTime(DateTime.now().year - 16, DateTime.now().month, DateTime.now().day),
                                firstDate: new DateTime(DateTime.now().year - 100, DateTime.now().month, DateTime.now().day),
                                lastDate: new DateTime(DateTime.now().year - 16, DateTime.now().month, DateTime.now().day),
                            );
                            if(pickedDate != null ){
                              print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                              _formattedBirthdayDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                              print(_formattedBirthdayDate); //formatted date output using intl package =>  2021-03-16
                              setState(() {
                                textEditingControllerDateInput.text = _formattedBirthdayDate; //set output date to TextField value.
                                _birthday = pickedDate;
                              });
                            }
                          },
                        ),
                      )
                  ),
                ],
              ),
              Flex(
                direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    flex: Responsive.isMobile(context) ? 0 : 1,
                    child: Padding(
                      padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
                      child: StreamBuilder <List<UserEnreda>>(
                          stream:
                          // Empty stream (no call to firestore) if email not valid
                          !EmailValidator.validate(writtenEmail)
                              ? Stream<List<UserEnreda>>.empty()
                              : database.checkIfUserEmailRegistered(writtenEmail),
                          builder:  (context, snapshotUsers) {

                            var usersListLength = snapshotUsers.data != null ? snapshotUsers.data?.length : 0;
                            isRegistered = usersListLength! > 0 ? 1 : 0;

                            final validationMessage = (value) => EmailValidator.validate(value!)
                                ? (isRegistered == 0 ? null : StringConst.EMAIL_REGISTERED)
                                : StringConst.EMAIL_ERROR;

                            return
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: StringConst.FORM_EMAIL,
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
                                initialValue: _email,
                                validator: validationMessage,
                                onSaved: (value) => _email = value,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) => setState(() => this.writtenEmail = value),
                                style: textTheme.button?.copyWith(
                                  height: 1.5,
                                  color: AppColors.greyDark,
                                  fontWeight: FontWeight.w400,
                                  fontSize: fontSize,
                                ),
                              );
                          }
                      ),
                    ),
                  ),
                  Expanded(
                    flex: Responsive.isMobile(context) ? 0 : 1,
                    child: Padding(
                        padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
                        child: streamBuilder_Dropdown_Genders(context, selectedGender, _buildGenderStreamBuilder_setState)
                    ),
                  ),
                ],
              ),
              CustomFlexRowColumn(
                childLeft: streamBuilderForCountry(context, selectedCountry, _buildCountryStreamBuilder_setState),
                childRight: streamBuilderForProvince(context, selectedCountry, selectedProvince, _buildProvinceStreamBuilder_setState),
              ),
              CustomFlexRowColumn(
                childLeft: streamBuilderForCity(context, selectedCountry, selectedProvince, selectedCity, _buildCityStreamBuilder_setState),
                childRight: customTextFormFieldName(context, _postalCode!, StringConst.FORM_POSTAL_CODE, StringConst.POSTAL_CODE_ERROR, _postalCode_setState),
              ),
            ]),
      );
  }

  Widget _buildFormMotivations(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return
      Form(
        key: _formKeyMotivations,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              CustomPadding(child: streamBuilderDropdownDedication(context, selectedDedication, _buildDedicationStreamBuilder_setState)),
              CustomPadding(child: streamBuilderDropdownTimeSearching(context, selectedTimeSearching, _buildTimeSearchingStreamBuilder_setState)),
              CustomPadding(child: streamBuilderDropdownTimeSpentWeekly(context, selectedTimeSpentWeekly, _buildTimeSpentWeeklyStreamBuilder_setState)),
              CustomPadding(
                child: TextFormField(
                  controller: textEditingControllerAbilities,
                  decoration: InputDecoration(
                    hintText: StringConst.FORM_ABILITIES,
                    hintMaxLines: 2,
                    labelStyle: textTheme.button?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.5,
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
                  onTap: () => {_showMultiSelectAbilities(context) },
                  validator: (value) => value!.isNotEmpty ?
                  null : StringConst.FORM_MOTIVATION_ERROR,
                  onSaved: (value) => value = _abilityId,
                  maxLines: 2,
                  readOnly: true,
                  style: textTheme.button?.copyWith(
                    height: 1.5,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ), ),
              CustomPadding(child: streamBuilderDropdownEducation(context, selectedEducation, _buildEducationStreamBuilder_setState)),
            ]),
      );
  }

  Widget _buildFormInterests(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return
      Form(
        key: _formKeyInterests,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
                child: TextFormField(
                  controller: textEditingControllerInterests,
                  decoration: InputDecoration(
                    hintText: StringConst.FORM_INTERESTS_QUESTION,
                    hintMaxLines: 2,
                    labelStyle: textTheme.bodyText1?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.5,
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
                  onTap: () => {_showMultiSelectInterests(context) },
                  validator: (value) => value!.isNotEmpty ?
                  null : StringConst.FORM_MOTIVATION_ERROR,
                  onSaved: (value) => value = _interestId,
                  maxLines: 2,
                  readOnly: true,
                  style: textTheme.button?.copyWith(
                    height: 1.5,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
                child: TextFormField(
                  controller: textEditingControllerSpecificInterests,
                  decoration: InputDecoration(
                    labelText: StringConst.FORM_SPECIFIC_INTERESTS,
                    labelStyle: textTheme.button?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.5,
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
                  onTap: () => {_showMultiSelectSpecificInterests(context) },
                  validator: (value) => value!.isNotEmpty ?
                  null : StringConst.FORM_MOTIVATION_ERROR,
                  onSaved: (value) => value = _interestId,
                  maxLines: 2,
                  readOnly: true,
                  style: textTheme.button?.copyWith(
                    height: 1.5,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ]),
      );
  }

  Widget _revisionForm(BuildContext context) {
    return Column(
      children: [
        UnemployedRevisionForm(
          context,
          _firstName!,
          _lastName!,
          _email!,
          genderName,
          countryName,
          provinceName,
          cityName,
          _postalCode!,
          abilitesNames,
          dedicationName,
          timeSearchingName,
          timeSpentWeeklyName,
          educationName,
          specificInterestsNames,
          interestsNames,
        ),
        checkboxForm(context, _checkFieldKey, _isChecked, functionSetState)
      ],
    );
  }

  void functionSetState(bool? val) {
    setState(() {
      _isChecked = val!;
    });
  }

  void _buildCountryStreamBuilder_setState(Country? country) {
    setState(() {
      this.selectedProvince = null;
      this.selectedCity = null;
      this.selectedCountry = country;
      countryName = country != null ? country.name : "";
    });
    _country = country?.countryId;
  }

  void _buildProvinceStreamBuilder_setState(Province? province) {
    setState(() {
      this.selectedCity = null;
      this.selectedProvince = province;
      provinceName = province != null ? province.name : "";
    });
    _province = province?.provinceId;
  }

  void _buildCityStreamBuilder_setState(City? city) {
    setState(() {
      this.selectedCity = city;
      cityName = city != null ? city.name : "";
    });
    _city = city?.cityId;
  }

  void _buildDedicationStreamBuilder_setState(Dedication? dedication) {
    setState(() {
      this.selectedDedication = dedication;
      dedicationName = dedication != null ? dedication.label : "";
      dedicationId = dedication?.dedicationId;
    });
    dedicationValue = dedication?.value;
  }

  void _buildTimeSearchingStreamBuilder_setState(TimeSearching? timeSearching) {
    setState(() {
      this.selectedTimeSearching = timeSearching;
      timeSearchingName = timeSearching != null ? timeSearching.label : "";
      timeSearchingId = timeSearching?.timeSearchingId;
    });
    timeSearchingValue = timeSearching?.value;
  }

  void _buildTimeSpentWeeklyStreamBuilder_setState(TimeSpentWeekly? timeSpentWeekly) {
    setState(() {
      this.selectedTimeSpentWeekly = timeSpentWeekly;
      timeSpentWeeklyName = timeSpentWeekly != null ? timeSpentWeekly.label : "";
      timeSpentWeeklyId = timeSpentWeekly?.timeSpentWeeklyId;
    });
    timeSpentWeeklyValue = timeSpentWeekly?.value;
  }

  void _buildEducationStreamBuilder_setState(Education? education) {
    setState(() {
      this.selectedEducation = education;
      educationName = education != null ? education.label : "";
    });
    educationValue = education?.value;
  }

  void _buildGenderStreamBuilder_setState(Gender? gender) {
    setState(() {
      this.selectedGender = gender;
      genderName = gender != null ? gender.name : "";
    });
  }

  void _name_setState(String? val) {
    setState(() => this._firstName = val!);
  }

  void _surname_setState(String? val) {
    setState(() => this._lastName = val!);
  }

  void _postalCode_setState(String? val) {
    setState(() => this._postalCode = val!);
  }

  void _showMultiSelectAbilities(BuildContext context) async {
    final selectedValues = await showDialog<Set<Ability>>(
      context: context,
      builder: (BuildContext context) {
        return streamBuilderDropdownAbilities(context, selectedAbilities);
      },
    );
    print(selectedValues);
    getValuesFromKeyAbilities(selectedValues);
  }

  void getValuesFromKeyAbilities (selectedValues) {
    var concatenate = StringBuffer();
    var abilitiesIds = [];
    selectedValues.forEach((item){
      concatenate.write(item.name +' / ');
      abilitiesIds.add(item.abilityId);
    });
    setState(() {
      this.abilitesNames = concatenate.toString();
      this.textEditingControllerAbilities.text = concatenate.toString();
      this.abilities = abilitiesIds;
      this.selectedAbilities = selectedValues;
    });
    print(abilitesNames);
    print(abilitiesIds);
  }

  void _showMultiSelectInterests(BuildContext context) async {
    final selectedValues = await showDialog<Set<Interest>>(
      context: context,
      builder: (BuildContext context) {
        return streamBuilderDropdownInterests(context, selectedInterests);
      },
    );
    print(selectedValues);
    getValuesFromKeyInterests(selectedValues);
  }

  void getValuesFromKeyInterests (selectedValues) {
    var concatenate = StringBuffer();
    List<String> interestsIds = [];
    selectedValues.forEach((item){
      concatenate.write(item.name +' / ');
      interestsIds.add(item.interestId);
    });
    setState(() {
      this.interestsNames = concatenate.toString();
      this.textEditingControllerInterests.text = concatenate.toString();
      this.interests = interestsIds;
      this.selectedInterests = selectedValues;
    });
    print(interestsNames);
    print(interestsIds);
  }

  void _showMultiSelectSpecificInterests(BuildContext context) async {
    final selectedValues = await showDialog<Set<SpecificInterest>>(
      context: context,
      builder: (BuildContext context) {
        return streamBuilderDropdownSpecificInterests(context, selectedInterests, selectedSpecificInterests);
      },
    );
    print(selectedValues);
    getValuesFromKeySpecificInterests(selectedValues);
  }

  void getValuesFromKeySpecificInterests (selectedValues) {
    var concatenate = StringBuffer();
    List<String> specificInterestsIds = [];
    selectedValues.forEach((item){
      concatenate.write(item.name +' / ');
      specificInterestsIds.add(item.specificInterestId);
    });
    setState(() {
      this.specificInterestsNames = concatenate.toString();
      this.textEditingControllerSpecificInterests.text = concatenate.toString();
      this.specificInterests = specificInterestsIds;
      this.selectedSpecificInterests = selectedValues;
    });
    print(interestsNames);
    print(specificInterestsIds);
  }


  List<Step> getSteps() => [
    Step(
      isActive: currentStep >= 0,
      state: currentStep > 0 ? StepState.complete : StepState.indexed,
      title: Text(StringConst.FORM_GENERAL_INFO.toUpperCase()),
      content: _buildForm(context),
    ),
    Step(
      isActive: currentStep >= 1,
      state: currentStep > 1 ? StepState.complete : StepState.disabled,
      title: Text(StringConst.FORM_MOTIVATION.toUpperCase()),
      content: _buildFormMotivations(context),
    ),
    Step(
      isActive: currentStep >= 2,
      state: currentStep > 2 ? StepState.complete : StepState.disabled,
      title: Text(StringConst.FORM_INTERESTS.toUpperCase()),
      content: _buildFormInterests(context),
    ),
    Step(
      isActive: currentStep >= 3,
      title: Text(StringConst.FORM_REVISION.toUpperCase()),
      content: _revisionForm(context),
    ),
  ];


  onStepContinue() async {
    // If invalid form, just return
    if (currentStep == 0 && !_validateAndSaveForm())
      return;

    if (currentStep == 1 && !_validateAndSaveMotivationForm())
      return;

    if (currentStep == 2 && !_validateAndSaveInterestsForm())
      return;

    // If not last step, advance and return
    final isLastStep = currentStep == getSteps().length-1;
    if (!isLastStep) {
      setState(() => {
        if(currentStep == 1 && sum >= 0 && sum <= 6 ) {
          this.currentStep += 2
        }
        else {
          this.currentStep += 1
        }
      });
      return;
    }
    _submit();
  }

  goToStep(int step){
      setState(() => this.currentStep = step);
  }

  onStepCancel() {
    if (currentStep > 0)
      goToStep(currentStep - 1);
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == getSteps().length-1;
    double screenWidth = widthOfScreen(context);
    double screenHeight = heightOfScreen(context);
    double contactBtnWidth = responsiveSize(
      context,
      contactBtnWidthSm,
      contactBtnWidthLg,
      md: contactBtnWidthMd,
    );
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Constants.white,
            toolbarHeight: Responsive.isMobile(context) ? 50 : 74,
            iconTheme: IconThemeData(
              color: Constants.grey, //change your color here
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Responsive.isMobile(context) ? Container() : Padding(
                  padding: EdgeInsets.all(Constants.mainPadding),
                  child: Image.asset(
                    ImagePath.LOGO,
                    height: Sizes.HEIGHT_24,
                  ),
                ),
                Responsive.isMobile(context) ? Container() : SizedBox(width: Constants.mainPadding),
                Container(
                  padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2), child: Text(StringConst.FORM_UNEMPLOYED.toUpperCase(),
                    style: TextStyle(color: AppColors.greyDark)),)
              ],
            ),
          ),
          body: Stack(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: Responsive.isMobile(context) || Responsive.isTablet(context) ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.70,
                      width: Responsive.isMobile(context) || Responsive.isTablet(context) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Borders.kDefaultPaddingDouble / 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Stepper(
                            type: Responsive.isMobile(context) ? StepperType.vertical : StepperType.horizontal,
                            steps: getSteps(),
                            currentStep: currentStep,
                            onStepContinue: onStepContinue,
                            onStepTapped: (step) => goToStep(step),
                            onStepCancel: onStepCancel,
                            controlsBuilder: (context, _) {
                              return Container(
                                height: Borders.kDefaultPaddingDouble * 2,
                                margin: EdgeInsets.only(top: Borders.kDefaultPaddingDouble * 2),
                                padding: const EdgeInsets.symmetric(horizontal: Borders.kDefaultPaddingDouble / 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    if(currentStep !=0)
                                      EnredaButton(
                                        buttonTitle: StringConst.FORM_BACK,
                                        width: contactBtnWidth,
                                        onPressed: onStepCancel,
                                      ),
                                    SizedBox(width: Borders.kDefaultPaddingDouble),
                                    EnredaButton(
                                      buttonTitle: isLastStep ? StringConst.FORM_CONFIRM : StringConst.FORM_NEXT,
                                      width: contactBtnWidth,
                                      buttonColor: AppColors.primaryColor,
                                      titleColor: AppColors.white,
                                      onPressed: onStepContinue,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Responsive.isTablet(context) || Responsive.isMobile(context) ?
                          Positioned(
                            top: screenHeight * 0.45,
                            left: -10,
                            child: Container(
                              height: 300 * 0.50,
                              child: ClipRRect(
                                child: Image.asset(ImagePath.CHICA_LATERAL),
                              ),
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Responsive.isTablet(context) || Responsive.isMobile(context) ? Container() :
              Positioned(
                top: screenHeight * 0.51,
                left: Responsive.isDesktopS(context) ? screenWidth * 0.06 : screenWidth * 0.09,
                child: Container(
                  height: 300,
                  child: ClipRRect(
                    child: Image.asset(ImagePath.CHICA_LATERAL),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}