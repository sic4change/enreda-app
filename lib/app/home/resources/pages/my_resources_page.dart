import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/resourcePicture.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_app/app/home/resources/pages/no_resources_ilustration.dart';
import 'package:enreda_app/app/home/resources/resource_list_tile.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/main_container.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class MyResourcesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildContents(context);
  }

  Widget _buildContents(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return RoundedContainer(
      contentPadding: Responsive.isMobile(context) ?
      EdgeInsets.all(Sizes.mainPadding) :
      EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
      child: Stack(
        children: [
          CustomTextMediumBold(text: StringConst.MY_RESOURCES),
          Container(
            margin: EdgeInsets.only(top: Sizes.kDefaultPaddingDouble * 2.5),
            child: StreamBuilder<List<Resource>>(
                stream: database.myResourcesStream(auth.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  return snapshot.hasData && snapshot.data!.isNotEmpty
                      ? ListItemBuilderGrid<Resource>(
                          snapshot: snapshot,
                          fitSmallerLayout: false,
                          itemBuilder: (context, resource) {
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
                                resource.setResourceTypeName();
                                resource.setResourceCategoryName();
                                return StreamBuilder<Country>(
                                    stream: database.countryStream(resource.country),
                                    builder: (context, snapshot) {
                                      final country = snapshot.data;
                                      resource.countryName =
                                      country == null ? '' : country.name;
                                      return StreamBuilder<Province>(
                                        stream: database
                                            .provinceStream(resource.province),
                                        builder: (context, snapshot) {
                                          final province = snapshot.data;
                                          resource.provinceName =
                                          province == null ? '' : province.name;
                                          return StreamBuilder<City>(
                                              stream:
                                              database.cityStream(resource.city),
                                              builder: (context, snapshot) {
                                                final city = snapshot.data;
                                                resource.cityName =
                                                city == null ? '' : city.name;
                                                return Container(
                                                  key: Key('resource-${resource.resourceId}'),
                                                  child: ResourceListTile(
                                                    resource: resource,
                                                    onTap: () => context.go(
                                                        '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                                                  ),
                                                );
                                              });
                                        },
                                      );
                                    });
                              },
                            );
                          },
                          emptyTitle: 'Sin recursos',
                          emptyMessage: 'No estás inscrito a ningún recurso',
                        )
                      : snapshot.connectionState == ConnectionState.active
                          ? NoResourcesIlustration(title: '¡Todavía no te has inscrito a ningún recurso!', imagePath: ImagePath.LEARNING_GIRL,)
                          : Center(child: CircularProgressIndicator());
                }),
          ),
        ],
      ),
    );
  }
}
