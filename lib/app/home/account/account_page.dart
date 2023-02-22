import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/competencies/my_competencies_page.dart';
import 'package:enreda_app/app/home/curriculum/my_curriculum_page.dart';
import 'package:enreda_app/app/home/account/personal_data_page.dart';
import 'package:enreda_app/app/home/models/contact.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/pages/favorite_resources_page.dart';
import 'package:enreda_app/app/home/resources/pages/my_resources_page.dart';
import 'package:enreda_app/app/sign_in/access/access_page.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../utils/functions.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  TextEditingController _textFieldController = TextEditingController();
  ImagePicker _imagePicker = ImagePicker();
  BuildContext? myContext;
  String _userId = '';
  String _photo = '';
  String codeDialog = '';
  String valueText = '';
  Widget? _currentPage = MyCurriculumPage();

  String _currentPageTitle = StringConst.MY_CV.toUpperCase();
  String _selectedPageName = StringConst.MY_CV;

  late UserEnreda _userEnreda;
  late TextTheme textTheme;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    textTheme = Theme.of(context).textTheme;

    return StreamBuilder<User?>(
        stream: Provider.of<AuthBase>(context).authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<UserEnreda>(
              stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _userEnreda = snapshot.data!;
                  _photo = (_userEnreda.profilePic?.src == null || _userEnreda.profilePic?.src == ""
                      ? "" : _userEnreda.profilePic?.src)!;
                  _userId = _userEnreda.userId ?? '';
                  return Responsive.isDesktop(context) || Responsive.isDesktopS(context)
                      ? _buildDesktopLayout(_userEnreda)
                      : _buildMobileLayout(_userEnreda, context);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          } else if (!snapshot.hasData) {
            return AccessPage();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildDesktopLayout(UserEnreda userEnreda) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child:
      Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            width: widthOfScreen(context) < 1200
                ? Constants.sidebarWidth / 2
                : Constants.sidebarWidth,
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMyProfile(userEnreda),
                  SpaceH20(),
                  _buildMyParameters()
                ],
              ),
            ),
          ),
          SpaceW20(),
          Expanded(
            child: _currentPageTitle == StringConst.PERSONAL_DATA.toUpperCase()
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26.0),
                    child: _currentPage,
                  )
                : _currentPageTitle == StringConst.MY_CV.toUpperCase()
                    ? Stack(
                        children: [
                          _currentPage!,
                          Responsive.isTablet(context) ? Container() : Positioned(
                            top: -80,
                            left: 80,
                            child: Image.asset(ImagePath.CLIP_CV),
                            width: 100.0,
                          ),
                          Responsive.isTablet(context) ? Container() : Positioned(
                            top: -80,
                            right: 80,
                            child: Image.asset(ImagePath.CLIP_CV),
                            width: 100.0,
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Container(
                          padding: EdgeInsets.all(Constants.mainPadding),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Constants.lightGray, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(Constants.mainPadding),
                                child: Text(
                                  _currentPageTitle,
                                  style: textTheme.bodyText1?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Constants.penBlue,
                                      fontSize: 16.0),
                                ),
                              ),
                              Expanded(child: _currentPage!),
                            ],
                          ),
                        ),
                      ),
          ),
        ]),
    );
  }

  Widget _buildMobileLayout(UserEnreda userEnreda, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: Colors.white,
        ),
        child: ListView(
          children: <Widget>[
            _buildMyProfile(userEnreda),
            SpaceH20(),
            _currentPageTitle == StringConst.PERSONAL_DATA.toUpperCase() ||
                    _currentPageTitle == StringConst.MY_CV.toUpperCase()
                ? Container()
                : Padding(
                    padding: EdgeInsets.all(Constants.mainPadding),
                    child: Text(
                      _currentPageTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Constants.penBlue,
                          fontSize: 16.0),
                    ),
                  ),
            Padding(
              padding: EdgeInsets.all(
                  _currentPageTitle == StringConst.PERSONAL_DATA.toUpperCase()
                      ? 0.0
                      : 0.0),
              child: _currentPage,
            ),
            SpaceH20(),
            _buildMyParameters(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyProfile(UserEnreda? userEnreda) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Constants.mainPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.lightGray, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            onTap: () => !kIsWeb
                ? _displayPickImageDialog()
                : _onImageButtonPressed(ImageSource.gallery),
            child: Container(
              width: 120,
              height: 120,
              color: Colors.white,
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120),
                      ),
                      child:
                      !kIsWeb ?
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(60)),
                        child:
                        Stack(
                          children: <Widget>[
                            const Center(child: CircularProgressIndicator()),
                            Center(
                              child:
                              _photo == "" ?
                              Container(
                                color:  Colors.transparent,
                                height: 120,
                                width: 120,
                                child: Image.asset(ImagePath.USER_DEFAULT),
                              ):
                              CachedNetworkImage(
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  imageUrl: _photo),
                            ),
                          ],
                        ),
                      ):
                      ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            child:
                            Stack(
                              children: <Widget>[
                                const Center(child: CircularProgressIndicator()),
                                Center(
                                  child:
                                  _photo == "" ?
                                  Container(
                                    color:  Colors.transparent,
                                    height: 120,
                                    width: 120,
                                    child: Image.asset(ImagePath.USER_DEFAULT),
                                  ):
                                  FadeInImage.assetNetwork(
                                    placeholder: ImagePath.USER_DEFAULT,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    image: _photo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Constants.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Constants.penBlue, width: 1.0),
                      ),
                      child: Icon(
                        Icons.mode_edit_outlined,
                        size: 22,
                        color: Constants.penBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SpaceH8(),
          if (userEnreda?.firstName != null)
            Text(
              '${userEnreda!.firstName} ${userEnreda.lastName}',
              style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: Constants.chatDarkGray),
            ),
          SpaceH48(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              StringConst.MY_PROFILE.toUpperCase(),
              style: textTheme.bodyLarge?.copyWith(color: Constants.penBlue),
            ),
          ),
          Divider(),
          _buildMyProfileRow(
            text: StringConst.MY_CV,
            imagePath: ImagePath.ICON_CV,
            onTap: () => setState(() {
              _currentPage = MyCurriculumPage();
              _currentPageTitle = StringConst.MY_CV.toUpperCase();
              _selectedPageName = StringConst.MY_CV;
            }),
          ),
          _buildMyProfileRow(
            text: StringConst.PERSONAL_DATA,
            imagePath: ImagePath.ICON_PROFILE_BLUE,
            onTap: () => setState(() {
              _currentPage = PersonalData();
              _currentPageTitle = StringConst.PERSONAL_DATA.toUpperCase();
              _selectedPageName = StringConst.PERSONAL_DATA;
            }),
          ),
          _buildMyProfileRow(
            text: StringConst.MY_COMPETENCIES,
            imagePath: ImagePath.ICON_COMPETENCIES,
            onTap: () => setState(() {
              _currentPage = MyCompetenciesPage();
              _currentPageTitle = StringConst.MY_COMPETENCIES.toUpperCase();
              _selectedPageName = StringConst.MY_COMPETENCIES;
            }),
          ),
          _buildMyProfileRow(
            text: StringConst.MY_RESOURCES,
            imagePath: ImagePath.ICON_RESOURCES_BLUE,
            onTap: () => setState(() {
              _currentPage = MyResourcesPage();
              _currentPageTitle = StringConst.MY_RESOURCES.toUpperCase();
              _selectedPageName = StringConst.MY_RESOURCES;
            }),
          ),
          _buildMyProfileRow(
            text: StringConst.FAVORITES,
            imagePath: ImagePath.ICON_FAV_BLUE,
            onTap: () => setState(() {
              _currentPage = FavoriteResourcesPage();
              _currentPageTitle = StringConst.FAVORITES.toUpperCase();
              _selectedPageName = StringConst.FAVORITES;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMyParameters() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: Constants.mainPadding),
        decoration: BoxDecoration(
          border: Border.all(color: Constants.lightGray, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'CONFIGURACIÓN DE LA CUENTA',
                style: textTheme.bodyLarge?.copyWith(color: Constants.penBlue),
              ),
            ),
            Divider(),
            _buildMyProfileRow(
              text: 'Cambiar contraseña',
              onTap: () => _confirmChangePassword(context),
            ),
            _buildMyProfileRow(
              text: 'Política de privacidad',
              onTap: () => launchURL(StringConst.PRIVACY_URL),
            ),
            _buildMyProfileRow(
              text: 'Condiciones de uso',
              onTap: () => launchURL(StringConst.USE_CONDITIONS_URL),
            ),
            _buildMyProfileRow(
              text: 'Ayúdanos a mejorar',
              onTap: () => _displayReportDialog(context),
            ),
            _buildMyProfileRow(
              text: 'Eliminar cuenta',
              textStyle: textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Constants.deleteRed,
                  fontSize: 16.0),
              onTap: () => _confirmDeleteAccount(context),
            ),
          ],
        ));
  }

  Widget _buildMyProfileRow(
      {required String text,
      TextStyle? textStyle,
      String? imagePath,
      void Function()? onTap}) {
    return Material(
      color: text == _selectedPageName
          ? Constants.lightTurquoise
          : Constants.white,
      child: InkWell(
        splashColor: Constants.onHoverTurquoise,
        highlightColor: Constants.lightTurquoise,
        hoverColor: text == _selectedPageName
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
                    textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Constants.penBlue,
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


  Future<void> _displayPickImageDialog() async {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 24.0),
              child: Row(
                children: <Widget>[
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.camera,
                          color: Colors.indigo,
                          size: 30,
                        ),
                        onPressed: () {
                          _onImageButtonPressed(ImageSource.camera);
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(
                        'Cámara',
                        style: textTheme.bodyText1?.copyWith(fontSize: 12.0),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(children: [
                    IconButton(
                        icon: Icon(
                          Icons.photo,
                          color: Colors.indigo,
                          size: 30,
                        ),
                        onPressed: () {
                          _onImageButtonPressed(ImageSource.gallery);
                          Navigator.of(context).pop();
                        }),
                    Text(
                      'Galería',
                      style: textTheme.bodyText1?.copyWith(fontSize: 12.0),
                    ),
                  ]),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
      );
      if (pickedFile != null) {
        setState(() async {
          final database = Provider.of<Database>(context, listen: false);
          await database.uploadUserAvatar(
              _userId, await pickedFile.readAsBytes());
        });
      }
    } catch (e) {
      setState(() {
        //_pickImageError = e;
      });
    }
  }

  Future<void> _displayReportDialog(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ayudanos a mejorar',
              style: textTheme.button?.copyWith(
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
                hintText: "Escribe tus sugerencias",
                hintStyle: textTheme.button?.copyWith(
                  color: AppColors.greyDark,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),),
              style: textTheme.button?.copyWith(
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
                  child: Text('Cancelar'),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
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
                  child: Text('Enviar'),
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
                        title: 'Mensaje ensaje enviado',
                        content:
                        'Hemos recibido satistactoriamente tu sugerencia. ¡Muchas gracias por tu información!',
                        defaultActionText: 'Aceptar',
                      ).then((value) => Navigator.pop(context));
                    }
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _changePasword(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.changePassword();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteUser(_userEnreda);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmChangePassword(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Cambiar contraseña',
        content: 'Si pulsa en Aceptar se le envirá a su correo las acciones a '
            'realizar para cambiar su contraseña. Si no aparece, revisa las carpetas de SPAM y Correo no deseado',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Aceptar');
    if (didRequestSignOut == true) {
      _changePasword(context);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Eliminar cuenta',
        content: 'Si pulsa en Aceptar se procederá a la eliminación completa '
            'de su cuenta, esta acción no se podrá deshacer, '
            '¿Está seguro que quiere continuar?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Aceptar');
    if (didRequestSignOut == true) {
      _deleteAccount(context);
    }
  }

}
