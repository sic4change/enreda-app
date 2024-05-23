import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_app/app/home/resources/pages/my_resources_page.dart';
import 'package:enreda_app/app/home/resources/pages/no_resources_ilustration.dart';
import 'package:enreda_app/app/home/resources/resource_list_tile.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../values/values.dart';
import '../../models/resource.dart';
import 'package:enreda_app/app/home/resources/global.dart' as globals;


class MyEnrolledResourcesPage extends StatefulWidget {
  const MyEnrolledResourcesPage({Key? key}) : super(key: key);

  @override
  State<MyEnrolledResourcesPage> createState() => _MyEnrolledResourcesPageState();
}

class _MyEnrolledResourcesPageState extends State<MyEnrolledResourcesPage> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return Container(
      child: StreamBuilder<List<Resource>>(
          stream: database.myResourcesStream(auth.currentUser?.uid ?? ''),
          builder: (context, snapshot) {
            return snapshot.hasData && snapshot.data!.isNotEmpty
                ? ListItemBuilderGrid<Resource>(
              scrollController: ScrollController(),
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
                                        onTap: () =>
                                            setState(() {
                                              globals.currentResource = resource;
                                              MyResourcesPage.selectedIndex.value = 3;
                                            }),
                                        // onTap: () => context.go(
                                        //     '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
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
            ) : NoResourcesIlustration(
                title: StringConst.NO_RESOURCES_TITLE,
                subtitle: StringConst.NO_RESOURCES_SUBTITLE,
                imagePath: ImagePath.NO_RESOURCES,);
          }),
    );
  }
}
