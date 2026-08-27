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
// import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_social_entity.dart'; // commented: social entity selector replaced by companionship Si/No
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
import 'package:go_router/go_router.dart';
import 'package:enreda_app/services/location_cache.dart';
import '../../../../../../services/database.dart';
import '../../../../../../utils/responsive.dart';
import '../../../../../../values/values.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../common_widgets/rounded_container.dart';
import '../validating_form_controls/bubbled_container.dart';
import 'package:enreda_app/app/home/models/companion_data.dart';
import '../validating_form_controls/checkbox_data_form.dart';
import '../validating_form_controls/checkbox_newsletter_form.dart';

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
  final _formKeyCompanion = GlobalKey<FormState>();
  final _checkFieldKey = GlobalKey<FormState>();
  final _checkFieldKeyDataProtectionPolicy = GlobalKey<FormState>();
  final _checkFieldKeyNewsletter = GlobalKey<FormState>();
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
  String? _nationalitySecond;
  bool _showSecondNationality = false;
  String? _belongOrganization;

  // Companion step
  bool? _needsCompanionship; // null = not answered, true = Si, false = No
  String? _companionFamilySituation;
  String? _companionDateArriveSpain;
  String? _companionAdministrativeStatus;
  bool? _companionWorkPermit;
  String? _companionWorkPermitRenewalDate;
  String? _companionDocumentType;
  String? _companionDocumentNumber;
  List<String> _companionHelpNeeds = [];
  bool _companionHelpNeedsOther = false;
  String? _companionHelpNeedsOtherText;
  List<String> _companionContactSchedule = [];
  bool? _companionProfessionalHelp;
  String? _companionOtherRelevantData;

  int isRegistered = 0;
  int usersIds = 0;
  int currentStep = 0;
  bool _isChecked = false;
  bool _isCheckedDataProtectionPolicy = false;
  bool _isNewsletterChecked = false;

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
  String? selectedNationalitySecond;
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
  late String entityName;
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

  late Future<void> _cacheReadyFuture;

  List<DropdownMenuItem<String>> _futureLearningOptions = ['No me interesa nada', 'Formación', 'Prácticas', 'Ocio', 'Voluntariado', 'Empleo'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    _cacheReadyFuture = LocationCache.instance.warmUp(database);
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
    entityName = "Ninguna";
    _needsCompanionship = null;
    _companionHelpNeeds = [];
    _companionHelpNeedsOther = false;
    _companionContactSchedule = [];
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
        nationalitySecond: selectedNationalitySecond,
        assignedEntityId: selectedSocialEntity?.socialEntityId ?? null,
        checkAgreeCV: _isCheckedDataProtectionPolicy,
        newsletterSubscribed: _isNewsletterChecked,
        gamificationFlags: {
          UserEnreda.FLAG_SIGN_UP: true,
        },
      );
      try {
        final database = Provider.of<Database>(context, listen: false);
        setState(() => isLoading = true);
        await database.addUnemployedUser(unemployedUser);
        // Save companion data if user requested accompaniment
        if (_needsCompanionship == true) {
          final helpNeedsList = List<String>.from(_companionHelpNeeds);
          if (_companionHelpNeedsOther && (_companionHelpNeedsOtherText?.isNotEmpty ?? false)) {
            helpNeedsList.add('Otro: ${_companionHelpNeedsOtherText!}');
          }
          final companionData = CompanionData(
            userId: _email ?? '',
            companionFamilySituation: _companionFamilySituation,
            companionDateArriveSpain: _companionDateArriveSpain,
            companionAdministrativeStatus: _companionAdministrativeStatus,
            companionWorkPermit: _companionWorkPermit,
            companionWorkPermitRenewalDate: _companionWorkPermit == true ? _companionWorkPermitRenewalDate : null,
            companionDocumentType: _companionDocumentType,
            companionDocumentNumber: _companionDocumentNumber,
            companionHelpNeeds: helpNeedsList,
            companionContactSchedule: _companionContactSchedule,
            companionProfessionalHelp: _companionProfessionalHelp,
            companionOtherRelevantData: _companionOtherRelevantData,
          );
          await database.addCompanionData(companionData);
        }
        setState(() => isLoading = false);
        showAlertDialog(
          context,
          title: StringConst.FORM_SUCCESS,
          content: StringConst.FORM_SUCCESS_MAIL,
          defaultActionText: StringConst.FORM_ACCEPT,
        ).then((value) {
          if (Constants.pendingResourceId != null) {
            String rid = Constants.pendingResourceId!;
            Constants.pendingResourceId = null;
            GoRouter.of(context).go('${StringConst.PATH_RESOURCES}/$rid');
          } else if (Constants.pendingTrainingPillId != null) {
            String rid = Constants.pendingTrainingPillId!;
            Constants.pendingTrainingPillId = null;
            GoRouter.of(context).go('${StringConst.PATH_TRAINING_PILLS}/$rid');
          } else {
            Navigator.of(this.context).push(
              MaterialPageRoute<void>(
                builder: ((context) {
                  return HomePage();
                }),
              ),
            );
          }
        });
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
              streamBuilderForNation(
                context,
                selectedNationality,
                _buildNationalityStreamBuilder_setState,
                StringConst.FORM_CURRENT_NATIONALITY,
                nationalityName,
                trailing: _buildAddNationalityButton(),
              ),
              if (_showSecondNationality) ...
              [
                SpaceH16(),
                streamBuilderForNation(
                  context,
                  selectedNationalitySecond,
                  _buildNationalitySecondStreamBuilder_setState,
                  StringConst.FORM_SECOND_NATIONALITY,
                  _nationalitySecond,
                  isRequired: false,
                ),
              ],
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
                childRight: CustomTextFormFieldTitle(
                    labelText: StringConst.FORM_POSTAL_CODE,
                    initialValue: _postalCode!,
                    onSaved: _postalCode_setState,
                  validator: (value) =>
                  value!.isNotEmpty ? null : StringConst.POSTAL_CODE_ERROR,
                ),
              ),
              SpaceH20(),
              streamBuilderDropdownEducation(context, selectedEducation,
                  _buildEducationStreamBuilder_setState, null, StringConst.FORM_EDUCATION),
              SpaceH20(),
              // Pregunta de acompañamiento (reemplaza al selector de entidad social)
              _buildNeedsCompanionshipSelector(context),
              // streamBuilderForSocialEntity(
              //   context, selectedSocialEntity,
              //   _buildSocialEntityStreamBuilder_setState, null,
              //   StringConst.FORM_SOCIAL_ENTITY, true
              // ),
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
    return
      Form(
        key: _formKeyInterests,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              CustomPadding(child:
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextSmall(text: StringConst.FORM_DEDICATION,),
                  Container(
                      height: 60,
                      child: streamBuilderDropdownDedication(context, selectedDedication, _buildDedicationStreamBuilder_setState)),
                ],
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormField(
                  validator: (value) {
                    if (selectedInterests.isEmpty) {
                      return 'Por favor seleccione al menos un interés';
                    }
                    return null;
                  },
                  builder: (FormFieldState<dynamic> field) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          CustomTextSmall(text: StringConst.FORM_INTERESTS_QUESTION,),
                          InkWell(
                            onTap: () => {_showMultiSelectInterests(context) },
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(minHeight: 50),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                      color: AppColors.greyUltraLight
                                  )
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                                child: Wrap(
                                  spacing: 5,
                                  children: selectedInterests.map((s) =>
                                      BubbledContainer(s.name),
                                  ).toList(),
                                ),
                              ),
                            ),
                          ),
                          if (!field.isValid && field.errorText != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                field.errorText!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ]);
                  }
                ),
              ),
              if (selectedInterests.isNotEmpty &&
                  !selectedInterests.every(
                      (i) => i.name.trim().toLowerCase() == 'sin clasificar'))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FormField(
                      validator: (value) {
                        if (selectedSpecificInterests.isEmpty) {
                          return 'Por favor seleccione al menos un interés específico';
                        }
                        return null;
                      },
                      builder: (FormFieldState<dynamic> field) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget> [
                              CustomTextSmall(text: StringConst.FORM_SPECIFIC_INTERESTS,),
                              InkWell(
                                onTap: () => {_showMultiSelectSpecificInterests(context) },
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(minHeight: 50),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          color: AppColors.greyUltraLight
                                      )
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                                    child: Wrap(
                                      spacing: 5,
                                      children: selectedSpecificInterests.map((s) =>
                                          BubbledContainer(s.name),
                                      ).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              if (!field.isValid && field.errorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    field.errorText!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ]);
                      }
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormField(
                    validator: (value) {
                      if (selectedKeepLearningOptions.isEmpty) {
                        return 'Por favor seleccione al menos una opción';
                      }
                      return null;
                    },
                    builder: (FormFieldState<dynamic> field) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget> [
                            CustomTextSmall(text: StringConst.FORM_KEEP_LEARNING_OPTIONS,),
                            InkWell(
                              onTap: () => {_showMultiSelectKeepLearningOptions(context) },
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(minHeight: 50),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                        color: AppColors.greyUltraLight
                                    )
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                                  child: Wrap(
                                    spacing: 5,
                                    children: selectedKeepLearningOptions.map((s) =>
                                        BubbledContainer(s.title),
                                    ).toList(),
                                  ),
                                ),
                              ),
                            ),
                            if (!field.isValid && field.errorText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  field.errorText!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ]);
                    }
                ),
              ),
            ]),
      );
  }

  Widget _buildNeedsCompanionshipSelector(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      errorStyle: const TextStyle(height: 0.01),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: AppColors.greyUltraLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: AppColors.greyUltraLight, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            StringConst.FORM_NEEDS_COMPANIONSHIP,
            style: textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _needsCompanionship == null ? null : (_needsCompanionship! ? 'Sí' : 'No'),
          isExpanded: true,
          isDense: true,
          decoration: inputDecoration.copyWith(
            hintText: 'Selecciona...',
          ),
          items: ['Sí', 'No']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() {
              if (val == 'Sí') {
                _needsCompanionship = true;
              } else if (val == 'No') {
                _needsCompanionship = false;
              } else {
                _needsCompanionship = null;
              }
            });
          },
          onSaved: (val) {
            if (val == 'Sí') {
              _needsCompanionship = true;
            } else if (val == 'No') {
              _needsCompanionship = false;
            }
          },
          style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
        ),
      ],
    );
  }

  Widget _buildFormCompanion(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      errorStyle: const TextStyle(height: 0.01),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: AppColors.greyUltraLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: AppColors.greyUltraLight, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
    );

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          height: 1.5,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );

    Widget fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          height: 1.5,
          color: AppColors.greyDark,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );

    return Form(
      key: _formKeyCompanion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Situación familiar ──────────────────────────────────────────────
          sectionTitle('Situación familiar'),
          fieldLabel('¿Tienes alguna responsabilidad familiar? ¿Tienes familiares en España?'),
          TextFormField(
            initialValue: _companionFamilySituation,
            minLines: 2,
            maxLines: 4,
            decoration: inputDecoration.copyWith(
              hintText: 'Describe brevemente tu situación familiar en España...',
              hintStyle: textTheme.bodySmall?.copyWith(color: AppColors.greyLight, fontSize: fontSize),
            ),
            style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
            onSaved: (v) => _companionFamilySituation = v,
            onChanged: (v) => _companionFamilySituation = v,
          ),
          SpaceH20(),

          // ── Fecha de llegada ─────────────────────────────────────────────────
          sectionTitle('Fecha de llegada a España'),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.greyDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Añade la fecha en la que llegaste a España',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _companionDateArriveSpain,
            decoration: inputDecoration.copyWith(
              hintText: '¿Recuerdas la fecha exacta? Indica el año, mes o día en que llegaste al país.',
              hintStyle: textTheme.bodySmall?.copyWith(color: AppColors.greyLight, fontSize: fontSize),
            ),
            style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
            onSaved: (v) => _companionDateArriveSpain = v,
            onChanged: (v) => _companionDateArriveSpain = v,
          ),
          SpaceH20(),

          // ── Situación administrativa ────────────────────────────────────────
          fieldLabel('Situación administrativa'),
          DropdownButtonFormField<String>(
            value: _companionAdministrativeStatus,
            isExpanded: true,
            isDense: true,
            decoration: inputDecoration.copyWith(
              hintText: 'Selecciona...',
            ),
            items: ['Regular', 'Irregular', 'En trámite', 'No lo tengo claro']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _companionAdministrativeStatus = v),
            onSaved: (v) => _companionAdministrativeStatus = v,
            style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
          ),
          SpaceH20(),

          // ── Permiso de trabajo ───────────────────────────────────────────────
          fieldLabel('Permiso de trabajo'),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _companionWorkPermit,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() => _companionWorkPermit = v),
              ),
              Text('Sí', style: textTheme.bodySmall?.copyWith(fontSize: 15, color: AppColors.greyDark)),
              const SizedBox(width: 16),
              Radio<bool>(
                value: false,
                groupValue: _companionWorkPermit,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() => _companionWorkPermit = v),
              ),
              Text('No', style: textTheme.bodySmall?.copyWith(fontSize: 15, color: AppColors.greyDark)),
            ],
          ),
          if (_companionWorkPermit == true) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.greyDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Añade la fecha de renovación de tu permiso de trabajo.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _companionWorkPermitRenewalDate,
              decoration: inputDecoration,
              style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
              onSaved: (v) => _companionWorkPermitRenewalDate = v,
              onChanged: (v) => _companionWorkPermitRenewalDate = v,
            ),
          ],
          SpaceH20(),

          // ── Tipo de documento + Número ────────────────────────────────────
          Flex(
            direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: Responsive.isMobile(context) ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('¿Qué tipo de documento tienes actualmente?'),
                    DropdownButtonFormField<String>(
                      value: _companionDocumentType,
                      isExpanded: true,
                      isDense: true,
                      decoration: inputDecoration.copyWith(hintText: 'Selecciona...'),
                      items: ['DNI', 'NIE', 'Pasaporte o Cédula de Pasaporte']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _companionDocumentType = v),
                      onSaved: (v) => _companionDocumentType = v,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
                    ),
                  ],
                ),
              ),
              if (Responsive.isMobile(context)) SpaceH20() else const SizedBox(width: 16),
              Expanded(
                flex: Responsive.isMobile(context) ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('Número de documento'),
                    TextFormField(
                      initialValue: _companionDocumentNumber,
                      decoration: inputDecoration.copyWith(
                        hintText: 'Escribe el número de documento',
                        hintStyle: textTheme.bodySmall?.copyWith(color: AppColors.greyLight, fontSize: fontSize),
                      ),
                      style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
                      onSaved: (v) => _companionDocumentNumber = v,
                      onChanged: (v) => _companionDocumentNumber = v,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SpaceH20(),

          // ── ¿Cómo te podemos ayudar? ────────────────────────────────────────
          sectionTitle('¿Cómo te podemos ayudar?'),
          fieldLabel('Selecciona una o varias...'),
          ...[
            'Ocio y tiempo libre',
            'Clases de español',
            'Formación',
            'Competencias digitales - Aula abierta',
            'Acompañamiento jurídico',
            'Acompañamiento hacia el empleo',
          ].map((option) {
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primaryColor,
              title: Text(option, style: textTheme.bodySmall?.copyWith(fontSize: fontSize, color: AppColors.greyDark)),
              value: _companionHelpNeeds.contains(option),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _companionHelpNeeds.add(option);
                  } else {
                    _companionHelpNeeds.remove(option);
                  }
                });
              },
            );
          }),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primaryColor,
            title: Text('Otro...(desarrolla)', style: textTheme.bodySmall?.copyWith(fontSize: fontSize, color: AppColors.greyDark)),
            value: _companionHelpNeedsOther,
            onChanged: (checked) {
              setState(() {
                _companionHelpNeedsOther = checked ?? false;
                if (!_companionHelpNeedsOther) _companionHelpNeedsOtherText = null;
              });
            },
          ),
          if (_companionHelpNeedsOther) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _companionHelpNeedsOtherText,
              decoration: inputDecoration.copyWith(
                hintText: 'Describe brevemente...',
                hintStyle: textTheme.bodySmall?.copyWith(color: AppColors.greyLight, fontSize: fontSize),
              ),
              style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
              onSaved: (v) => _companionHelpNeedsOtherText = v,
              onChanged: (v) => _companionHelpNeedsOtherText = v,
            ),
          ],
          SpaceH20(),

          // ── Horario de contacto ───────────────────────────────────────────
          fieldLabel('¿En qué horario prefieres que nos pongamos en contacto contigo?'),
          fieldLabel('Selecciona una o varias...'),
          ...['Mañana', 'Tarde'].map((option) {
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primaryColor,
              title: Text(option, style: textTheme.bodySmall?.copyWith(fontSize: fontSize, color: AppColors.greyDark)),
              value: _companionContactSchedule.contains(option),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _companionContactSchedule.add(option);
                  } else {
                    _companionContactSchedule.remove(option);
                  }
                });
              },
            );
          }),
          SpaceH20(),

          // ── ¿Ayuda de profesional? ───────────────────────────────────────
          fieldLabel('¿Te ha ayudado algún/alguna profesional a rellenar este formulario?'),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _companionProfessionalHelp,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() => _companionProfessionalHelp = v),
              ),
              Text('Sí', style: textTheme.bodySmall?.copyWith(fontSize: 15, color: AppColors.greyDark)),
              const SizedBox(width: 16),
              Radio<bool>(
                value: false,
                groupValue: _companionProfessionalHelp,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() => _companionProfessionalHelp = v),
              ),
              Text('No', style: textTheme.bodySmall?.copyWith(fontSize: 15, color: AppColors.greyDark)),
            ],
          ),
          SpaceH20(),

          // ── Otros datos relevantes ───────────────────────────────────────
          sectionTitle('Otros datos relevantes'),
          fieldLabel('Cualquier dato que consideres importante en tu camino hacia al empleo'),
          TextFormField(
            initialValue: _companionOtherRelevantData,
            minLines: 2,
            maxLines: 5,
            decoration: inputDecoration.copyWith(
              hintText: 'Cuéntanos brevemente cualquier otro dato que consideres importante en tu camino hacia al empleo.',
              hintStyle: textTheme.bodySmall?.copyWith(color: AppColors.greyLight, fontSize: fontSize),
            ),
            style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark, fontSize: fontSize),
            onSaved: (v) => _companionOtherRelevantData = v,
            onChanged: (v) => _companionOtherRelevantData = v,
          ),
        ],
      ),
    );
  }

  Widget _revisionForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: Responsive.isMobile(context) ? null // No image on mobile devices
        : DecorationImage(
          image: AssetImage(ImagePath.LOGO_LINES),
          fit: BoxFit.fitWidth, // Ensures the image covers the entire container
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
              entityName,
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
                checkboxNewsletterForm(context, _checkFieldKeyNewsletter, _isNewsletterChecked, functionNewsletterSetState),
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

  void functionNewsletterSetState(bool? val) {
    setState(() {
      _isNewsletterChecked = val!;
    });
  }

  void _buildCountryStreamBuilder_setState(Country? country) {
    setState(() {
      this.selectedProvince = null;
      this.selectedCity = null;
      this.selectedCountry = country;
      countryName = country != null ? country.name : "";

      if (countryName.toLowerCase() == 'senegal') {
        this.phoneCode = '+221';
      } else if (countryName.toLowerCase() == 'españa') {
        this.phoneCode = '+34';
      } else if (countryName.toLowerCase() == 'perú') {
        this.phoneCode = '+51';
      }
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
      entityName = socialEntity != null ? socialEntity.name : "";
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

  void _buildNationalitySecondStreamBuilder_setState(String? nation) {
    setState(() {
      this.selectedNationalitySecond = nation;
      this._nationalitySecond = nation;
    });
  }

  Widget _buildAddNationalityButton() {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool _hovered = false;
        return StatefulBuilder(
          builder: (context, setHoverState) {
            return MouseRegion(
              onEnter: (_) => setHoverState(() => _hovered = true),
              onExit: (_) => setHoverState(() => _hovered = false),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showSecondNationality = !_showSecondNationality;
                    if (!_showSecondNationality) {
                      selectedNationalitySecond = null;
                      _nationalitySecond = null;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _hovered || _showSecondNationality
                        ? const Color(0xFF18C5C1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF18C5C1),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: _hovered || _showSecondNationality
                        ? Colors.white
                        : const Color(0xFF18C5C1),
                    size: 20,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
    int count = 0;
    int totalItems = selectedValues.length;
    selectedValues.forEach((item) {
      concatenate.write(item.name);
      interestsIds.add(item.interestId);
      if (count != totalItems - 1) {
        concatenate.write(' / ');
      }
      count++;
    });
    setState(() {
      this.interestsNames = concatenate.toString();
      this.textEditingControllerInterests.text = concatenate.toString();
      this.interests = interestsIds;
      this.selectedInterests = selectedValues;
      selectedSpecificInterests.removeWhere((si) => !selectedInterests.any((i) => i.interestId == si.interestId));
      // If only "sin clasificar" is selected, clear specific interests
      if (selectedInterests.isNotEmpty &&
          selectedInterests.every((i) => i.name.trim().toLowerCase() == 'sin clasificar')) {
        selectedSpecificInterests.clear();
        specificInterests.clear();
        specificInterestsNames = '';
        textEditingControllerSpecificInterests.clear();
      }
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

  void getValuesFromKeySpecificInterests(selectedValues) {
    var concatenate = StringBuffer();
    List<String> specificInterestsIds = [];
    int count = 0;
    int totalItems = selectedValues.length;
    selectedValues.forEach((item) {
      concatenate.write(item.name);
      specificInterestsIds.add(item.specificInterestId);
      if (count != totalItems - 1) {
        concatenate.write(' / ');
      }
      count++;
    });
    setState(() {
      this.specificInterestsNames = concatenate.toString();
      this.textEditingControllerSpecificInterests.text = concatenate.toString();
      this.specificInterests = specificInterestsIds;
      this.selectedSpecificInterests = selectedValues;
    });
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
    int count = 0;
    int totalItems = selectedOptions.length;
    selectedOptions.forEach((item) {
      concatenate.write(item.title);
      keepLearningIds.add(item.keepLearningOptionId);
      if (count != totalItems - 1) {
        concatenate.write(' / ');
      }
      count++;
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


  List<CustomStep> getSteps() {
    // IMPORTANT: CustomStepper asserts steps.length never changes between builds.
    // We ALWAYS return exactly 4 steps. The companion step (index 2) is always
    // present but its tab is hidden/invisible when _needsCompanionship != true.
    // Navigation logic in onStepContinue/onStepCancel skips step 2 when unneeded.
    final bool showCompanion = _needsCompanionship == true;

    return [
      CustomStep(
        isActive: currentStep >= 0,
        state: currentStep > 0 ? CustomStepState.complete : CustomStepState.indexed,
        title: Container(
          padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
          decoration: BoxDecoration(
            color: currentStep >= 0 ? AppColors.yellowAlt : AppColors.white,
            borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble * 2),
            border: Border.all(color: AppColors.greyLight, width: 2.0),
          ),
          child: Text(
            StringConst.FORM_GENERAL_INFO,
            style: const TextStyle(color: AppColors.primary900, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        content: _buildForm(context),
      ),
      CustomStep(
        isActive: currentStep >= 1,
        state: currentStep > 1 ? CustomStepState.complete : CustomStepState.disabled,
        title: Container(
          padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
          decoration: BoxDecoration(
            color: currentStep >= 1 ? AppColors.yellowAlt : AppColors.white,
            borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble * 2),
            border: Border.all(color: AppColors.greyLight, width: 2.0),
          ),
          child: Text(
            StringConst.FORM_INTERESTS,
            style: const TextStyle(color: AppColors.primary900, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        content: _buildFormInterests(context),
      ),
      // Step 2: Companion — always present but visually hidden when not needed.
      CustomStep(
        isActive: showCompanion && currentStep >= 2,
        state: showCompanion
            ? (currentStep > 2 ? CustomStepState.complete : CustomStepState.disabled)
            : CustomStepState.disabled,
        title: showCompanion
            ? Container(
                padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                decoration: BoxDecoration(
                  color: currentStep >= 2 ? AppColors.yellowAlt : AppColors.white,
                  borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble * 2),
                  border: Border.all(color: AppColors.greyLight, width: 2.0),
                ),
                child: Text(
                  StringConst.FORM_COMPANION_STEP,
                  style: const TextStyle(color: AppColors.primary900, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              )
            : const SizedBox.shrink(), // Hidden tab when not needed
        content: showCompanion ? _buildFormCompanion(context) : const SizedBox.shrink(),
      ),
      CustomStep(
        isActive: currentStep >= 3,
        state: CustomStepState.disabled,
        title: Container(
          padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
          decoration: BoxDecoration(
            color: currentStep >= 3 ? AppColors.yellowAlt : AppColors.white,
            borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble * 2),
            border: Border.all(color: AppColors.greyLight, width: 2.0),
          ),
          child: Text(
            StringConst.FORM_REVISION,
            style: const TextStyle(color: AppColors.primary900, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        content: _revisionForm(context),
      ),
    ];
  }

  onStepContinue() async {
    // Validate step 0 (general info) — also require companionship answer
    if (currentStep == 0) {
      if (!_validateAndSaveForm()) return;
      if (_needsCompanionship == null) {
        showAlertDialog(
          context,
          title: 'Aviso',
          content: 'Por favor indica si necesitas acompañamiento especializado.',
          defaultActionText: 'Aceptar',
        );
        return;
      }
    }

    if (currentStep == 1 && !_validateAndSaveInterestsForm()) return;

    // Companion step save (step 2, only when visible)
    if (currentStep == 2 && _needsCompanionship == true) {
      final form = _formKeyCompanion.currentState;
      if (form != null) form.save();
    }

    // Step 3 = last step (Revisión)
    final isLastStep = currentStep == 3;
    if (isLastStep) {
      _submit();
      return;
    }

    // Navigate to next step, skipping companion (step 2) when not needed
    final nextStep = (currentStep == 1 && _needsCompanionship != true) ? 3 : currentStep + 1;
    setState(() => this.currentStep = nextStep);
  }

  goToStep(int step) {
    setState(() => this.currentStep = step);
  }

  onStepCancel() {
    if (currentStep <= 0) return;
    // Skip companion step (2) going backwards when not needed
    final prevStep = (currentStep == 3 && _needsCompanionship != true) ? 1 : currentStep - 1;
    goToStep(prevStep);
  }

  Widget _buildCompanionBanner(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double titleFontSize = responsiveSize(context, 20, 26, md: 24);
    double bodyFontSize = responsiveSize(context, 13, 15, md: 14);

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.gre600.withOpacity(0.5), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Image.asset(
                'images/companion_banner_illustration.png',
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                top: 24.0,
                bottom: 24.0,
                right: Responsive.isMobile(context) ? 70.0 : 220.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Te acompañamos en tu camino',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: titleFontSize,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cada persona tiene un camino diferente hacia el empleo. No importa si ya sabes cuál es tu objetivo o si aún estás descubriendo por dónde empezar: en Enreda te acompañamos en ese proceso.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.45,
                      fontSize: bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Te ayudaremos a identificar tus competencias y desarrollar otras nuevas, mejorar tu empleabilidad y acercarte a nuevas oportunidades laborales.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.45,
                      fontSize: bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Al completar este formulario, además de inscribirte en nuestra plataforma y acceder a sus herramientas, podrás recibir información sobre nuestros programas de acompañamiento personalizado para la búsqueda de empleo.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.45,
                      fontSize: bodyFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sendBasicAnalyticsEvent(context, "enreda_app_visit_sign_in_page");
    final isLastStep = currentStep == 3; // always 4 steps, index 3 = Revisión
    final bool isCompanionStep = _needsCompanionship == true && currentStep == 2;
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
              color: Constants.grey,
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
          body: FutureBuilder<void>(
            future: _cacheReadyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(child: CircularProgressIndicator(color: AppColors.primary300));
              }
              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.height
                        : MediaQuery.of(context).size.height * 0.92,
                    maxWidth: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width
                        : MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isCompanionStep) _buildCompanionBanner(context),
                      Expanded(
                        child: RoundedContainer(
                          color: AppColors.grey80,
                          borderColor: Responsive.isMobile(context) ? Colors.transparent : AppColors.gre600,
                          margin: EdgeInsets.zero,
                          contentPadding: Responsive.isMobile(context)
                              ? const EdgeInsets.all(12)
                              : const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isCompanionStep) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Text(
                                    'Necesitamos alguna información básica para asesorarte mejor en tu camino hacia el empleo.\nRellena solo los campos que apliquen a tu situación.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.greyDark,
                                      height: 1.4,
                                      fontSize: responsiveSize(context, 13, 15, md: 14),
                                    ),
                                  ),
                                ),
                                const Divider(
                                  color: AppColors.greyUltraLight,
                                  thickness: 1.0,
                                  height: 24.0,
                                ),
                                const SizedBox(height: 8.0),
                              ],
                              Row(
                                children: [
                                  isCompanionStep
                                      ? Text(
                                          'Solicitud de acompañamiento',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: responsiveSize(context, 18, 22, md: 20),
                                          ),
                                        )
                                      : CustomTextMedium(text: StringConst.FORM_CREATE_PROFILE),
                                  const Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: (Responsive.isMobile(context) || Responsive.isTablet(context)) ? 30.0 : 0.0,
                                    ),
                                    child: SizedBox(
                                      width: 34,
                                      child: PillTooltip(
                                        title: StringConst.PILL_TRAVEL_BEGINS,
                                        pillId: TrainingPill.TRAVEL_BEGINS_ID,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              Expanded(
                                child: CustomStepper(
                                  elevation: 0.0,
                                  type: Responsive.isMobile(context) ? CustomStepperType.vertical : CustomStepperType.horizontal,
                                  steps: getSteps(),
                                  currentStep: currentStep,
                                  onStepContinue: onStepContinue,
                                  onStepTapped: (step) {
                                    if (step == 2 && _needsCompanionship != true) return;
                                    goToStep(step);
                                  },
                                  onStepCancel: onStepCancel,
                                  controlsBuilder: (context, _) {
                                    return Container(
                                      height: Borders.kDefaultPaddingDouble * 2,
                                      margin: EdgeInsets.only(top: Borders.kDefaultPaddingDouble * 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          if (currentStep != 0)
                                            EnredaButton(
                                              buttonTitle: StringConst.FORM_BACK,
                                              width: contactBtnWidth,
                                              onPressed: onStepCancel,
                                            ),
                                          SizedBox(width: Borders.kDefaultPaddingDouble),
                                          isLoading
                                              ? Center(child: CircularProgressIndicator(color: AppColors.primary300))
                                              : EnredaButton(
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
      ),
    );
  }
}