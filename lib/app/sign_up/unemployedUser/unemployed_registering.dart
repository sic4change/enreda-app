import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enreda_app/app/anallytics/analytics.dart';
import 'package:enreda_app/app/home/home_page.dart';
import 'package:enreda_app/app/home/models/ability.dart';
import 'package:enreda_app/app/home/models/addressUser.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/dedication.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/gender.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/interests.dart';
import 'package:enreda_app/app/home/models/keepLearningOptions.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/app/home/models/timeSearching.dart';
import 'package:enreda_app/app/home/models/timeSpentWeekly.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/models/unemployedUser.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/pill_tooltip.dart';
import 'package:enreda_app/app/sign_up/unemployedUser/unemployed_revision_form.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/checkbox_form.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_abilities.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_city.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_country.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_dedication.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_education.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_gender.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_interests.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_keepLearning.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_nation.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_province.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_social_entity.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/select_specific_interests_dialog.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_timeSearching.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_timeSpentWeekly.dart';
import 'package:enreda_app/common_widgets/custom_date_picker_title.dart';
import 'package:enreda_app/common_widgets/custom_padding.dart';
import 'package:enreda_app/common_widgets/custom_phone_form_field_title.dart';
import 'package:enreda_app/common_widgets/custom_stepper.dart';
import 'package:enreda_app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/flex_row_column.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../../../../utils/responsive.dart';
import '../../../../../../values/values.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../common_widgets/rounded_container.dart';
import '../validating_form_controls/checkbox_data_form.dart';

const double contactBtnWidthLg = 200.0;
const double contactBtnWidthSm = 120.0;
const double contactBtnWidthMd = 150.0;

class UnemployedRegistering extends StatefulWidget {
  const UnemployedRegistering({Key? key}) : super(key: key);

  @override
  _UnemployedRegisteringState createState() => _UnemployedRegisteringState();
}

class _UnemployedRegisteringState extends State<UnemployedRegistering> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyMotivations = GlobalKey<FormState>();
  final _formKeyInterests = GlobalKey<FormState>();
  final _checkFieldKey = GlobalKey<FormState>();
  final _checkFieldKeyDataProtectionPolicy = GlobalKey<FormState>();
  bool isLoading = false;

  String? _email;
  String? _firstName;
  String? _lastName;
  DateTime? _birthday;
  String? _phone;
  String? _country;
  String? _province;
  String? _city;
  String? _postalCode;
  String? _nationality;
  String? _belongOrganization;

  int? isRegistered;
  int usersIds = 0;
  int currentStep = 0;
  bool _isChecked = false;
  bool _isCheckedDataProtectionPolicy = false;

  List<String> countries = [];
  List<String> provinces = [];
  List<String> cities = [];
  List abilities = [];
  List<String> interests = [];
  List<String> specificInterests = [];
  List<String> keepLearningOptions = [];
  Set<Ability> selectedAbilities = {};
  Set<Interest> selectedInterests = {};
  Set<KeepLearningOption> selectedKeepLearningOptions = {};
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
  SocialEntity? selectedSocialEntity;
  String? selectedNationality;
  late String countryName, nationalityName;
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
  late String keepLearningOptionsNames;
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
  String? futureLearning;
  String? _keepLearningOptionId;
  TextTheme? textTheme;

  TextEditingController textEditingControllerDateInput = TextEditingController();
  TextEditingController textEditingControllerAbilities = TextEditingController();
  TextEditingController textEditingControllerInterests = TextEditingController();
  TextEditingController textEditingControllerSpecificInterests = TextEditingController();
  TextEditingController textEditingControllerKeepLearningOptions = TextEditingController();

  int sum = 0;

  List<DropdownMenuItem<String>> _futureLearningOptions = ['No me interesa nada', 'Formación', 'Prácticas', 'Ocio', 'Voluntariado', 'Empleo'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

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
    nationalityName = '';
    keepLearningOptionsNames = '';
    _belongOrganization = "";

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

  bool _validateCheckDataField() {
    final checkKeyData = _checkFieldKeyDataProtectionPolicy.currentState;
    if (checkKeyData!.validate() && isRegistered == 0) {
      checkKeyData.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    bool checkFieldValid = _validateCheckField();
    bool checkDataFieldValid = _validateCheckDataField();

    if (checkFieldValid && checkDataFieldValid) {

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

      final interestsSet = Interests(
        interests: interests,
        specificInterests: specificInterests,
        surePurpose: selectedDedication,
        continueLearning: keepLearningOptions,
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
        interests: interestsSet,
        educationId: selectedEducation?.educationId ?? "",
        address: address,
        role: 'Desempleado',
        unemployedType: unemployedType,
        nationality: selectedNationality,
        assignedEntityId: selectedSocialEntity?.socialEntityId ?? null,
        checkAgreeCV: _isCheckedDataProtectionPolicy,
        gamificationFlags: {
          UserEnreda.FLAG_SIGN_UP: true,
        },
      );
      try {
        final database = Provider.of<Database>(context, listen: false);
        setState(() => isLoading = true);
        await database.addUnemployedUser(unemployedUser);
        setState(() => isLoading = false);
        showAlertDialog(
          context,
          title: StringConst.FORM_SUCCESS,
          content: StringConst.FORM_SUCCESS_MAIL,
          defaultActionText: StringConst.FORM_ACCEPT,
        ).then((value) => {
          Navigator.of(this.context).push(
            MaterialPageRoute<void>(
              builder: ((context) {
                return HomePage();
              }),
            ),
          )
        },
        );
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: StringConst.FORM_ERROR, exception: e).then((value) => Navigator.pop(context));
      }
    } else {
      if (!checkFieldValid) {
        showAlertDialog(
          context,
          title: 'Aviso',
          content: 'Para continuar debe aceptar las Políticas y Condiciones de uso.',
          defaultActionText: 'Aceptar',
        );
        return;
      }
      if (!checkDataFieldValid) {
        showAlertDialog(
          context,
          title: 'Aviso',
          content: 'Para continuar debe autorizar el uso de sus datos personales.',
          defaultActionText: 'Aceptar',
        );
        return;
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
    return
      Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              CustomFlexRowColumn(
                contentPadding: EdgeInsets.all(0.0),
                separatorSize: Sizes.kDefaultPaddingDouble,
                childLeft: CustomTextFormFieldTitle(
                    labelText: StringConst.FORM_NAME,
                    initialValue: _firstName!,
                    validator: (value) =>
                    value!.isNotEmpty ? null : StringConst.NAME_ERROR,
                    onSaved: _name_setState
                ),
                childRight: CustomTextFormFieldTitle(
                    labelText: StringConst.FORM_LASTNAME,
                    initialValue: _lastName!,
                    validator: (value) =>
                    value!.isNotEmpty ? null : StringConst.FORM_LASTNAME_ERROR,
                    onSaved: _surname_setState
                ),
              ),
              SpaceH20(),
              Flex(
                direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    flex: Responsive.isMobile(context) ? 0 : 1,
                    child: CustomDatePickerTitle(
                      labelText: StringConst.FORM_BIRTHDAY,
                      onChanged: (value){//pickedDate output format => 2021-03-10 00:00:00.000
                        _formattedBirthdayDate = DateFormat('dd-MM-yyyy').format(value!);
                        print(_formattedBirthdayDate); //formatted date output using intl package =>  2021-03-16
                        setState(() {
                          textEditingControllerDateInput.text = _formattedBirthdayDate; //set output date to TextField value.
                          _birthday = value;
                        });
                      },
                      validator: (value) => value != null ? null : StringConst.FORM_BIRTHDAY_ERROR,
                    ),
                  ),
                  if (Responsive.isMobile(context))
                    SpaceH20(),
                  if (!Responsive.isMobile(context))
                    SpaceW20(),
                  Expanded(
                    flex: Responsive.isMobile(context) ? 0 : 1,
                    child: streamBuilder_Dropdown_Genders(context, selectedGender, _buildGenderStreamBuilder_setState, null),
                  ),
                ],
              ),
              SpaceH20(),
              streamBuilderForNation(context, selectedNationality,
                  _buildNationalityStreamBuilder_setState, StringConst.FORM_CURRENT_NATIONALITY, nationalityName),
              SpaceH20(),
              Flex(
                direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    flex: Responsive.isMobile(context) ? 0 : 1,
                    child: CustomPhoneFormFieldTitle(
                      labelText: StringConst.FORM_PHONE,
                      phoneCode: phoneCode,
                      onCountryChange: _onCountryChange,
                      initialValue: _phone,
                      validator: (value) =>
                      value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
                      onSaved: (value) => this._phone = phoneCode +' '+ value!,
                      fontSize: 15,
                    ),
                  ),
                  if (Responsive.isMobile(context))
                    SpaceH20(),
                  if (!Responsive.isMobile(context))
                    SpaceW20(),
                  Expanded(
                    flex: Responsive.isMobile(context) ? 0 : 1,
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

                          return CustomTextFormFieldTitle(
                            labelText: StringConst.FORM_EMAIL,
                            initialValue: _email,
                            validator: validationMessage,
                            onSaved: (value) => _email = value,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => setState(() => this.writtenEmail = value),
                          );
                        }
                    ),
                  ),
                ],
              ),
              SpaceH20(),
              CustomFlexRowColumn(
                contentPadding: EdgeInsets.all(0.0),
                separatorSize: Sizes.kDefaultPaddingDouble,
                childLeft: streamBuilderForCountry(context, selectedCountry,
                    _buildCountryStreamBuilder_setState, null, StringConst.FORM_CURRENT_COUNTRY),
                childRight: streamBuilderForProvince(context, selectedCountry?.countryId, selectedProvince,
                    _buildProvinceStreamBuilder_setState, null),
              ),
              SpaceH20(),
              CustomFlexRowColumn(
                contentPadding: EdgeInsets.all(0.0),
                separatorSize: Sizes.kDefaultPaddingDouble,
                childLeft: streamBuilderForCity(context, selectedProvince?.provinceId, selectedCity,
                    _buildCityStreamBuilder_setState, null),
                //childLeft: Container(),
                childRight: CustomTextFormFieldTitle(
                    labelText: StringConst.FORM_POSTAL_CODE,
                    initialValue: _postalCode!,
                    /*validator: (value) =>
                      value!.isNotEmpty ? null : StringConst.POSTAL_CODE_ERROR,*/
                    onSaved: _postalCode_setState,
                  validator: (value) =>
                  value!.isNotEmpty ? null : StringConst.POSTAL_CODE_ERROR,
                ),
              ),
              SpaceH20(),
              streamBuilderDropdownEducation(context, selectedEducation,
                  _buildEducationStreamBuilder_setState, null, StringConst.FORM_EDUCATION),
              SpaceH20(),
              ///Definir user assinedById cuando unemployed se registre solo, error en Contact Page
              streamBuilderForSocialEntity(context, selectedSocialEntity,
                   _buildSocialEntityStreamBuilder_setState, null, StringConst.FORM_SOCIAL_ENTITY),
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
                    labelStyle: textTheme.bodySmall?.copyWith(
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
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ), ),
              CustomPadding(child: streamBuilderDropdownEducation(context, selectedEducation, _buildEducationStreamBuilder_setState, null, StringConst.FORM_EDUCATION)),
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
              CustomPadding(child: Container(
                  height: 60,
                  child: streamBuilderDropdownDedication(context, selectedDedication, _buildDedicationStreamBuilder_setState))),
              Padding(
                padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                child: Container(
                  height: 60,
                  child: TextFormField(
                    controller: textEditingControllerInterests,
                    decoration: InputDecoration(
                      hintText: StringConst.FORM_INTERESTS_QUESTION,
                      hintMaxLines: 2,
                      labelStyle: textTheme.bodySmall?.copyWith(
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
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                child: Container(
                  height: 60,
                  child: TextFormField(
                    controller: textEditingControllerSpecificInterests,
                    decoration: InputDecoration(
                      labelText: StringConst.FORM_SPECIFIC_INTERESTS,
                      labelStyle: textTheme.bodySmall?.copyWith(
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
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                child: Container(
                  height: 60,
                  child: TextFormField(
                    controller: textEditingControllerKeepLearningOptions,
                    decoration: InputDecoration(
                      hintText: '¿Qué te gustaría seguir aprendiendo?',
                      hintMaxLines: 2,
                      labelStyle: textTheme.bodySmall?.copyWith(
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
                    onTap: () => {_showMultiSelectKeepLearningOptions(context) },
                    validator: (value) => value!.isNotEmpty ?
                    null : StringConst.FORM_MOTIVATION_ERROR,
                    onSaved: (value) => value = _keepLearningOptionId,
                    maxLines: 2,
                    readOnly: true,
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
            ]),
      );
  }

  Widget _revisionForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: Responsive.isMobile(context) ? null // No image on mobile devices
        : DecorationImage(
          image: AssetImage(ImagePath.LOGO_LINES),
          fit: BoxFit.cover, // Ensures the image covers the entire container
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundedContainer(
            width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.5,
            margin: Responsive.isMobile(context) ? EdgeInsets.all(0) : EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            contentPadding: Responsive.isMobile(context) ? EdgeInsets.all(0) : EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            borderColor: Responsive.isMobile(context) ? Colors.transparent : AppColors.greyLight,
            child: unemployedRevisionForm(
              context,
              _firstName!,
              _lastName!,
              _email!,
              _phone!,
              nationalityName,
              genderName,
              countryName,
              provinceName,
              cityName,
              _postalCode!,
              educationName,
              specificInterestsNames,
              interestsNames,
              keepLearningOptionsNames,
            ),
          ),
          Padding(
            padding: Responsive.isMobile(context) ? EdgeInsets.all(0) : const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                checkboxForm(context, _checkFieldKey, _isChecked, functionSetState),
                checkboxDataForm(context, _checkFieldKeyDataProtectionPolicy, _isCheckedDataProtectionPolicy, functionDataSetState),
              ],
            ),
          )
        ],
      ),
    );
  }

  void functionSetState(bool? val) {
    setState(() {
      _isChecked = val!;
    });
  }

  void functionDataSetState(bool? val) {
    setState(() {
      _isCheckedDataProtectionPolicy = val!;
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
      educationName = (education != null ? education.label : "");
    });
    educationValue = education?.value;
  }

  void _buildGenderStreamBuilder_setState(Gender? gender) {
    setState(() {
      this.selectedGender = gender;
      genderName = gender != null ? gender.name : "";
    });
  }

  void _buildSocialEntityStreamBuilder_setState(SocialEntity? socialEntity) {
    setState(() {
      this.selectedSocialEntity = socialEntity;
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

  void _buildNationalityStreamBuilder_setState(String? nation) {
    setState(() {
      this.selectedNationality = nation;
      nationalityName = nation != null ? nation : "";
    });
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
      selectedSpecificInterests.removeWhere((si) => !selectedInterests.any((i) => i.interestId == si.interestId));
      getValuesFromKeySpecificInterests(selectedSpecificInterests);
    });
    print(interestsNames);
    print(interestsIds);
  }

  void _showMultiSelectSpecificInterests(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    final allSpecificInterests = await database.specificInterestsStream().first;

    final selectedValues = await showDialog<Set<SpecificInterest>>(
      context: context,
      builder: (BuildContext context) {
        return selectSpecificInterestsDialog(
            context,
            selectedInterests,
            selectedSpecificInterests,
            allSpecificInterests
        );
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

  void _showMultiSelectKeepLearningOptions(BuildContext context) async {
    final selectedOptions = await showDialog<Set<KeepLearningOption>>(
      context: context,
      builder: (BuildContext context) {
        return streamBuilderDropdownKeepLearningOptions(context, selectedKeepLearningOptions);
      },
    );
    print(selectedOptions);
    getValuesFromKeyKeepLearningOptions(selectedOptions);
  }

  void getValuesFromKeyKeepLearningOptions (selectedOptions) {
    var concatenate = StringBuffer();
    List<String> keepLearningIds = [];
    selectedOptions.forEach((item){
      concatenate.write(item.title +' / ');
      keepLearningIds.add(item.keepLearningOptionId);
    });
    setState(() {
      this.keepLearningOptionsNames = concatenate.toString();
      this.textEditingControllerKeepLearningOptions.text = concatenate.toString();
      this.keepLearningOptions = keepLearningIds;
      this.selectedKeepLearningOptions = selectedOptions;
    });
    print(keepLearningOptionsNames);
    print(keepLearningIds);
  }


  List<CustomStep> getSteps() => [
    CustomStep(
      isActive: currentStep >= 0,
      state: currentStep > 0 ? CustomStepState.complete : CustomStepState.indexed,
      title: Container(
        padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble/2),
        decoration: BoxDecoration(
          color: currentStep >= 0? AppColors.yellowAlt : AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble*2),
          border: Border.all(color: AppColors.greyLight, width: 2.0,),
        ),
        child: Text(StringConst.FORM_GENERAL_INFO,
            style: TextStyle(
                color: AppColors.primary900,
                fontWeight: FontWeight.w800,
                fontSize: 15
            )
        )
      ),
      content: _buildForm(context),
    ),
    CustomStep(
      isActive: currentStep >= 1,
      state: currentStep > 1 ? CustomStepState.complete : CustomStepState.disabled,
      title: Container(
        padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble/2),
        decoration: BoxDecoration(
          color: currentStep >= 1? AppColors.yellowAlt : AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble*2),
          border: Border.all(color: AppColors.greyLight, width: 2.0,),
        ),
        child: Text(
          StringConst.FORM_INTERESTS,
          style: TextStyle(
              color: AppColors.primary900,
              fontWeight: FontWeight.w800,
              fontSize: 15
          )
        ),
      ),
      content: _buildFormInterests(context),
    ),
    CustomStep(
      isActive: currentStep >= 2,
      state: currentStep > 2 ? CustomStepState.complete : CustomStepState.disabled,
      title: Container(
        padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble/2),
        decoration: BoxDecoration(
          color: currentStep >= 2? AppColors.yellowAlt: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble*2),
          border: Border.all(color: AppColors.greyLight, width: 2.0,),
        ),
        child: Text(
          StringConst.FORM_REVISION,
            style: TextStyle(
                color: AppColors.primary900,
                fontWeight: FontWeight.w800,
                fontSize: 15
            )
        ),
      ),
      content: _revisionForm(context),
    ),
  ];

  onStepContinue() async {
    // If invalid form, just return
    if (currentStep == 0 && !_validateAndSaveForm())
      return;

    if (currentStep == 1 && !_validateAndSaveInterestsForm())
      return;


    // If not last step, advance and return
    final isLastStep = currentStep == getSteps().length - 1;
    if (!isLastStep) {
      setState(() => this.currentStep += 1);
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
    sendBasicAnalyticsEvent(context, "enreda_app_visit_sign_in_page");
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
                    height: Sizes.HEIGHT_30,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                    child: CustomTextMediumBold(text: StringConst.FORM_UNEMPLOYED,)),
              ],
            ),
          ),
          body: Center(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: Responsive.isMobile(context) ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.9,
                maxWidth: Responsive.isMobile(context) ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.width * 0.7,
              ),
              child: RoundedContainer(
                color: AppColors.grey80,
                borderColor: Responsive.isMobile(context) ? Colors.transparent : AppColors.gre600,
                margin: Responsive.isMobile(context) ? EdgeInsets.all(0) : EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                contentPadding: Responsive.isMobile(context) ? EdgeInsets.all(0) : EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: Sizes.kDefaultPaddingDouble * 3),
                      child: CustomStepper(
                        elevation: 0.0,
                        type: Responsive.isMobile(context) ? CustomStepperType.vertical : CustomStepperType.horizontal,
                        steps: getSteps(),
                        currentStep: currentStep,
                        onStepContinue: onStepContinue,
                        onStepTapped: (step) => goToStep(step),
                        onStepCancel: onStepCancel,
                        controlsBuilder: (context, _) {
                          return Container(
                            height: Borders.kDefaultPaddingDouble * 2,
                            margin: EdgeInsets.only(top: Borders.kDefaultPaddingDouble * 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                if(currentStep != 0)
                                  EnredaButton(
                                    buttonTitle: StringConst.FORM_BACK,
                                    width: contactBtnWidth,
                                    onPressed: onStepCancel,
                                  ),
                                SizedBox(width: Borders.kDefaultPaddingDouble),
                                isLoading ? Center(child: CircularProgressIndicator(color: AppColors.primary300,)) :
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                      child: Row(
                        children: [
                          CustomTextMedium(text: StringConst.FORM_CREATE_PROFILE,),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: Responsive.isMobile(context) || Responsive.isTablet(context)? 30.0: 0.0),
                            child: Container(
                                width: 34,
                                child: PillTooltip(title: StringConst.PILL_TRAVEL_BEGINS, pillId: TrainingPill.TRAVEL_BEGINS_ID)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}