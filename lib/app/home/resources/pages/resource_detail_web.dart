import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/contact.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/build_share_button.dart';
import 'package:enreda_app/app/home/resources/resource_actions.dart';
import 'package:enreda_app/common_widgets/background_web.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/show_alert_dialog.dart';
import '../../../../common_widgets/show_back_icon.dart';
import '../../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../../utils/adaptive.dart';
import '../../../../utils/functions.dart';
import '../../../../values/values.dart';
import '../../../anallytics/analytics.dart';

class ResourceDetailPageWeb extends StatefulWidget {
  const ResourceDetailPageWeb({Key? key, required this.resourceId})
      : super(key: key);
  final String resourceId;

  @override
  _ResourceDetailPageWebState createState() => _ResourceDetailPageWebState();
}

class _ResourceDetailPageWebState extends State<ResourceDetailPageWeb> {
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
    _countUserAccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: showBackIconButton(context, Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          Opacity(opacity: 0.8, child: BackgroundWeb()),
          _buildContent(),
        ],
      ),
    );
  }

  Future<void> _countUserAccess() async {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (auth.currentUser != null) {
      final user = await database.userEnredaStreamByUserId(auth.currentUser!.uid).first;
      database.setUserEnreda(user.copyWith(resourcesAccessCount: user.resourcesAccessCount! + 1));
    }
  }

  Widget _buildContent() {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<Resource>(
        stream: database.resourceStream(widget.resourceId),
        builder: (context, snapshotResource) {
          if (snapshotResource.hasData) {
            resource = snapshotResource.data!;
            resource.setResourceTypeName();
            resource.setResourceCategoryName();
            sendResourceAnalyticsEvent(context, "enreda_app_open_resource", resource.resourceCategoryName!);
            return StreamBuilder(
                stream: resource.organizerType == 'Organización' ? database.organizationStream(resource.organizer) :
                resource.organizerType == 'Entidad Social' ? database.socialEntityStream(resource.organizer)
                    : database.mentorStream(resource.organizer),
                builder: (context, snapshotOrganizer) {
                  if (snapshotOrganizer.hasData) {
                    if (resource.organizerType == 'Organización') {
                      final organization = snapshotOrganizer.data as Organization;
                      resource.organizerName = organization.name;
                      resource.organizerImage = organization.photo;
                    } else if (resource.organizerType == 'Entidad Social') {
                      final organization = snapshotOrganizer.data as SocialEntity;
                      resource.organizerName = organization.name;
                      resource.organizerImage = organization.photo;
                    } else {
                      final mentor = snapshotOrganizer.data as UserEnreda;
                      resource.organizerName = '${mentor.firstName} ${mentor.lastName} ';
                      resource.organizerImage = mentor.photo;
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
                                      padding: const EdgeInsets.only(top: 70.0),
                                      child: Dialog(
                                        alignment: Alignment.topCenter,
                                        clipBehavior: Clip.hardEdge,
                                        elevation: 0.0,
                                        backgroundColor: Colors.transparent,
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Container(
                                                width:  Responsive.isDesktopS(context) ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.6,
                                                margin: EdgeInsets.only(top: 0, bottom: 20),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(20.0),
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 4.0,
                                                        offset: Offset(0.0, 1.0),
                                                      ),
                                                    ]),
                                                padding: EdgeInsets.all(
                                                    Constants.mainPadding),
                                                child: resource.organizerImage != null && resource.organizerName != null
                                                    ? SingleChildScrollView(
                                                      child: Column(mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(child: Container(),),
                                                                _buildMenuButton(context, resource),
                                                              ],
                                                            ),
                                                            SpaceH30(),
                                                            _buildHeader(),
                                                            SpaceH20(),
                                                            Divider(),
                                                            SpaceH20(),
                                                            Flexible(child: _buildBody()),
                                                            SpaceH20(),
                                                            _buildActionButtons(),
                                                          ],
                                                        ),
                                                    )
                                                    : Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                              ),
                                            ),
                                            resource.organizerImage == null || resource.organizerImage!.isEmpty
                                                ? Container()
                                                : Align(
                                                    alignment: Alignment.topCenter,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(width: 1.0, color: Constants.lightGray),
                                                          borderRadius: BorderRadius.circular(60,),
                                                          color: Constants.lightGray),
                                                      child: CircleAvatar(
                                                        radius: 30,
                                                        backgroundColor: Constants.white,
                                                        backgroundImage: NetworkImage(resource.organizerImage!),
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
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          resource.title,
          textAlign: TextAlign.left,
          maxLines: 2,
          style: textTheme.bodyLarge?.copyWith(
            letterSpacing: 1.2,
            color: Constants.darkGray,
            fontWeight: FontWeight.w800
          ),
        ),
        SpaceH12(),
        Text(
          resource.promotor?.isNotEmpty == true
              ? resource.promotor!
              : resource.organizerName ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.2,
            color: Constants.penBlue,
            fontWeight: FontWeight.w800
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            resource.description,
            style: textTheme.bodyMedium?.copyWith(
              color: Constants.darkGray,
            ),
          ),
          flex: 6,
        ),
        SpaceW30(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Constants.lightGray,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextTitle(title: StringConst.RESOURCE_TYPE.toUpperCase()),
                  CustomTextBody(text: '${resource.resourceCategoryName}'),
                  SpaceH8(),
                  CustomTextTitle(title: StringConst.LOCATION.toUpperCase()),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextBody(text: '${resource.cityName},'),
                      CustomTextBody(text: '${resource.provinceName},'),
                      CustomTextBody(text: '${resource.countryName}'),
                    ],
                  ),
                  SpaceH8(),
                  CustomTextTitle(title: StringConst.MODALITY.toUpperCase()),
                  CustomTextBody(text: resource.modality),
                  SpaceH8(),
                  CustomTextTitle(title: StringConst.CAPACITY.toUpperCase()),
                  CustomTextBody(text: '${resource.capacity}'),
                  SpaceH8(),
                  CustomTextTitle(title: StringConst.DATE.toUpperCase()),
                  DateFormat('dd/MM/yyyy').format(resource.start) == '31/12/2050'
                      ? CustomTextBody(
                    text: StringConst.ALWAYS_AVAILABLE,
                  )
                      : Row(
                    children: [
                      CustomTextBody(
                          text: DateFormat('dd/MM/yyyy').format(resource.start)),
                      SpaceW4(),
                      CustomTextBody(text: '-'),
                      SpaceW4(),
                      CustomTextBody(
                          text: DateFormat('dd/MM/yyyy').format(resource.end))
                    ],
                  ),
                  SpaceH8(),
                  CustomTextTitle(title: StringConst.CONTRACT_TYPE.toUpperCase()),
                  CustomTextBody(text: resource.contractType != null && resource.contractType != ''  ? '${resource.contractType}' : 'Sin especificar' ),
                  SpaceH8(),
                  CustomTextTitle(title: StringConst.DURATION.toUpperCase()),
                  CustomTextBody(text: resource.duration),
                  SpaceH8(),
                  CustomTextTitle(title: StringConst.SALARY.toUpperCase()),
                  CustomTextBody(text: resource.salary != null && resource.salary != ''  ? '${resource.salary}' :  'Sin especificar'),
                  SpaceH8(),
                  CustomTextTitle(title: StringConst.SCHEDULE.toUpperCase()),
                  CustomTextBody(text: resource.temporality != null && resource.temporality != ''  ? '${resource.temporality}' :  'Sin especificar'),
                  SpaceH8(),
                ],
              ),
            ),

          ),
          flex: 4,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final auth = Provider.of<AuthBase>(context);
    final userId = auth.currentUser?.uid ?? '';
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    if (auth.currentUser == null) {
                      showAlertNullUser(context);
                    } else if (resource.participants.contains(userId)) {
                      removeUserToResource(context: context, userId: userId, resource: resource);
                    } else if ((resource.link == null || resource.link!.isEmpty) &&
                        (resource.contactEmail == null || resource.contactEmail!.isEmpty) &&
                        (resource.contactPhone == null || resource.contactPhone!.isEmpty)) {
                      addUserToResource(context: context, userId: userId, resource: resource);
                      setGamificationFlag(context: context, flagId: UserEnreda.FLAG_JOIN_RESOURCE);
                    } else if (resource.link != null) {
                      launchURL(resource.link!);
                    } else {
                      showContactDialog(context: context, resource: resource);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
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
                      backgroundColor:
                          MaterialStateProperty.all(resource.participants.contains(userId)
                              ? Constants.chatDarkBlue : Constants.turquoise),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ))),
                ),
              ),
              SpaceW30(),
              buildShareButton(context, resource, Constants.darkGray),
              SpaceW30(),
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
                    bottom: 2,
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
          ),
          flex: 6,
        ),
        Expanded(
          child: Container(),
          flex: 4,
        )
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, Resource resource) {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.turquoise,
                    ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.turquoise,
                    ),
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

}
