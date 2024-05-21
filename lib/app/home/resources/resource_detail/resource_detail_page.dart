import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/contact.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/resources/build_share_button.dart';
import 'package:enreda_app/app/home/resources/resource_actions.dart';
import 'package:enreda_app/app/home/resources/resource_detail/box_item_data.dart';
import 'package:enreda_app/app/home/resources/streams/competencies_by_resource.dart';
import 'package:enreda_app/app/home/resources/streams/interests_by_resource.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_app/app/home/resources/global.dart' as globals;

import '../../models/userEnreda.dart';

class ResourceDetailPage extends StatefulWidget {
  const ResourceDetailPage({Key? key}) : super(key: key);

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  TextEditingController _textFieldController = TextEditingController();
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
    return _buildResourcePage(context, globals.currentResource! );
  }

  Widget _buildResourcePage(BuildContext context, Resource resource) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<Resource>(
        stream: database.resourceStream(resource.resourceId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            Resource resource = snapshot.data!;
            resource.setResourceTypeName();
            resource.setResourceCategoryName();
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
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                resource.setResourceTypeName();
                resource.setResourceCategoryName();
                return StreamBuilder<Country>(
                    stream: database.countryStream(resource.country),
                    builder: (context, snapshot) {
                      final country = snapshot.data;
                      resource.countryName = country == null ? '' : country.name;
                      resource.province ?? "";
                      resource.city ?? "";
                      return StreamBuilder<Province>(
                        stream: database.provinceStream(resource.province),
                        builder: (context, snapshot) {
                          final province = snapshot.data;
                          resource.provinceName = province == null ? '' : province.name;
                          return StreamBuilder<City>(
                              stream: database
                                  .cityStream(resource.city!),
                              builder: (context, snapshot) {
                                final city = snapshot.data;
                                resource.cityName = city == null ? '' : city.name;
                                return Responsive.isMobile(context) ? _buildResourceDetailMobile(context, resource)
                                    : _buildResourceDetailWeb(context, resource);
                              });
                        },
                      );
                    });
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _buildResourceDetailWeb(BuildContext context, Resource resource) {
    final auth = Provider.of<AuthBase>(context);
    final userId = auth.currentUser?.uid ?? '';
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSizeTitle = responsiveSize(context, 14, 22, md: 18);
    double fontSizePromotor = responsiveSize(context, 12, 16, md: 14);
    return SingleChildScrollView(
      child: Container(
        margin: MediaQuery.of(context).size.width >= 1200 ?
          EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          border: Border.all(
              color: AppColors.greyLight2.withOpacity(0.2),
              width: 1),
          borderRadius: BorderRadius.circular(Sizes.MARGIN_16),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImagePath.RECTANGLE_RESOURCE),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(Sizes.MARGIN_16),
                    bottomLeft: Radius.circular(Sizes.MARGIN_16)),
              ),
              margin: Responsive.isMobile(context) ? const EdgeInsets.all(0.0) : const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                  children: [
                    Responsive.isMobile(context) ? SpaceH8() : SpaceH20(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 60,),
                        Spacer(),
                        Align(
                          alignment: Alignment.topCenter,
                          child: resource.organizerImage == null || resource.organizerImage!.isEmpty ? Container() :
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1.0, color: AppColors.greyLight),
                                  borderRadius: BorderRadius.circular(100,),
                                  color: AppColors.greyLight),
                              child: CircleAvatar(
                                radius: Responsive.isMobile(context) ? 28 : 40,
                                backgroundColor: AppColors.white,
                                backgroundImage: NetworkImage(resource.organizerImage!),
                              ),
                            ),
                        ),
                        Spacer(),
                        Container(
                            width: 60,
                            child: _buildMenuButton(context, resource))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 30.0, left: 30.0),
                      child: Text(
                        resource.title,
                        textAlign: TextAlign.center,
                        maxLines:
                        Responsive.isMobile(context) ? 2 : 1,
                        style: textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.2,
                          color: AppColors.white,
                          height: 1.5,
                          fontWeight: FontWeight.w300,
                          fontSize: fontSizeTitle,
                        ),
                      ),
                    ),
                    SpaceH4(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          resource.promotor != null
                              ? resource.promotor != ""
                              ? resource.promotor!
                              : resource.organizerName!
                              : resource.organizerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            letterSpacing: 1.2,
                            fontSize: fontSizePromotor,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        buildShare(context, resource, AppColors.darkGray, AppColors.white),
                        SpaceW8(),
                        IconButton(
                          icon: (resource.likes.contains(userId))
                              ? FaIcon(FontAwesomeIcons.solidHeart) : FaIcon(FontAwesomeIcons.heart),
                          tooltip: 'Me gusta',
                          color: (resource.likes.contains(userId))
                              ? AppColors.red : AppColors.white,
                          iconSize: 30,
                          onPressed: () {
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
                        ),
                        SpaceW16(),
                      ],
                    )
                  ]
              ),
            ),
            Padding(
              padding: Responsive.isMobile(context) ? const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0) :
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: _buildBoxes(resource),
            ),
            _buildDetailResource(context, resource),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceDetailMobile(BuildContext context, Resource resource) {
    final auth = Provider.of<AuthBase>(context);
    final userId = auth.currentUser?.uid ?? '';
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSizeTitle = responsiveSize(context, 14, 22, md: 18);
    double fontSizePromotor = responsiveSize(context, 12, 16, md: 14);
    return SingleChildScrollView(
      child: Container(
        margin: MediaQuery.of(context).size.width >= 1200 ?
        EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          border: Border.all(
              color: Responsive.isMobile(context) ? Colors.transparent :AppColors.greyLight2.withOpacity(0.2),
              width: Responsive.isMobile(context) ? 0 : 1),
          borderRadius: BorderRadius.circular(Sizes.MARGIN_16),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImagePath.RECTANGLE_RESOURCE),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Container(
                          width: 150,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildShare(context, resource, AppColors.darkGray, AppColors.white),
                              IconButton(
                                icon: (resource.likes.contains(userId))
                                    ? FaIcon(FontAwesomeIcons.solidHeart) : FaIcon(FontAwesomeIcons.heart),
                                tooltip: 'Me gusta',
                                color: (resource.likes.contains(userId))
                                    ? AppColors.red : AppColors.white,
                                iconSize: 20,
                                onPressed: () {
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
                              ),
                              SpaceW4(),
                              _buildMenuButton(context, resource),
                            ],
                          ))
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        Align(
                          alignment: Alignment.topCenter,
                          child: resource.organizerImage == null || resource.organizerImage!.isEmpty ? Container() :
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 1.0, color: AppColors.greyLight),
                                borderRadius: BorderRadius.circular(100,),
                                color: AppColors.greyLight),
                            child: CircleAvatar(
                              radius: Responsive.isMobile(context) ? 28 : 40,
                              backgroundColor: AppColors.white,
                              backgroundImage: NetworkImage(resource.organizerImage!),
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 30.0, left: 30.0),
                      child: Text(
                        resource.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines:
                        Responsive.isMobile(context) ? 2 : 1,
                        style: textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.2,
                          color: AppColors.white,
                          height: 1.5,
                          fontWeight: FontWeight.w300,
                          fontSize: fontSizeTitle,
                        ),
                      ),
                    ),
                    SpaceH4(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          resource.promotor != null
                              ? resource.promotor != ""
                              ? resource.promotor!
                              : resource.organizerName!
                              : resource.organizerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            letterSpacing: 1.2,
                            fontSize: fontSizePromotor,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Responsive.isMobile(context) ? Container() : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        buildShare(context, resource, AppColors.darkGray, AppColors.white),
                        SpaceW8(),
                        IconButton(
                          icon: (resource.likes.contains(userId))
                              ? FaIcon(FontAwesomeIcons.solidHeart) : FaIcon(FontAwesomeIcons.heart),
                          tooltip: 'Me gusta',
                          color: (resource.likes.contains(userId))
                              ? AppColors.red : AppColors.white,
                          iconSize: 30,
                          onPressed: () {
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
                        ),
                        SpaceW16(),
                      ],
                    ),
                    SpaceH20(),
                    _buildBoxes(resource),
                    Responsive.isMobile(context)  ? _buildButton(context, resource) : Container(),
                    SpaceH20(),
                  ]
              ),
            ),
            Responsive.isMobile(context) ? Container() : Padding(
              padding: Responsive.isMobile(context) ? const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0) :
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: _buildBoxes(resource),
            ),
            _buildDetailResource(context, resource),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailResource(BuildContext context, Resource resource) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.FORM_DESCRIPTION.toUpperCase(),
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.turquoiseBlue,
            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              resource.description,
              textAlign: TextAlign.left,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.greyTxtAlt,
                height: 1.5,
              ),
            ),
          ),
          _buildInformationResource(context, resource),
        ],
      ),
    );
  }

  Widget _buildInformationResource(BuildContext context, Resource resource) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.FORM_INTERESTS.toUpperCase(),
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.turquoiseBlue,
          ),
        ),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InterestsByResource(interestsIdList: resource.interests!,),
        ),
        const SizedBox(height: 10,),
        Text(
          StringConst.COMPETENCIES.toUpperCase(),
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.turquoiseBlue,
          ),
        ),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: CompetenciesByResource(competenciesIdList: resource.competencies!,),
        ),
        const SizedBox(height: 10,),
        Text(
          StringConst.AVAILABLE.toUpperCase(),
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.turquoiseBlue,
          ),
        ),
        Container(
            width: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: AppColors.greyLight2.withOpacity(0.2),
                  width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.only(top: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: resource.status == "No disponible" ? Colors.red : Colors.lightGreenAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 8),
                CustomTextBody(text: resource.status),
              ],
            )),
        const SizedBox(height: 30,),
        _buildButton(context, resource),
        Responsive.isMobile(context) ?  SizedBox(height: 50,) : Container(),
      ],
    );
  }

  Widget _buildButton(BuildContext context, Resource resource) {
    final auth = Provider.of<AuthBase>(context);
    final userId = auth.currentUser?.uid ?? '';
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
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
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
            child: Text(
              resource.participants.contains(userId)
                  ? StringConst.QUIT_RESOURCE
                  : StringConst.JOIN_RESOURCE,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: resource.participants.contains(userId) ? Constants.darkGray : Constants.white,
              ),
            ),
          ),
          style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(resource.participants.contains(userId)
                  ? AppColors.grey70 : Constants.turquoise),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ))),
        ),
      ],
    );
  }

  Widget _buildBoxes(Resource resource) {
    List<BoxItemData> boxItemData = [
      BoxItemData(
          icon: Image.asset(Responsive.isMobile(context) ? ImagePath.ICON_MODALITY_YELLOW
              : ImagePath.ICON_MODALITY),
          title: StringConst.RESOURCE_TYPE,
          contact: '${resource.resourceCategoryName}'
      ),
      BoxItemData(
        icon: Image.asset(Responsive.isMobile(context) ? ImagePath.ICON_PLACE_YELLOW
            : ImagePath.ICON_PLACE),
        title: StringConst.LOCATION,
        contact: '${resource.countryName}',
      ),
      BoxItemData(
        icon: Image.asset(Responsive.isMobile(context) ? ImagePath.ICON_MODALITY_YELLOW
            : ImagePath.ICON_MODALITY),
        title: StringConst.MODALITY,
        contact: '${resource.modality}',
      ),
      BoxItemData(
        icon: Image.asset(Responsive.isMobile(context) ? ImagePath.ICON_SEATS_YELLOW
            : ImagePath.ICON_SEATS),
        title: StringConst.CAPACITY,
        contact: '${resource.capacity}',
      ),
      BoxItemData(
        icon: Image.asset(Responsive.isMobile(context) ? ImagePath.ICON_DATE_YELLOW
            : ImagePath.ICON_DATE),
        title: StringConst.DATE,
        contact: '${DateFormat('dd/MM/yyyy').format(resource.start)} - ${DateFormat('dd/MM/yyyy').format(resource.end)}',
      ),
      BoxItemData(
        icon: Image.asset(Responsive.isMobile(context) ? ImagePath.ICON_CONTRACT_YELLOW
            : ImagePath.ICON_CONTRACT),
        title: StringConst.CONTRACT_TYPE,
        contact: resource.contractType != null && resource.contractType != ''  ? '${resource.contractType}' : 'Sin especificar',
      ),
      BoxItemData(
        icon: Image.asset(Responsive.isMobile(context) ? ImagePath.ICON_CONTRACT_YELLOW
            : ImagePath.ICON_CONTRACT),
        title: StringConst.FORM_SCHEDULE,
        contact: resource.temporality != null && resource.temporality != ''  ? '${resource.temporality}' :  'Sin especificar',
      ),
      BoxItemData(
        icon: Image.asset(Responsive.isMobile(context) ? ImagePath.ICON_CURRENCY_YELLOW
            : ImagePath.ICON_CURRENCY),
        title: StringConst.SALARY,
        contact: resource.salary != null && resource.salary != ''  ? '${resource.salary}' :  'Sin especificar',
      ),
    ];
    const int crossAxisCount = 2; // The number of columns in the grid
    const double maxCrossAxisExtent = 250;
    const double mainAxisExtent = 70;
    const double childAspectRatio = 6 / 2;
    const double crossAxisSpacing = 10;
    const double mainAxisSpacing = 10;
    int rowCount = (boxItemData.length / crossAxisCount).ceil();
    double gridHeight = rowCount * mainAxisExtent + (rowCount - 1) * mainAxisSpacing;
    double gridHeightD = rowCount * mainAxisExtent + (rowCount - 15) * mainAxisSpacing;
    return Responsive.isMobile(context) ?
      SizedBox(
        height: gridHeight * 0.85,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: boxItemData.length,
            itemBuilder: (BuildContext context, index) {
              return BoxItem(
                icon: boxItemData[index].icon,
                title: boxItemData[index].title,
                contact: boxItemData[index].contact,
              );
            }),
      ) :
      SizedBox(
        height: Responsive.isDesktop(context) ? gridHeightD : gridHeight,
        child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxCrossAxisExtent,
                mainAxisExtent: mainAxisExtent,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing),
            itemCount: boxItemData.length,
            itemBuilder: (BuildContext context, index) {
              return BoxItem(
                icon: boxItemData[index].icon,
                title: boxItemData[index].title,
                contact: boxItemData[index].contact,
              );
            }),
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
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.red,
                fontWeight: FontWeight.w700,
              ),),
          );
        });
      },
      child: Icon(
        Icons.more_vert,
        color: Constants.white,
        size: Responsive.isMobile(context) ? 23.0 : 30.0,
      ),
    );
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
              style: textTheme.bodySmall?.copyWith(
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
              style: textTheme.bodySmall?.copyWith(
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
              style: textTheme.bodySmall?.copyWith(
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
                        style: textTheme.bodySmall?.copyWith(
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
                        style: textTheme.bodySmall?.copyWith(
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

  Future<void> _countUserAccess() async {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (auth.currentUser != null) {
      final user = await database.userEnredaStreamByUserId(auth.currentUser!.uid).first;
      database.setUserEnreda(user.copyWith(resourcesAccessCount: user.resourcesAccessCount! + 1));
    }
  }

}
