import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/contact.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/build_share_button.dart';
import 'package:enreda_app/app/home/resources/resource_actions.dart';
import 'package:enreda_app/common_widgets/background_mobile.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/show_alert_dialog.dart';
import '../../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../../utils/adaptive.dart';
import '../../../../utils/functions.dart';
import '../../../../values/values.dart';

class ResourceDetailPage extends StatefulWidget {
  const ResourceDetailPage({Key? key, required this.resourceId})
      : super(key: key);
  final String resourceId;

  @override
  _ResourceDetailPageState createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  TextEditingController _textFieldController = TextEditingController();
  late Resource resource;

  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _name;
  String? _text;
  String? codeDialog;
  String? valueText;

  @override
  void initState() {
    super.initState();
    _email = "";
    _name = "";
    _text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 100),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: new EdgeInsets.only(
                    right: Constants.mainPadding,
                    left: Constants.mainPadding,
                    top: Constants.mainPadding,
                    bottom: 0),
                height: 44,
                width: 44,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Constants.lightTurquoise,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Icon(Icons.keyboard_backspace, color: Constants.white),
                  onPressed: () {
                    context.canPop()
                        ? context.pop()
                        : context.go(StringConst.PATH_HOME);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
         BackgroundMobile(backgroundHeight: BackgroundHeight.ExtraLarge),
          _buildContent()
        ],
      ),
    );
  }

  Widget _buildContent() {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<Resource>(
        stream: database.resourceStream(widget.resourceId),
        builder: (context, snapshotResource) {
          if (snapshotResource.hasData &&
              snapshotResource.connectionState == ConnectionState.active) {
            resource = snapshotResource.data!;
            resource.setResourceTypeName();
            return StreamBuilder(
                stream: resource.organizerType == 'Organización'
                    ? database.organizationStream(resource.organizer)
                    : database.mentorStream(resource.organizer),
                builder: (context, snapshotOrganizer) {
                  if (snapshotOrganizer.hasData &&
                      snapshotOrganizer.connectionState ==
                          ConnectionState.active) {
                    if (resource.organizerType == 'Organización') {
                      final organization =
                          snapshotOrganizer.data as Organization;
                      resource.organizerName =
                          organization == null ? '' : organization.name;
                      resource.organizerImage =
                          organization == null ? '' : organization.photo;
                    } else {
                      final mentor = snapshotOrganizer.data as UserEnreda;
                      resource.organizerName = mentor == null
                          ? ''
                          : '${mentor.firstName} ${mentor.lastName} ';
                      resource.organizerImage =
                          mentor == null ? '' : mentor.photo;
                    }
                  }
                  return StreamBuilder<Country>(
                      stream: database.countryStream(resource.country),
                      builder: (context, snapshot) {
                        final country = snapshot.data;
                        resource.countryName =
                            country == null ? '' : country.name;
                        return StreamBuilder<Province>(
                            stream: database.provinceStream(resource.province),
                            builder: (context, snapshot) {
                              final province = snapshot.data;
                              resource.provinceName =
                                  province == null ? '' : province.name;
                              return StreamBuilder<City>(
                                  stream: database.cityStream(resource.city),
                                  builder: (context, snapshot) {
                                    final city = snapshot.data;
                                    resource.cityName =
                                        city == null ? '' : city.name;
                                    return Padding(
                                      padding: kIsWeb? const EdgeInsets.only(top: 40.0): const EdgeInsets.only(top: 60.0),
                                      child: Dialog(
                                        insetPadding: EdgeInsets.all(12.0),
                                        alignment: Alignment.topCenter,
                                        clipBehavior: Clip.hardEdge,
                                        elevation: 0.0,
                                        backgroundColor: Colors.transparent,
                                        child: Stack(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 10,
                                                  top: 30,
                                                  right: 10,
                                                  bottom: 10),
                                              decoration: BoxDecoration(
                                                  color: Constants.white,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 4.0,
                                                      offset: Offset(0.0, 1.0),
                                                    ),
                                                  ]),
                                              padding: EdgeInsets.all(
                                                  Constants.mainPadding),
                                              child: resource.organizerImage !=
                                                          null &&
                                                      resource.organizerName !=
                                                          null
                                                  ? Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  Container(),
                                                            ),
                                                            _buildMenuButton(
                                                                context),
                                                          ],
                                                        ),
                                                        _buildHeader(),
                                                        Divider(),
                                                        Flexible(
                                                            child:
                                                                _buildBody()),
                                                        SpaceH8(),
                                                        _buildActionButtons(),
                                                      ],
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                            ),
                                            resource.organizerImage == null ||
                                                    resource
                                                        .organizerImage!.isEmpty
                                                ? Container()
                                                : Align(
                                                    alignment: Alignment.topCenter,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1.0,
                                                              color: Constants
                                                                  .lightGray),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            100,
                                                          ),
                                                          color: Constants
                                                              .lightGray),
                                                      child: CircleAvatar(
                                                        radius: 30,
                                                        backgroundColor:
                                                            Constants.white,
                                                        backgroundImage:
                                                            NetworkImage(resource
                                                                .organizerImage!),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            });
                      });
                });
          } else
            return Container();
        });
  }

  Widget _buildHeader() {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          resource.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: textTheme.bodyText1?.copyWith(
            letterSpacing: 1.2,
            fontSize: 16,
            color: Constants.darkGray,
          ),
        ),
        SpaceH12(),
        Text(
          resource.promotor != null
              ? resource.promotor!
              : resource.organizerName ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Constants.penBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            resource.description,
            style: textTheme.bodyText1,
          ),
          SpaceH40(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Constants.lightGray,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpaceH30(),
                  Text(
                    StringConst.RESOURCE_TYPE.toUpperCase(),
                    style: textTheme.bodyText1?.copyWith(
                        color: Constants.penBlue, fontWeight: FontWeight.bold),
                  ),
                  SpaceH8(),
                  Text('${resource.resourceTypeName}', style: textTheme.bodyText1,),
                  SpaceH30(),
                  Text(
                    StringConst.LOCATION.toUpperCase(),
                    style: textTheme.bodyText1?.copyWith(
                        color: Constants.penBlue, fontWeight: FontWeight.bold),
                  ),
                  SpaceH8(),
                  Text(_getLocationText(resource), style: textTheme.bodyText1,),
                  SpaceH30(),
                  Text(
                    StringConst.CAPACITY.toUpperCase(),
                    style: textTheme.bodyText1?.copyWith(
                        color: Constants.penBlue, fontWeight: FontWeight.bold),
                  ),
                  SpaceH8(),
                  Text('${resource.capacity}', style: textTheme.bodyText1,),
                  SpaceH30(),
                  Text(
                    StringConst.DATE.toUpperCase(),
                    style: textTheme.bodyText1?.copyWith(
                        color: Constants.penBlue, fontWeight: FontWeight.bold),
                  ),
                  SpaceH8(),
                  DateFormat('dd/MM/yyyy').format(resource.start) == '31/12/2050'
                      ? Text(
                          StringConst.ALWAYS_AVAILABLE,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyText1,
                        )
                      : Text(
                          '${DateFormat('dd/MM/yyyy').format(resource.start)} - ${DateFormat('dd/MM/yyyy').format(resource.end)}',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyText1,
                        ),
                  SpaceH30(),
                  Text(
                    StringConst.CONTRACT_TYPE.toUpperCase(),
                    style: textTheme.bodyText1?.copyWith(
                        color: Constants.penBlue, fontWeight: FontWeight.bold),
                  ),
                  SpaceH8(),
                  Text(
                    resource.contractType == null ||
                            resource.contractType!.isEmpty
                        ? 'Sin especificar'
                        : resource.contractType!,
                    textAlign: TextAlign.center, style: textTheme.bodyText1,
                  ),
                  SpaceH30(),
                  Text(
                    StringConst.SALARY.toUpperCase(),
                    style: textTheme.bodyText1?.copyWith(
                        color: Constants.penBlue, fontWeight: FontWeight.bold),
                  ),
                  SpaceH8(),
                  Text(
                    resource.salary == null || resource.salary!.isEmpty
                        ? 'Sin especificar'
                        : resource.salary!,
                    textAlign: TextAlign.center, style: textTheme.bodyText1,
                  ),
                  SpaceH30(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final textTheme = Theme.of(context).textTheme;
    final auth = Provider.of<AuthBase>(context);
    final userId = auth.currentUser?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          onPressed: () =>
          auth.currentUser == null
              ? showAlertNullUser(context)
              : resource.participants.contains(userId)
                  ? removeUserToResource(
                      context: context, userId: userId, resource: resource)
                  : resource.link == null &&
                          resource.contactEmail == null &&
                          resource.contactPhone == null
                      ? addUserToResource(
                          context: context, userId: userId, resource: resource)
                      : resource.link != null
                          ? launchURL(resource.link!)
                          : showContactDialog(
                              context: context, resource: resource),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              resource.participants.contains(userId)
                  ? StringConst.QUIT_RESOURCE
                  : StringConst.JOIN_RESOURCE,
              style: textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w600,
                color: Constants.white,
              ),
            ),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(resource.participants.contains(userId)
                  ? Constants.chatDarkBlue : Constants.turquoise),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ))),
        ),
        SpaceH12(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildShareButton(context, resource, Constants.darkGray),
            InkWell(
              mouseCursor: MaterialStateMouseCursor.clickable,
              onTap: () {
                auth.currentUser == null
                    ? showAlertNullUser(context)
                    : resource.likes.contains(userId)
                        ? removeUserToLike(
                            context: context,
                            userId: userId,
                            resource: resource)
                        : addUserToLike(
                            context: context,
                            userId: userId,
                            resource: resource);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  top: 2,
                  right: 4,
                  bottom: 0,
                ),
                child: Column(
                  children: [
                    (resource.likes.contains(userId))
                        ? Icon(
                            Icons.favorite,
                            color: Constants.salmonLight,
                            size: 30,
                          )
                        : Icon(Icons.favorite_outline_outlined,
                            color: Constants.darkGray, size: 30),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopupMenuButton<int>(
      onSelected: (int value) {
        auth.currentUser == null
            ? _displayReportDialogVisitor(context, resource)
            : _displayReportDialog(context, resource);
      },
      itemBuilder: (context) {
        return List.generate(1, (index) {
          return PopupMenuItem(
            value: 1,
            child: Text('Denunciar el recurso',
                style: textTheme.button?.copyWith(
                height: 1.5,
                color: AppColors.red,
                fontWeight: FontWeight.w700,
                ),),
          );
        });
      },
      child: Icon(
        Icons.more_vert,
        color: Constants.grey,
        size: 30.0,
      ),
    );
  }

  Future<void> _displayReportDialog(BuildContext context, Resource resource) async {
    final database = Provider.of<Database>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Denunciar recurso',
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
                hintText: "Escribe la queja",
                hintStyle: textTheme.button?.copyWith(
                  color: AppColors.greyDark,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
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
                  padding: const EdgeInsets.all(10.0),
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

  String _getLocationText(Resource resource) {
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
        return StringConst.ONLINE_FOR_COUNTRY
            .replaceAll('país', resource.countryName!);

      case StringConst.ONLINE_FOR_PROVINCE:
        return StringConst.ONLINE_FOR_PROVINCE.replaceAll(
            'provincia', '${resource.provinceName!}, ${resource.countryName!}');

      case StringConst.ONLINE_FOR_CITY:
        return StringConst.ONLINE_FOR_CITY.replaceAll('ciudad',
            '${resource.cityName!}, ${resource.provinceName!}, ${resource.countryName!}');

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
            title: Text('Denunciar recurso'),
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
          width: 500,
          height: 350,
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
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return [
      Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Nombre'),
              initialValue: '',
              validator: (value) =>
              value!.isNotEmpty ? null : 'El nombre no puede estar vacío',
              onSaved: (value) => _name = value,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.name,
              style: textTheme.button?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
              ),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              initialValue: _email,
              validator: (value) => EmailValidator.validate(value!) ? null : "El email no es válido",
              onSaved: (value) => _email = value,
              keyboardType: TextInputType.emailAddress,
              style: textTheme.button?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
              ),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Descripción de la denuncia'),
              initialValue: _text,
              validator: (value) =>
              value!.isNotEmpty ? null : 'La descripción no puede estar vacía',
              onSaved: (value) => _text = value,
              minLines: 4,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              style: textTheme.button?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
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
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(StringConst.CANCEL.toUpperCase(),
                        style: textTheme.button?.copyWith(
                          height: 1.5,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: fontSize,
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
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(StringConst.SEND.toUpperCase(),
                        style: textTheme.button?.copyWith(
                          height: 1.5,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: fontSize,
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
          defaultActionText: 'Aceptar',
        ).then((value) => Navigator.pop(context));
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: 'Error al enviar contacto', exception: e)
            .then((value) => Navigator.pop(context));
        ;
      }
    }
  }

}
