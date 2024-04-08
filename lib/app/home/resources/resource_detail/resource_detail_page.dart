import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/resources/build_share_button.dart';
import 'package:enreda_app/app/home/resources/resource_detail/box_item_data.dart';
import 'package:enreda_app/app/home/resources/streams/competencies_by_resource.dart';
import 'package:enreda_app/app/home/resources/streams/interests_by_resource.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_app/app/home/resources/global.dart' as globals;

class ResourceDetailPage extends StatefulWidget {
  const ResourceDetailPage({Key? key}) : super(key: key);

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {

  @override
  Widget build(BuildContext context) {
    return _buildResourcePage(context, globals.currentResource! );
  }

  Widget _buildResourcePage(BuildContext context, Resource resource) {
    List<String> interestsLocal = [];
    List<String> competenciesLocal = [];
    Set<Interest> selectedInterests = {};
    Set<Competency> selectedCompetencies = {};
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
            return StreamBuilder<SocialEntity>(
              stream: database.socialEntityStream(resource.organizer),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final organization = snapshot.data;
                globals.organizerCurrentResource = organization;
                resource.organizerName =
                organization == null ? '' : organization.name;
                resource.organizerImage =
                organization == null ? '' : organization.photo;
                interestsLocal = resource.interests ?? [];
                competenciesLocal = resource.competencies ?? [];
                globals.interestsCurrentResource = resource.interests ?? [];
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
                                  .cityStream(resource.city),
                              builder: (context, snapshot) {
                                final city = snapshot.data;
                                resource.cityName = city == null ? '' : city.name;
                                return StreamBuilder<List<Interest>>(
                                    stream: database.resourcesInterestsStream(interestsLocal),
                                    builder: (context, snapshotInterest) {
                                      if (snapshotInterest.hasData) {
                                        selectedInterests = snapshotInterest.data!.toSet();
                                        globals.selectedInterestsCurrentResource = snapshotInterest.data!.toSet();
                                        globals.interestsNamesCurrentResource =
                                            selectedInterests.map((item) => item.name).join(' / ');
                                        return StreamBuilder<List<Competency>>(
                                            stream: database.resourcesCompetenciesStream(competenciesLocal),
                                            builder: (context, snapshotCompetencies) {
                                              if(!snapshotCompetencies.hasData) {
                                                selectedCompetencies = {};
                                                globals.selectedCompetenciesCurrentResource = {};
                                                globals.competenciesNamesCurrentResource = '';
                                                return _buildResourceDetail(context, resource);
                                              }
                                              if (snapshotCompetencies.hasData) {
                                                selectedCompetencies = snapshotCompetencies.data!.toSet();
                                                globals.selectedCompetenciesCurrentResource = snapshotCompetencies.data!.toSet();
                                                globals.competenciesNamesCurrentResource =
                                                    selectedCompetencies.map((item) => item.name).join(' / ');
                                                return _buildResourceDetail(context, resource);
                                              }
                                              return Container();
                                            }
                                        );
                                      }
                                      return Container();
                                    });
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

  Widget _buildResourceDetail(BuildContext context, Resource resource) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSizeTitle = responsiveSize(context, 14, 22, md: 18);
    double fontSizePromotor = responsiveSize(context, 12, 16, md: 14);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: Responsive.isMobile(context) ||
                Responsive.isTablet(context) ||
                Responsive.isDesktopS(context)
                ? Axis.vertical
                : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                    ),
                    decoration: BoxDecoration(
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
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                              children: [
                                Responsive.isMobile(context)
                                    ? SpaceH8()
                                    : SpaceH20(),
                                resource.organizerImage == null ||
                                    resource.organizerImage!.isEmpty
                                    ? Container()
                                    : Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.0, color: AppColors.greyLight),
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          color: AppColors.greyLight),
                                      child: CircleAvatar(
                                        radius:
                                        Responsive.isMobile(context) ? 28 : 40,
                                        backgroundColor: AppColors.white,
                                        backgroundImage:
                                        NetworkImage(resource.organizerImage!),
                                      ),
                                    ),
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
                                    buildShare(context, resource, AppColors.darkGray),
                                    SizedBox(width: 10),
                                  ],
                                )
                              ]
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            child: _buildBoxes(resource),
                          ),
                        ),
                        Flex(
                          direction: Responsive.isMobile(context) ||
                              Responsive.isTablet(context) ||
                              Responsive.isDesktopS(context)
                              ? Axis.vertical
                              : Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: Responsive.isMobile(context) ||
                                    Responsive.isTablet(context) ||
                                    Responsive.isDesktopS(context)
                                    ? 0
                                    : 4,
                                child: _buildDetailResource(
                                    context, resource)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailResource(BuildContext context, Resource resource) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(20.0),
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
                CustomTextBody(text: resource.status!),
              ],
            )),
        const SizedBox(height: 30,),
      ],
    );
  }

  Widget _buildBoxes(Resource resource) {
    List<BoxItemData> boxItemData = [
      BoxItemData(
          icon: Icons.card_travel,
          title: StringConst.RESOURCE_TYPE,
          contact: '${resource.resourceCategoryName}'
      ),
      BoxItemData(
        icon: Icons.location_on_outlined,
        title: StringConst.LOCATION,
        contact: '${resource.countryName}',
      ),
      BoxItemData(
        icon: Icons.card_travel,
        title: StringConst.MODALITY,
        contact: '${resource.modality}',
      ),
      BoxItemData(
        icon: Icons.people,
        title: StringConst.CAPACITY,
        contact: '${resource.capacity}',
      ),
      BoxItemData(
        icon: Icons.calendar_month_outlined,
        title: StringConst.DATE,
        contact: '${DateFormat('dd/MM/yyyy').format(resource.start!)} - ${DateFormat('dd/MM/yyyy').format(resource.end!)}',
      ),
      BoxItemData(
        icon: Icons.list_alt,
        title: StringConst.CONTRACT_TYPE,
        contact: resource.contractType != null && resource.contractType != ''  ? '${resource.contractType}' : 'Sin especificar',
      ),
      BoxItemData(
        icon: Icons.alarm,
        title: StringConst.FORM_SCHEDULE,
        contact: resource.temporality != null && resource.temporality != ''  ? '${resource.temporality}' :  'Sin especificar',
      ),
      BoxItemData(
        icon: Icons.currency_exchange,
        title: StringConst.SALARY,
        contact: resource.salary != null && resource.salary != ''  ? '${resource.salary}' :  'Sin especificar',
      ),
    ];
    const int crossAxisCount = 2; // The number of columns in the grid
    const double maxCrossAxisExtent = 250;
    const double mainAxisExtent = 62;
    const double childAspectRatio = 6 / 2;
    const double crossAxisSpacing = 10;
    const double mainAxisSpacing = 10;
    int rowCount = (boxItemData.length / crossAxisCount).ceil();
    double gridHeight = rowCount * mainAxisExtent + (rowCount - 1) * mainAxisSpacing;
    double gridHeightD = rowCount * mainAxisExtent + (rowCount - 15) * mainAxisSpacing;
    return SizedBox(
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
}
