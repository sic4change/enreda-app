import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/resources/build_share_button.dart';
import 'package:enreda_app/app/home/resources/resource_actions.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../services/database.dart';
import '../../../common_widgets/show_alert_dialog.dart';
import '../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../services/auth.dart';
import '../../../values/strings.dart';
import '../models/contact.dart';

class ResourceListTile extends StatefulWidget {
  const ResourceListTile({Key? key, required this.resource, this.onTap})
      : super(key: key);
  final Resource resource;
  final VoidCallback? onTap;

  @override
  State<ResourceListTile> createState() => _ResourceListTileState();
}

class _ResourceListTileState extends State<ResourceListTile> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _name;
  String? _text;
  String? codeDialog;
  String? valueText;
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _email = "";
    _name = "";
    _text = "";
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 15, md: 14);
    double sidePadding = responsiveSize(context, 15, 20, md: 17);
    String resourceCategoryName = widget.resource.resourceCategoryName ?? '';
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: const EdgeInsets.all(5.0),
          child: InkWell(
            mouseCursor: WidgetStateMouseCursor.clickable,
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.blue050, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Constants.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyBorder,
                    spreadRadius: 0.2,
                    blurRadius: 1,
                    offset: Offset(0, 0),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 168,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 60,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: widget.resource.organizerImage == null ||
                                    widget.resource.organizerImage!.isEmpty
                                    ? sidePadding : sidePadding / 2, right: sidePadding, top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                widget.resource.organizerImage == null ||
                                        widget.resource.organizerImage!.isEmpty
                                    ? Container()
                                    : CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Constants.white,
                                      backgroundImage: NetworkImage(
                                          widget.resource.organizerImage!),
                                    ),
                                widget.resource.organizerImage == null ||
                                        widget.resource.organizerImage!.isEmpty
                                    ? Container()
                                    : SizedBox(
                                        width: 5,
                                      ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.resource.promotor?.isNotEmpty == true
                                            ? widget.resource.promotor!
                                            : widget.resource.organizerName ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Constants.grey,
                                          height: 1.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.place,
                                            color: Constants.grey,
                                            size: 12,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Text(
                                                getLocationText(widget.resource),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    textTheme.bodySmall?.copyWith(
                                                  color: Constants.grey,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      PopupMenuButton<int>(
                                        onSelected: (int value) {
                                          auth.currentUser == null
                                              ? _displayReportDialogVisitor(context, widget.resource)
                                              : _displayReportDialog(context, widget.resource);
                                        },
                                        itemBuilder: (context) {
                                          return List.generate(1, (index) {
                                            return PopupMenuItem(
                                              value: 1,
                                              child:
                                                  Text('Denunciar el recurso',
                                                    style: textTheme.bodySmall?.copyWith(
                                                      height: 1.5,
                                                      color: AppColors.red,
                                                      fontSize: fontSize,
                                                      fontWeight: FontWeight.w700,
                                                    ),),
                                            );
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.more_vert,
                                              color: AppColors.greyTxtAlt,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SpaceH4(),
                        Container(
                          height: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SpaceH8(),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: sidePadding, right: sidePadding),
                                child: Text(
                                  resourceCategoryName.toUpperCase(),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  style: TextStyle(
                                      letterSpacing: 1,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor),
                                ),
                              ),
                              SpaceH4(),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: sidePadding, left: sidePadding),
                                child: Text(
                                  widget.resource.title,
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  style: TextStyle(
                                    letterSpacing: 1,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 70,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey350, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Constants.white
                            ),
                            child: Text(
                              'Ver más', style: TextStyle(
                              letterSpacing: 1,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greyTxtAlt,
                            ),
                            )
                          ),
                          Spacer(),
                          buildShare(
                              context, widget.resource, Constants.grey, AppColors.greyTxtAlt, Colors.transparent),
                          SpaceW4(),
                          auth.currentUser == null
                            ? IconButton(
                                icon: FaIcon(FontAwesomeIcons.heart, color: AppColors.red),
                                tooltip: 'Me gusta',
                                color: Constants.darkGray,
                                iconSize: 20,
                                onPressed: () => showAlertNullUser(context),
                              )
                            : widget.resource.likes
                                    .contains(auth.currentUser!.uid)
                                ? IconButton(
                                    icon: FaIcon(FontAwesomeIcons.solidHeart),
                                    tooltip: 'Me gusta',
                                    color: AppColors.red,
                                    iconSize: 20,
                                    onPressed: () {
                                      _removeUserToLike(widget.resource,
                                          auth.currentUser!.uid);
                                    },
                                  )
                                : IconButton(
                                    icon: FaIcon(FontAwesomeIcons.heart, color: AppColors.red),
                                    tooltip: 'Me gusta',
                                    color: Constants.darkGray,
                                    onPressed: () {
                                      _addUserToLike(widget.resource);
                                    },
                                  ),

                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }

  String getLocationText(Resource resource) {
    switch (resource.modality) {
      case StringConst.FACE_TO_FACE:
      case StringConst.BLENDED:
        {
          if (resource.cityName != null) {
            return '${resource.cityName}, ${resource.provinceName}, ${resource.countryName}';
          }

          if (resource.cityName == null && resource.provinceName != null) {
            return '${resource.provinceName}, ${resource.countryName}';
          }

          if (resource.provinceName == null && resource.countryName != null) {
            return resource.countryName!;
          }

          if (resource.provinceName != null) {
            return resource.provinceName!;
          } else if (resource.countryName != null) {
            return resource.countryName!;
          }
          return resource.modality;
        }

      case StringConst.ONLINE_FOR_COUNTRY:
      /*return StringConst.ONLINE_FOR_COUNTRY
            .replaceAll('país', resource.countryName!);*/

      case StringConst.ONLINE_FOR_PROVINCE:
      /*return StringConst.ONLINE_FOR_PROVINCE.replaceAll(
            'provincia', '${resource.provinceName!}, ${resource.countryName!}');*/

      case StringConst.ONLINE_FOR_CITY:
      /*return StringConst.ONLINE_FOR_CITY.replaceAll('ciudad',
            '${resource.cityName!}, ${resource.provinceName!}, ${resource.countryName!}');*/

      case StringConst.ONLINE:
        return StringConst.ONLINE;

      default:
        return resource.modality;
    }
  }

  Future<void> _displayReportDialogVisitor(
      BuildContext context, Resource resource) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.primary050,
            title: CustomTextMediumBold(text: 'Denunciar recurso'),
            content: _buildForm(context, resource),
          );
        });
  }

  Widget _buildForm(BuildContext context, Resource resource) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: Responsive.isMobile(context) ? 300 : 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildFormChildren(context, resource),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormChildren(BuildContext context, Resource resource) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 12, 15, md: 13);
    double fontSizeButton = responsiveSize(context, 12, 15, md: 13);
    return [
      Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary900,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  )
              ),
              initialValue: '',
              validator: (value) =>
              value!.isNotEmpty ? null : 'El nombre no puede estar vacío',
              onSaved: (value) => _name = value,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.name,
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.primary900,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary900,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  )
              ),
              initialValue: _email,
              validator: (value) => EmailValidator.validate(value!) ? null : "El email no es válido",
              onSaved: (value) => _email = value,
              keyboardType: TextInputType.emailAddress,
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.primary900,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Descripción de la denuncia',
                  labelStyle: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary900,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  )
              ),
              initialValue: _text,
              validator: (value) =>
              value!.isNotEmpty ? null : 'La descripción no puede estar vacía',
              onSaved: (value) => _text = value,
              minLines: 4,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.primary900,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
              ),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.turquoise,
                    ),
                    child: Padding(
                      padding: Responsive.isMobile(context) ?
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5.0) : const EdgeInsets.all(10.0),
                      child: Text(StringConst.CANCEL,
                        style: textTheme.bodySmall?.copyWith(
                          height: 1.5,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: fontSizeButton,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SpaceW20(),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.turquoise,
                    ),
                    child: Padding(
                      padding: Responsive.isMobile(context) ?
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5.0) : const EdgeInsets.all(10.0),
                      child: Text(StringConst.SEND,
                        style: textTheme.bodySmall?.copyWith(
                          height: 1.5,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: fontSizeButton,
                        ),
                      ),
                    ),
                    onPressed: () => _submit(resource),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
          ])
    ];
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit(Resource resource) async {
    if (_validateAndSaveForm()) {
      final contact = Contact(
        email: _email!,
        name: _name!,
        text:
        'Tenemos una queja de este recurso: ${resource.title}.  ${_text!}',
      );
      try {
        final database = Provider.of<Database>(context, listen: false);
        await database.addContact(contact);
        showAlertDialog(
          context,
          title: 'Mensaje ensaje enviado',
          content:
          'Hemos recibido satisfactoriamente tu mensaje, nos comunicaremos contigo a la brevedad.',
          defaultActionText: 'Ok',
        ).then((value) => Navigator.pop(context));
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: 'Error al enviar contacto', exception: e)
            .then((value) => Navigator.pop(context));
        ;
      }
    }
  }

  Future<void> _displayReportDialog(BuildContext context, Resource resource) async {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 15, 16, md: 15);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.primary050,
            title: CustomTextMediumBold(text: 'Denunciar recurso'),
            content: Container(
              width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width :
              MediaQuery.of(context).size.width * 0.5,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    valueText = value;
                  });
                },
                controller: _textFieldController,
                decoration: InputDecoration(
                    hintText: "Escribe la queja",
                    hintStyle: textTheme.bodySmall?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.5,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                    ),
                ),
                style: textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  color: AppColors.primary900,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,),
                minLines: 4,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Padding(
                  padding: Responsive.isMobile(context) ?
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0) : const EdgeInsets.all(10.0),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Padding(
                  padding: Responsive.isMobile(context) ?
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0) : const EdgeInsets.all(10.0),
                  child: Text(
                    'Enviar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    codeDialog = valueText;
                    if (valueText != null && valueText!.isNotEmpty) {
                      final auth =
                      Provider.of<AuthBase>(context, listen: false);
                      final contact = Contact(
                          email: auth.currentUser?.email ?? '',
                          name: auth.currentUser?.displayName ?? '',
                          text:
                          'Tenemos una queja de este recurso: ${resource.title}.  ${valueText}');
                      database.addContact(contact);
                      showAlertDialog(
                        context,
                        title: 'Mensaje ensaje enviado',
                        content:
                        'Hemos recibido satisfactoriamente tu mensaje, nos comunicaremos contigo a la brevedad.',
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

  Future<void> _addUserToLike(Resource resource) async {
    if (_checkAnonimousUser()) {
      _showAlertUserAnonimousLike();
    } else {
      final auth = Provider.of<AuthBase>(context, listen: false);
      final database = Provider.of<Database>(context, listen: false);
      resource.likes.add(auth.currentUser!.uid);
      await database.setResource(resource);
      setState(() {
        widget.resource;
      });
    }
  }

  Future<void> _removeUserToLike(Resource resource, String userId) async {
    final database = Provider.of<Database>(context, listen: false);
    resource.likes.remove(userId);
    await database.setResource(resource);
    setState(() {
      widget.resource;
    });
  }

  bool _checkAnonimousUser() {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      return auth.currentUser!.isAnonymous;
    } catch (e) {
      print(e.toString());
      return true;
    }
  }

  _showAlertUserAnonimousLike() async {
    final didRequestSignOut = await showAlertDialog(context,
        title: '¿Te interesa este recurso?',
        content:
            'Solo los usuarios registrados pueden guardar como favoritos los recursos. ¿Desea entrar como usuario registrado?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Entrar');
    if (didRequestSignOut == true) {
      _signOut(context);
      Navigator.of(context).pop();
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
