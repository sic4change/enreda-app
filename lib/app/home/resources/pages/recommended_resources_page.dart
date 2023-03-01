import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/empty_content.dart';
import 'package:enreda_app/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_app/app/home/resources/resource_list_tile.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RecommendedResourcesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildContents(context);
  }

  Widget _buildContents(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    if (auth.currentUser == null) {
      return EmptyContent(
        title: 'Sin recursos',
        message: 'No tenemos recursos recomendados basados en tus intereses',
      );
    } else {
      return StreamBuilder<List<UserEnreda>>(
          stream: database.userStream(auth.currentUser!.email),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final user = snapshot.data![0];
              return StreamBuilder<List<Resource>>(
                  stream: database.recommendedResourcesStream(user),
                  builder: (context, snapshot) {
                    return ListItemBuilderGrid<Resource>(
                      snapshot: snapshot,
                      fitSmallerLayout: true,
                      itemBuilder: (context, resource) {
                        if (resource.organizerType == 'Organización') {
                          return StreamBuilder<Organization>(
                            stream:
                                database.organizationStream(resource.organizer),
                            builder: (context, snapshot) {
                              final organization = snapshot.data;
                              resource.organizerName =
                                  organization == null ? '' : organization.name;
                              resource.organizerImage = organization == null
                                  ? ''
                                  : organization.photo;
                              resource.setResourceTypeName();
                              resource.setResourceCategoryName();
                              return StreamBuilder<Country>(
                                  stream:
                                      database.countryStream(resource.country),
                                  builder: (context, snapshot) {
                                    final country = snapshot.data;
                                    resource.countryName =
                                        country == null ? '' : country.name;
                                    return StreamBuilder<Province>(
                                      stream: database
                                          .provinceStream(resource.province),
                                      builder: (context, snapshot) {
                                        final province = snapshot.data;
                                        resource.provinceName = province == null
                                            ? ''
                                            : province.name;
                                        return StreamBuilder<City>(
                                            stream: database
                                                .cityStream(resource.city),
                                            builder: (context, snapshot) {
                                              final city = snapshot.data;
                                              resource.cityName =
                                                  city == null ? '' : city.name;
                                              return Container(
                                                key: Key(
                                                    'resource-${resource.resourceId}'),
                                                child: ResourceListTile(
                                                  resource: resource,
                                                  onTap: () => context.push(
                                                      '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                                                ),
                                              );
                                            });
                                      },
                                    );
                                  });
                            },
                          );
                        } else {
                          return StreamBuilder<UserEnreda>(
                            stream: database.mentorStream(resource.organizer),
                            builder: (context, snapshot) {
                              final mentor = snapshot.data;
                              resource.organizerName = mentor == null
                                  ? ''
                                  : '${mentor.firstName} ${mentor.lastName} ';
                              resource.organizerImage =
                                  mentor == null ? '' : mentor.photo;
                              resource.setResourceTypeName();
                              resource.setResourceCategoryName();
                              return StreamBuilder<Country>(
                                  stream:
                                      database.countryStream(resource.country),
                                  builder: (context, snapshot) {
                                    final country = snapshot.data;
                                    resource.countryName =
                                        country == null ? '' : country.name;
                                    return StreamBuilder<Province>(
                                      stream: database
                                          .provinceStream(resource.province),
                                      builder: (context, snapshot) {
                                        final province = snapshot.data;
                                        resource.provinceName = province == null
                                            ? ''
                                            : province.name;
                                        return StreamBuilder<City>(
                                            stream: database
                                                .cityStream(resource.city),
                                            builder: (context, snapshot) {
                                              final city = snapshot.data;
                                              resource.cityName =
                                                  city == null ? '' : city.name;
                                              return Container(
                                                key: Key(
                                                    'resource-${resource.resourceId}'),
                                                child: ResourceListTile(
                                                  resource: resource,
                                                  onTap: () => context.push(
                                                      '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                                                ),
                                              );
                                            });
                                      },
                                    );
                                  });
                            },
                          );
                        }
                      },
                      emptyTitle: 'Sin recursos',
                      emptyMessage:
                          'No tenemos recursos recomendados basados en tus intereses',
                    );
                  });
            } else {
              return Container(
                height: 0.0,
                width: 0.0,
              );
            }
          });
    }
  }
}
