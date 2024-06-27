// import 'package:chips_choice/chips_choice.dart';
// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:email_validator/email_validator.dart';
// import 'package:enreda_app/app/home/models/addressUser.dart';
// import 'package:enreda_app/app/home/models/city.dart';
// import 'package:enreda_app/app/home/models/contact.dart';
// import 'package:enreda_app/app/home/models/country.dart';
// import 'package:enreda_app/app/home/models/education.dart';
// import 'package:enreda_app/app/home/models/interest.dart';
// import 'package:enreda_app/app/home/models/province.dart';
// import 'package:enreda_app/app/home/models/socialEntity.dart';
// import 'package:enreda_app/app/home/models/userEnreda.dart';
// import 'package:enreda_app/app/home/web_home.dart';
// import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_city.dart';
// import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_country.dart';
// import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_education.dart';
// import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_gender.dart';
// import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_nation.dart';
// import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_province.dart';
// import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_social_entity.dart';
// import 'package:enreda_app/common_widgets/custom_chip.dart';
// import 'package:enreda_app/common_widgets/custom_date_picker_title.dart';
// import 'package:enreda_app/common_widgets/custom_text.dart';
// import 'package:enreda_app/common_widgets/custom_text_form_field_title.dart';
// import 'package:enreda_app/common_widgets/rounded_container.dart';
// import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
// import 'package:enreda_app/common_widgets/show_exception_alert_dialog.dart';
// import 'package:enreda_app/common_widgets/spaces.dart';
// import 'package:enreda_app/services/auth.dart';
// import 'package:enreda_app/services/database.dart';
// import 'package:enreda_app/utils/const.dart';
// import 'package:enreda_app/utils/functions.dart';
// import 'package:enreda_app/utils/responsive.dart';
// import 'package:enreda_app/values/strings.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../common_widgets/custom_raised_button.dart';
// import '../../../common_widgets/flex_row_column.dart';
// import '../../../utils/adaptive.dart';
// import '../../../values/values.dart';
//
// class PersonalData extends StatefulWidget {
//   const PersonalData({Key? key}) : super(key: key);
//
//   @override
//   State<PersonalData> createState() => _PersonalDataState();
// }
//
// class _PersonalDataState extends State<PersonalData> {
//   final _formKey = GlobalKey<FormState>();
//   String _userId = '';
//   String? _email = '';
//   String _firstName = '';
//   String _lastName = '';
//   String _phone = '';
//   String? _gender;
//   DateTime? _birthday;
//   String _postalCode = '';
//   String _role = '';
//   String _unemployedType = '';
//   List<String> _abilities = [];
//   List<Country> _countries = [Country(name: 'España')];
//   List<Province> _provinces = [Province(name: 'Las Palmas', countryId: '')];
//   List<City> _cities = [
//     City(name: 'Las Palmas de Gran Canaria', countryId: '', provinceId: '')
//   ];
//   String _countrySelected = '';
//   String _provinceSelected = '';
//   Set<Interest> _interests = Set.from([]);
//   List<String> _interestsSelected = [];
//   List<String> _specificInterest = [];
//   String codeDialog = '';
//   String valueText = '';
//   String _phoneCode = '+34';
//   late String _formattedBirthdayDate;
//   TextEditingController textEditingControllerDateInput = TextEditingController();
//   String? _nationality;
//   String writtenEmail = '';
//   int? isRegistered;
//   Country? _country;
//   Province? _province;
//   City? _city;
//   Education? _education;
//   SocialEntity? _socialEntity;
//   String? _assignedEntityId;
//   TextEditingController _textFieldController = TextEditingController();
//
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//    context.dependOnInheritedWidgetOfExactType();
//   }
//
//   void setStateIfMounted(f) {
//     if (mounted) setState(f);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthBase>(context, listen: false);
//     final database = Provider.of<Database>(context, listen: false);
//
//     return StreamBuilder<User?>(
//         stream: Provider.of<AuthBase>(context).authStateChanges(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return Container();
//           if (snapshot.hasData) {
//             return StreamBuilder<List<Interest>>(
//                 stream: database.interestStream(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     snapshot.data!.forEach((interest) {
//                       if (!_interests.any((element) =>
//                           element.interestId == interest.interestId)) {
//                         _interests.add(interest);
//                       }
//                     });
//                   }
//                   return StreamBuilder<List<UserEnreda>>(
//                     stream: database.userStream(auth.currentUser!.email),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) return Container();
//                       if (snapshot.hasData) {
//                         final userEnreda = snapshot.data![0];
//                         _userId = userEnreda.userId ?? '';
//                         _email = userEnreda.email;
//                         _firstName = userEnreda.firstName ?? '';
//                         _lastName = userEnreda.lastName ?? '';
//                         _role = userEnreda.role ?? '';
//                         _abilities = userEnreda.abilities ?? [];
//                         _unemployedType = userEnreda.unemployedType ?? '';
//                         if (_phone.isEmpty) _phone = userEnreda.phone ?? '';
//                         _phoneCode =
//                             '${userEnreda.phone?[0]}${userEnreda.phone?[1]}${userEnreda.phone?[2]}';
//                         _gender = userEnreda.gender ?? '';
//                         _birthday =
//                             _birthday == null ? userEnreda.birthday : _birthday;
//                         _postalCode = userEnreda.address?.postalCode ?? '';
//                         _specificInterest = userEnreda.specificInterests;
//                         _assignedEntityId = userEnreda.assignedEntityId ?? '';
//                         if (_interestsSelected.isEmpty) {
//                           _interestsSelected = userEnreda.interests;
//                           List<String> interestSelectedName = [];
//                           _interests
//                               .where((interest) => _interestsSelected.any(
//                                   (interestId) =>
//                                       interestId == interest.interestId))
//                               .forEach((interest) {
//                             interestSelectedName.add(interest.name);
//                           });
//                           _interestsSelected.clear();
//                           _interestsSelected.addAll(interestSelectedName);
//                           _birthday != null ?
//                             _formattedBirthdayDate = DateFormat('dd-MM-yyyy').format(_birthday!) :
//                             _formattedBirthdayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
//                           _birthday != null ?
//                             textEditingControllerDateInput.text = _formattedBirthdayDate :
//                             textEditingControllerDateInput.text = '';
//                           _nationality = userEnreda.nationality;
//                         }
//                         return StreamBuilder<List<Country>>(
//                             stream: database.countryFormatedStream(),
//                             builder: (context, snapshot) {
//                               _countries = snapshot.hasData ? snapshot.data! : [];
//                               if (_countrySelected == '') {
//                                 _countrySelected =
//                                     userEnreda.address?.country ?? '';
//                               }
//                               _country = _countries.firstWhere((country) =>
//                                   country.countryId == _countrySelected,
//                                       orElse: () => Country(name: ''));
//                               return StreamBuilder<List<Province>>(
//                                   stream: database
//                                       .provincesCountryStream(_countrySelected),
//                                   builder: (context, snapshot) {
//                                     _provinces = snapshot.hasData
//                                         ? snapshot.data!
//                                             .where((province) =>
//                                                 province.countryId ==
//                                                 _countrySelected)
//                                             .toList()
//                                         : [];
//                                     if (_provinceSelected == '') {
//                                       _provinceSelected =
//                                           userEnreda.address?.province ?? '';
//                                     }
//                                     try {
//                                       _province = _provinces.isNotEmpty
//                                           ? _provinces
//                                               .firstWhere((province) =>
//                                                   province.provinceId ==
//                                                   _provinceSelected)
//                                           : Province(name: '', countryId: '');
//                                     } catch (e) {
//                                       _province = _provinces[0];
//                                       _provinceSelected =
//                                           _provinces[0].provinceId ?? '';
//                                     }
//                                     return StreamBuilder<List<City>>(
//                                         stream: database.citiesProvinceStream(
//                                             _provinceSelected),
//                                         builder: (context, snapshot) {
//                                           _cities = snapshot.hasData
//                                               ? snapshot.data!
//                                                   .where((city) =>
//                                                       city.provinceId ==
//                                                       _provinceSelected)
//                                                   .toList()
//                                               : [];
//                                           try {
//                                             _city = _cities.isNotEmpty
//                                                 ? _cities
//                                                     .firstWhere((city) =>
//                                                         city.cityId ==
//                                                         userEnreda.city)
//                                                 : City(name: '', countryId: '', provinceId: '');
//                                           } catch (e) {
//                                             _city = _cities[0];
//                                           }
//                                           return StreamBuilder<List<Education>>(
//                                             stream: database.educationStream(),
//                                             builder: (context, snapshot) {
//                                               List<Education> educations = snapshot.hasData ? snapshot.data! : [];
//                                               if (educations != [] && userEnreda.educationId != null) {
//                                                 _education = educations.firstWhere((education) =>
//                                                     education.educationId == userEnreda.educationId,
//                                                     orElse: () => Education(order: 0, label: '', value: '', educationId: ''));
//                                                 if(_assignedEntityId != null && _assignedEntityId != '' )  {
//                                                   return StreamBuilder<SocialEntity>(
//                                                       stream: database.socialEntityStream(_assignedEntityId!),
//                                                       builder: (context, snapshot) {
//                                                         if(snapshot.hasData){
//                                                           _socialEntity = snapshot.data;
//                                                           return Responsive.isDesktop(context)
//                                                               ? _buildMainDataContainer(context, userEnreda)
//                                                               : _buildMainDataContainer(context, userEnreda);
//                                                         }
//                                                         return Container();
//                                                       }
//                                                   );
//                                                 }
//                                               }
//                                               return Responsive.isDesktop(context)
//                                                   ? _buildMainDataContainer(context, userEnreda)
//                                                   : _buildMainDataContainer(context, userEnreda);
//                                             }
//                                           );
//                                         });
//                                   });
//                             });
//                       } else {
//                         return Center(child: CircularProgressIndicator());
//                       }
//                     },
//                   );
//                 });
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         });
//   }
//
//   Widget _buildSaveDataButton(BuildContext context, UserEnreda userEnreda) {
//     return CustomButton(
//       text: StringConst.UPDATE_DATA,
//       color: Constants.turquoise,
//       onPressed: () => _submit(userEnreda),
//     );
//   }
//


//
//   Widget _buildInterestsContainer(BuildContext context) {
//
//     return Padding(
//       padding: const EdgeInsets.all(30.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             StringConst.FORM_INTERESTS,
//             style: TextStyle(
//               fontFamily: GoogleFonts.outfit().fontFamily,
//                 fontWeight: FontWeight.w300,
//                 color: AppColors.bluePetrol,
//                 fontSize: 24.0),
//           ),
//           SpaceH20(),
//           _interests.isNotEmpty
//               ? Container(
//                   alignment: Alignment.centerLeft,
//                   child: ChipsChoice<String>.multiple(
//                     padding: EdgeInsets.all(0.0),
//                     value: _interestsSelected,
//                     onChanged: (val) {
//                       if (val.isEmpty) {
//                         showAlertDialog(
//                           context,
//                           title: StringConst.FORM_INTERESTS,
//                           content: StringConst.FORM_SELECT_AT_LEAST_ONE,
//                           defaultActionText: StringConst.OK,
//                         );
//                       } else {
//                         setState(() => _interestsSelected = val);
//                       }
//                     },
//                     choiceItems: C2Choice.listFrom<String, String>(
//                       source: _interests.map((e) => e.name).toList(),
//                       value: (i, v) => v,
//                       label: (i, v) => v,
//                       tooltip: (i, v) => v,
//                     ),
//                     choiceBuilder: (item, i) => CustomChip(
//                       label: item.label,
//                       selected: item.selected,
//                       onSelect: item.select!,
//                     ),
//                     wrapped: true,
//                     runSpacing: 8,
//                     choiceCheckmark: false,
//                   ),
//                 )
//               : Container(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildForm(BuildContext context, UserEnreda userEnreda) {
//     final database = Provider.of<Database>(context, listen: false);
//     final textTheme = Theme.of(context).textTheme;
//     double fontSize = responsiveSize(context, 14, 16, md: 15);
//     return
//       Form(
//         key: _formKey,
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget> [
//               CustomFlexRowColumn(
//                 contentPadding: EdgeInsets.all(0.0),
//                 separatorSize: Sizes.kDefaultPaddingDouble,
//                 childLeft: CustomTextFormFieldTitle(
//                     labelText: StringConst.FORM_NAME,
//                     initialValue: _firstName,
//                     validator: (value) =>
//                     value!.isNotEmpty ? null : StringConst.NAME_ERROR,
//                     onSaved: (value){
//                       setState(() {
//                         _firstName = value!;
//                       });
//                     }
//                 ),
//                 childRight: CustomTextFormFieldTitle(
//                     labelText: StringConst.FORM_LASTNAME,
//                     initialValue: _lastName,
//                     validator: (value) =>
//                     value!.isNotEmpty ? null : StringConst.FORM_LASTNAME_ERROR,
//                     onSaved: (value){
//                       setState(() {
//                         _lastName = value!;
//                       });
//                     }
//                 ),
//               ),
//               SpaceH20(),
//               CustomFlexRowColumn(
//                 contentPadding: EdgeInsets.all(0.0),
//                 separatorSize: Sizes.kDefaultPaddingDouble,
//                 childLeft: CustomDatePickerTitle(
//                   labelText: StringConst.FORM_BIRTHDAY,
//                   initialValue: _birthday,
//                   onChanged: (value){//pickedDate output format => 2021-03-10 00:00:00.000
//                     _formattedBirthdayDate = DateFormat('dd-MM-yyyy').format(value!);
//                     print(_formattedBirthdayDate); //formatted date output using intl package =>  2021-03-16
//                     setState(() {
//                       textEditingControllerDateInput.text = _formattedBirthdayDate; //set output date to TextField value.
//                       _birthday = value;
//                     });
//                   },
//                   validator: (value) => value != null ? null : StringConst.FORM_BIRTHDAY_ERROR,
//                 ),
//                 childRight: streamBuilder_Dropdown_Genders(context, null, (value){
//                   setState(() {
//                     _gender = value.name;
//                   });
//                 }, _gender),
//               ),
//               SpaceH20(),
//               CustomFlexRowColumn(
//                   contentPadding: EdgeInsets.all(0.0),
//                   separatorSize: Sizes.kDefaultPaddingDouble,
//                   childLeft: streamBuilderForNation(context, _nationality,  (value){
//                     setState(() {
//                       _nationality = value;
//                     });
//                   }, StringConst.FORM_CURRENT_NATIONALITY),
//                   childRight: Container()),
//               SpaceH20(),
//               CustomFlexRowColumn(
//                 contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: Sizes.kDefaultPaddingDouble / 2),
//                 childLeft: StreamBuilder <List<UserEnreda>>(
//                     stream:
//                     // Empty stream (no call to firestore) if email not valid
//                     !EmailValidator.validate(writtenEmail)
//                         ? Stream<List<UserEnreda>>.empty()
//                         : database.checkIfUserEmailRegistered(writtenEmail),
//                     builder:  (context, snapshotUsers) {
//
//                       var usersListLength = snapshotUsers.data != null ? snapshotUsers.data?.length : 0;
//                       isRegistered = usersListLength! > 0 ? 1 : 0;
//
//                       final validationMessage = (value) => EmailValidator.validate(value!)
//                           ? (isRegistered == 0 ? null : StringConst.EMAIL_REGISTERED)
//                           : StringConst.EMAIL_ERROR;
//
//                       return Padding(
//                         padding: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? const EdgeInsets.only(right: 0, bottom: Sizes.kDefaultPaddingDouble )
//                             : const EdgeInsets.only(right: Sizes.kDefaultPaddingDouble / 2, bottom: Sizes.kDefaultPaddingDouble),
//                         child: CustomTextFormFieldTitle(
//                           textColor: AppColors.primaryText1,
//                           enabled: false,
//                           labelText: StringConst.FORM_EMAIL,
//                           initialValue: _email,
//                           validator: validationMessage,
//                           onSaved: (value) => _email = value,
//                           keyboardType: TextInputType.emailAddress,
//                           onChanged: (value) => setState(() => this.writtenEmail = value),
//                         ),
//                       );
//                     }
//                 ),
//                 childRight: Padding(
//                   padding: Responsive.isMobile(context) ? EdgeInsets.zero : Responsive.isTablet(context) ?
//                   EdgeInsets.only(left: Sizes.kDefaultPaddingDouble) : EdgeInsets.only(left: Sizes.kDefaultPaddingDouble / 2),
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       labelText: StringConst.FORM_PHONE,
//                       prefixIcon: CountryCodePicker(
//                         onChanged: _onCountryChange,
//                         dialogSize: Size(350.0, MediaQuery.of(context).size.height * 0.6),
//                         initialSelection: _phoneCode == '+34'
//                             ? 'ES'
//                             : _phoneCode == '+51'
//                             ? 'PE'
//                             : 'GT',
//                         //countryFilter: const ['ES', 'PE', 'GT'],
//                         showFlagDialog: true,
//                       ),
//                       focusColor: AppColors.primary400,
//                       labelStyle: textTheme.bodySmall?.copyWith(
//                         height: 1.5,
//                         color: AppColors.greyDark,
//                         fontWeight: FontWeight.w400,
//                         fontSize: fontSize,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                         borderSide: const BorderSide(
//                           color: AppColors.greyUltraLight,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                         borderSide: const BorderSide(
//                           color: AppColors.greyUltraLight,
//                           width: 1.0,
//                         ),
//                       ),
//                     ),
//                     initialValue: _phone.indexOf(' ') < 0 && _phone.length > 3
//                         ? _phone.substring(3)
//                         : _phone.substring(_phone.indexOf(' ') + 1),
//                     validator: (value) =>
//                     value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
//                     onSaved: (value) => this._phone = _phoneCode + ' ' + value!,
//                     textCapitalization: TextCapitalization.sentences,
//                     keyboardType: TextInputType.phone,
//                     style: textTheme.bodySmall?.copyWith(
//                       height: 1.5,
//                       color: AppColors.greyDark,
//                       fontWeight: FontWeight.w400,
//                       fontSize: fontSize,
//                     ),
//                     inputFormatters: <TextInputFormatter>[
//                       FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
//                     ],
//                   ),
//                 ),
//               ),
//               SpaceH20(),
//               CustomFlexRowColumn(
//                 contentPadding: EdgeInsets.all(0.0),
//                 separatorSize: Sizes.kDefaultPaddingDouble,
//                 childLeft: streamBuilderForCountry(context, _country, (value){
//                   setState(() {
//                     _country = value;
//                   });
//                 }, userEnreda, StringConst.FORM_CURRENT_COUNTRY),
//                 childRight: streamBuilderForProvince(context, _country, _province, (value){
//                   setState(() {
//                     _province = value;
//                   });
//                 }),
//               ),
//               SpaceH20(),
//               CustomFlexRowColumn(
//                 contentPadding: EdgeInsets.all(0.0),
//                 separatorSize: Sizes.kDefaultPaddingDouble,
//                 childLeft: streamBuilderForCity(context, _country, _province, _city, (value){
//                   setState(() {
//                     _city = value;
//                   });
//                 }),
//                 //childLeft: Container(),
//                 childRight: CustomTextFormFieldTitle(
//                     labelText: StringConst.FORM_POSTAL_CODE,
//                     initialValue: _postalCode,
//                     /*validator: (value) =>
//                       value!.isNotEmpty ? null : StringConst.POSTAL_CODE_ERROR,*/
//                     onSaved: (value){
//                       _postalCode = value!;
//                     }
//                 ),
//               ),
//               SpaceH20(),
//               streamBuilderDropdownEducation(context, _education, (value){
//                 setState(() {
//                   _education = value;
//                 });
//               }),
//               SpaceH20(),
//               //if(_assignedEntityId != null && _assignedEntityId != "")
//               streamBuilderForSocialEntity(context, _socialEntity, (value){
//                 setState(() {
//                   _socialEntity = value;
//                 });
//               }),
//
//             ]),
//       );
//   }
//
//   void _onCountryChange(CountryCode countryCode) {
//     this._phoneCode = countryCode.toString();
//   }
//
//   Widget _buildFormField(
//       {required BuildContext context,
//       required String title,
//       required Widget child,
//       Widget? prefix}) {
//     final textTheme = Theme.of(context).textTheme;
//     double fontSize = responsiveSize(context, 14, 16, md: 15);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             if (prefix != null) prefix,
//             Text(
//               title,
//               style: textTheme.bodySmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: Constants.chatDarkGray,
//                 fontSize: fontSize,
//               ),
//             ),
//           ],
//         ),
//         SpaceH8(),
//         child,
//         SpaceH12(),
//       ],
//     );
//   }
//
//   Future<void> _submit(UserEnreda userEnreda) async {
//     if (_validateAndSaveForm()) {
//       List<String> interestsSelectedId = [];
//       _interests
//           .where((interest) => _interestsSelected
//               .any((interestName) => interest.name == interestName))
//           .forEach((interest) {
//         interestsSelectedId.add(interest.interestId!);
//       });
//
//       final updatedUserEnreda = userEnreda.copyWith(
//         userId: _userId,
//         firstName: _firstName,
//         lastName: _lastName,
//         email: _email,
//         phone: _phone,
//         gender: _gender,
//         interests: interestsSelectedId,
//         specificInterests: _specificInterest,
//         address: Address(
//             country: _country!.countryId,
//             province: _province!.provinceId,
//             city: _city!.cityId,
//             postalCode: _postalCode),
//         birthday: _birthday,
//         role: _role,
//         abilities: _abilities,
//         unemployedType: _unemployedType,
//         educationId: _education?.educationId ?? '',
//         nationality: _nationality,
//         assignedEntityId: _socialEntity?.socialEntityId ?? '',
//       );
//       try {
//         final database = Provider.of<Database>(context, listen: false);
//         await database.setUserEnreda(updatedUserEnreda);
//         showAlertDialog(
//           context,
//           title: StringConst.UPDATED_DATA_TITLE,
//           content: StringConst.UPDATED_DATA,
//           defaultActionText: StringConst.OK,
//         );
//       } on FirebaseException catch (e) {
//         showExceptionAlertDialog(context,
//             title: StringConst.UPDATE_DATA_ERROR, exception: e);
//       }
//     }
//   }
//
//   bool _validateAndSaveForm() {
//     final form = _formKey.currentState;
//     if (form != null && form.validate()) {
//       form.save();
//       return true;
//     }
//
//     return false;
//   }
//
//
//   Future<void> _confirmSignOut(BuildContext context) async {
//     final didRequestSignOut = await showAlertDialog(context,
//         title: StringConst.SIGN_OUT,
//         content: StringConst.SIGN_OUT_DESCRIPTION,
//         cancelActionText: StringConst.CANCEL,
//         defaultActionText: StringConst.CLOSE);
//     if (didRequestSignOut == true) {
//       final auth = Provider.of<AuthBase>(context, listen: false);
//       await auth.signOut();
//     }
//   }
// }
//



import 'package:chips_choice/chips_choice.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:enreda_app/app/home/models/addressUser.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/contact.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/gender.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_city.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_country.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_education.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_gender.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_nation.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_province.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/stream_builder_social_entity.dart';
import 'package:enreda_app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/flex_row_column.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../common_widgets/spaces.dart';
import '../../../common_widgets/custom_chip.dart';
import '../../../common_widgets/custom_date_picker.dart';
import '../../../common_widgets/custom_text.dart';
import '../models/interest.dart';


class PersonalDataForm extends StatefulWidget {
  const PersonalDataForm({Key? key,
    required this.user,
    required this.interestsSet,
    required this.userInterestsSelectedName,
  }) : super(key: key);
  final UserEnreda user;
  final Set<Interest> interestsSet;
  final List<String> userInterestsSelectedName;

  @override
  State<PersonalDataForm> createState() => _PersonalDataFormState();
}

class _PersonalDataFormState extends State<PersonalDataForm> {
  late UserEnreda user;
  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _country;
  String? _province;
  String? _city;
  String? _postalCode;
  String? _phone;
  String? _education;
  String? _socialEntity;
  String? _gender;
  bool isLoading = false;
  String _email = '';
  String _nationality = '';
  String valueText = '';
  String codeDialog = '';
  String _phoneCode = '+34';
  DateTime? _birthday;
  Country? selectedCountry;
  Province? selectedProvince;
  City? selectedCity;
  Gender? selectedGender;
  String? selectedNation;
  Education? selectedEducation;
  SocialEntity? selectedSocialEntity;
  Set<Interest> _interests = Set.from([]);
  List<String> specificInterests = [];
  List<String> _selectedInterestsNameList = [];
  Set<SpecificInterest> selectedSpecificInterestsSet = {};
  bool? profileDataChanged;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _userId = user.userId;
    _email = user.email;
    _gender = user.gender ?? '';
    _firstName = user.firstName ?? '';
    _lastName = user.lastName ?? '';
    _country = user.country ?? '';
    _province = user.province ?? '';
    _city = user.city ?? '';
    _postalCode = user.postalCode ?? '';
    _nationality = user.nationality ?? '';
    _education = user.educationId ?? '';
    _socialEntity = user.assignedEntityId ?? '';
    _birthday = user.birthday ?? null;
    _phone = user.phone ?? '';
    _phoneCode = '${user.phone?[0]}${user.phone?[1]}${user.phone?[2]}';
    _interests = widget.interestsSet;
    _selectedInterestsNameList = widget.userInterestsSelectedName;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   context.dependOnInheritedWidgetOfExactType();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainDataContainer(context, user);
  }

    Widget _buildMainDataContainer(BuildContext context, UserEnreda userEnreda) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return RoundedContainer(
      margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
       const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      contentPadding: Responsive.isMobile(context) ?
        EdgeInsets.symmetric(horizontal: Sizes.mainPadding) :
        EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isSmallScreen ? InkWell(
                onTap: () {
                  setStateIfMounted(() {
                    WebHome.controller.selectIndex(0);});
                },
                child: Row(
                  children: [
                    Image.asset(ImagePath.ARROW_B, height: 30),
                    Spacer(),
                    CustomTextMediumBold(text: StringConst.PERSONAL_DATA),
                    Spacer(),
                    SizedBox(width: 30),
                  ],
                )) : CustomTextMediumBold(text: StringConst.PERSONAL_DATA),
            Container(
              margin: EdgeInsets.only(top: Sizes.kDefaultPaddingDouble),
              padding: EdgeInsets.symmetric(vertical: Sizes.kDefaultPaddingDouble),
              decoration: BoxDecoration(
                border: Border.all(color: Constants.lightGray, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: _buildForm(context, userEnreda),
                    ),
                    _buildInterestsContainer(context),
                    _buildSaveDataButton(
                        context,
                        userEnreda),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: _buildMyParameters(context, userEnreda),
            ),
            Responsive.isMobile(context) ? SpaceH50() : Container(),
          ],
        ),
      ),
    );
  }


  Widget _buildSaveDataButton(BuildContext context, UserEnreda user) {
    return isLoading
        ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ))
        : EnredaButton(
      buttonTitle: StringConst.UPDATE_DATA,
      onPressed: () => _submit(user),
    );
  }

  Widget _buildForm(BuildContext context, UserEnreda user) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
              child: Column(
                children: [
                  CustomFlexRowColumn(
                    childLeft: CustomTextFormFieldTitle(
                      labelText: StringConst.FORM_NAME,
                      initialValue: _firstName,
                      onSaved: nameSetState,
                    ),
                    childRight: CustomTextFormFieldTitle(
                      labelText: StringConst.FORM_LASTNAME,
                      initialValue: _lastName,
                      onSaved: lastNameSetState,
                    ),
                  ),
                  CustomFlexRowColumn(
                    childLeft: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container()
                        ),
                        CustomTextFormFieldTitle(
                          labelText: StringConst.FORM_EMAIL,
                          initialValue: _email,
                          onSaved: emailSetState,
                          enabled: false,
                        ),
                      ],
                    ),
                    childRight: streamBuilder_Dropdown_Genders(context, selectedGender,
                        genderSetState, _gender),
                  ),
                  CustomFlexRowColumn(
                    childLeft: TextFormField(
                      decoration: InputDecoration(
                        labelText: StringConst.FORM_PHONE,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: CountryCodePicker(
                          dialogSize: Size(350.0, MediaQuery.of(context).size.height * 0.6),
                          onChanged: _onCountryChange,
                          initialSelection: _phoneCode == '+34'
                              ? 'ES'
                              : _phoneCode == '+51'
                              ? 'PE'
                              : 'GT',
                          showFlagDialog: true,
                        ),
                        focusColor: AppColors.primaryColor,
                        labelStyle: textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: AppColors.greyDark,
                          fontWeight: FontWeight.w400,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: AppColors.greyUltraLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: AppColors.greyUltraLight,
                            width: 1.0,
                          ),
                        ),
                      ),
                      initialValue: _phone!.indexOf(' ') < 0 && _phone!.length > 3
                          ? _phone!.substring(3)
                          : _phone!.substring(_phone!.indexOf(' ') + 1),
                      validator: (value) =>
                      value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
                      onSaved: (value) => this._phone = _phoneCode + ' ' + value!,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.phone,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppColors.greyDark,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                    childRight: customDatePicker(context, _birthday,
                        StringConst.FORM_BIRTHDAY,
                        StringConst.FORM_BIRTHDAY_ERROR,
                        dateSetState),
                  ),
                  CustomFlexRowColumn(
                    childLeft: streamBuilderForCountry(context, selectedCountry,
                        buildCountryStreamBuilderSetState, user, StringConst.FORM_CURRENT_COUNTRY),
                    childRight: streamBuilderForProvince(
                        context,
                        selectedCountry == null ? _country : selectedCountry?.countryId,
                        selectedProvince,
                        buildProvinceStreamBuilderSetState, user),
                  ),
                  CustomFlexRowColumn(
                    childLeft: streamBuilderForCity(
                      context,
                      selectedProvince == null && selectedCountry == null ? _province : selectedProvince?.provinceId,
                      selectedCity,
                      buildCityStreamBuilderSetState, user),
                    childRight: CustomTextFormFieldTitle(
                        labelText: StringConst.FORM_POSTAL_CODE,
                        initialValue: _postalCode,
                        onSaved: postalCodeSetState,
                    ),
                  ),
                  CustomFlexRowColumn(
                    childLeft: streamBuilderForNation(context, selectedNation,
                        nationalitySetState, StringConst.FORM_CURRENT_NATIONALITY, _nationality),
                    childRight: Container(),
                  ),
                  CustomFlexRowColumn(
                    childLeft: streamBuilderDropdownEducation(context, selectedEducation,
                        educationSetState, user, StringConst.FORM_EDUCATION),
                    childRight: streamBuilderForSocialEntity(context, selectedSocialEntity,
                        socialEntityStreamBuilderSetState, user, StringConst.FORM_SOCIAL_ENTITY),
                  ),
                  SpaceH20(),
                ],),
            ),
          ]),
    );
  }

  Widget _buildInterestsContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.FORM_INTERESTS,
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
                fontWeight: FontWeight.w300,
                color: AppColors.bluePetrol,
                fontSize: 24.0),
          ),
          SpaceH20(),
          _interests.isNotEmpty
              ? Container(
                  alignment: Alignment.centerLeft,
                  child: ChipsChoice<String>.multiple(
                    padding: EdgeInsets.all(0.0),
                    value: _selectedInterestsNameList,
                    onChanged: (val) {
                      if (val.isEmpty) {
                        showAlertDialog(
                          context,
                          title: StringConst.FORM_INTERESTS,
                          content: StringConst.FORM_SELECT_AT_LEAST_ONE,
                          defaultActionText: StringConst.OK,
                        );
                      } else {
                        setState(() => _selectedInterestsNameList = val);
                      }
                    },
                    choiceItems: C2Choice.listFrom<String, String>(
                      source: _interests.map((e) => e.name).toList(),
                      value: (i, v) => v,
                      label: (i, v) => v,
                      tooltip: (i, v) => v,
                    ),
                    choiceBuilder: (item, i) => CustomChip(
                      label: item.label,
                      selected: item.selected,
                      onSelect: item.select!,
                    ),
                    wrapped: true,
                    runSpacing: 8,
                    choiceCheckmark: false,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Future<void> _submit(UserEnreda user) async {

    if (_validateAndSaveForm()) {

      List<String> interestsSelectedIds = [];
      _interests
          .where((interest) => _selectedInterestsNameList
              .any((interestName) => interest.name == interestName))
          .forEach((interest) {
        interestsSelectedIds.add(interest.interestId!);
      });
      final updatedUser = user.copyWith(
        userId: _userId,
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        phone: _phone,
        gender: _gender,
        interests: interestsSelectedIds,
        address: Address(
            country: _country!,
            province: _province!,
            city: _city!,
            postalCode: _postalCode
        ),
        birthday: _birthday,
        educationId: _education,
        nationality: _nationality,
        assignedEntityId: _socialEntity,
      );

      try {
        final database = Provider.of<Database>(context, listen: false);
        setState(() => isLoading = true);
        await database.setUserEnreda(updatedUser);
        setState(() => isLoading = false);
        showAlertDialog(
          context,
          title: StringConst.UPDATED_DATA_TITLE,
          content: StringConst.UPDATED_DATA,
          defaultActionText: StringConst.OK,
        );
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: StringConst.UPDATE_DATA_ERROR, exception: e);
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

  void nameSetState(String? val) {
    setState(() {
      _firstName = val!;
    });
  }

  void lastNameSetState(String? val) {
    setState(() {
      _lastName = val!;
    });
  }

  void emailSetState(String? val) {
    setState(() {
      _email = val!;
    });
  }

  void postalCodeSetState(String? val) {
    setState(() {
      _postalCode = val!;
    });
  }

  void genderSetState(Gender? gender) {
    setState(() {
      selectedGender = gender!;
    });
    _gender = gender?.name;
  }

  void dateSetState(DateTime? val) {
    setState(() {
      _birthday = val!;
    });
  }

  void nationalitySetState(String? nationalityName) {
    setState(() {
      _nationality = nationalityName!;
    });
  }

  void educationSetState(Education? education) {
    setState(() {
      selectedEducation = education!;
    });
    _education = education?.educationId;
  }

  void socialEntityStreamBuilderSetState(SocialEntity? socialEntity) {
    setState(() {
      selectedSocialEntity = socialEntity!;
    });
    _socialEntity = socialEntity?.socialEntityId;
  }

  void buildCountryStreamBuilderSetState(Country? country) {
    setState(() {
      selectedProvince = null;
      selectedCity = null;
      selectedCountry = country;
    });
    _country = country?.countryId;
  }

  void buildProvinceStreamBuilderSetState(Province? province) {
    setState(() {
      selectedCity = null;
      selectedProvince = province;
    });
    _province = province?.provinceId;
  }

  void buildCityStreamBuilderSetState(City? city) {
    setState(() {
      selectedCity = city;
    });
    _city = city?.cityId;
  }

  void _onCountryChange(CountryCode countryCode) {
    _phoneCode = countryCode.toString();
  }

  Widget _buildMyParameters(BuildContext context, UserEnreda userEnreda) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
        padding: EdgeInsets.symmetric(vertical: Sizes.kDefaultPaddingDouble, horizontal: Sizes.kDefaultPaddingDouble),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyUltraLight, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                StringConst.ACCOUNT_PARAMETERS,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.turquoiseBlue),
              ),
            ),
            _buildMyProfileRow(
              text: StringConst.CHANGE_PASSWORD,
              onTap: () => _confirmChangePassword(context),
            ),
            _buildMyProfileRow(
              text: StringConst.PRIVACY_POLICY,
              onTap: () => launchURL(StringConst.PRIVACY_URL),
            ),
            _buildMyProfileRow(
              text: StringConst.USE_CONDITIONS,
              onTap: () => launchURL(StringConst.USE_CONDITIONS_URL),
            ),
            _buildMyProfileRow(
              text: StringConst.SEND_FEEDBACK,
              onTap: () => _displayReportDialog(context),
            ),
            _buildMyProfileRow(
              text: StringConst.DELETE_ACCOUNT,
              textStyle: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Constants.deleteRed,
                  fontSize: 16.0),
              onTap: () => _confirmDeleteAccount(context, userEnreda),
            ),
          ],
        ));
  }

  Widget _buildMyProfileRow(
      {required String text,
        TextStyle? textStyle,
        String? imagePath,
        void Function()? onTap}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      color: text == ''
          ? Constants.lightTurquoise
          : Constants.white,
      child: InkWell(
        splashColor: Constants.onHoverTurquoise,
        highlightColor: Constants.lightTurquoise,
        hoverColor: text == ''
            ? Constants.lightTurquoise
            : Constants.onHoverTurquoise,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                    text,
                    style: textStyle ??
                        textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyTxtAlt,
                            fontSize: 16.0),
                  )),
              if (imagePath != null)
                Container(
                  width: 30,
                  child: Image.asset(
                    imagePath,
                    height: Sizes.ICON_SIZE_30,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _displayReportDialog(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(StringConst.SEND_FEEDBACK,
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w700,
              ), ),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(
                hintText: StringConst.SEND_FEEDBACK_TITLE,
                hintStyle: textTheme.bodySmall?.copyWith(
                  color: AppColors.greyDark,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),),
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w400,),
              minLines: 4,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(AppColors.primaryColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(StringConst.CANCEL),
                ),
                onPressed: () {
                    Navigator.pop(context);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(AppColors.primaryColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(StringConst.SEND),
                ),
                onPressed: () {
                  setState(() {
                    codeDialog = valueText;
                    if (valueText.isNotEmpty) {
                      final auth =
                      Provider.of<AuthBase>(context, listen: false);
                      final contact = Contact(
                          email: auth.currentUser?.email ?? '',
                          name: auth.currentUser?.displayName ?? '',
                          text: valueText);
                      database.addContact(contact);
                      showAlertDialog(
                        context,
                        title: StringConst.MESSAGE_SENT,
                        content:
                        StringConst.MESSAGE_SENT_DESCRIPTION,
                        defaultActionText: StringConst.FORM_ACCEPT,
                      ).then((value) => Navigator.pop(context));
                    }
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _confirmChangePassword(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: StringConst.CHANGE_PASSWORD,
        content: StringConst.SIGN_OUT_INSTRUCTIONS,
        cancelActionText: StringConst.CANCEL,
        defaultActionText: StringConst.FORM_ACCEPT);
    if (didRequestSignOut == true) {
      _changePasword(context);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, UserEnreda userEnreda) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: StringConst.DELETE_ACCOUNT,
        content: StringConst.DELETE_ACCOUNT_INSTRUCTIONS,
        cancelActionText: StringConst.CANCEL,
        defaultActionText: StringConst.FORM_ACCEPT);
    if (didRequestSignOut == true) {
      _deleteAccount(context, userEnreda);
    }
  }

  Future<void> _changePasword(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.changePassword();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteAccount(BuildContext context, UserEnreda userEnreda) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteUser(userEnreda);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }



}
