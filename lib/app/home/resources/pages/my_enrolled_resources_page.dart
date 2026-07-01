import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/company.dart';
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
import 'package:enreda_app/app/home/resources/models/resource_metadata.dart';
import 'package:async/async.dart' show StreamGroup;
import 'package:enreda_app/services/location_cache.dart';
import 'dart:async';


class MyEnrolledResourcesPage extends StatefulWidget {
  const MyEnrolledResourcesPage({Key? key}) : super(key: key);

  @override
  State<MyEnrolledResourcesPage> createState() => _MyEnrolledResourcesPageState();
}

class _MyEnrolledResourcesPageState extends State<MyEnrolledResourcesPage> {
  ResourceMetadata _metadata = ResourceMetadata();
  List<StreamSubscription> _metadataSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _getMetadata();
  }

  @override
  void dispose() {
    _metadataSubscriptions.forEach((s) => s.cancel());
    super.dispose();
  }

  void _getMetadata() async {
    final database = Provider.of<Database>(context, listen: false);
    await LocationCache.instance.warmUpAll(database);
    if (mounted) {
      setState(() {
        _metadata = ResourceMetadata.fromLists(
          countries: LocationCache.instance.countries,
          provinces: LocationCache.instance.provinces,
          cities: LocationCache.instance.allCities,
          organizers: LocationCache.instance.organizers,
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    final uid = auth.currentUser?.uid ?? '';

    return Container(
      child: StreamBuilder<UserEnreda>(
        stream: database.enredaUserStream(uid),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final user = userSnapshot.data!;
          return StreamBuilder<List<Resource>>(
            stream: database.resourcesStreamByIds(user.resourcesEnrolled),
            builder: (context, snapshot) {
              return snapshot.hasData && snapshot.data!.isNotEmpty
                  ? ListItemBuilderGrid<Resource>(
                      scrollController: ScrollController(),
                      snapshot: snapshot,
                      fitSmallerLayout: false,
                      itemBuilder: (context, resource) {
                        resource.organizerName =
                            _metadata.organizerNames[resource.organizer] ?? '';
                        resource.organizerImage =
                            _metadata.organizerImages[resource.organizer];
                        resource.countryName =
                            _metadata.countryNames[resource.country] ?? '';
                        resource.provinceName =
                            _metadata.provinceNames[resource.province] ?? '';
                        resource.cityName =
                            _metadata.cityNames[resource.city] ?? '';
                        resource.setResourceTypeName();
                        resource.setResourceCategoryName();

                        return Container(
                          key: Key('resource-${resource.resourceId}'),
                          child: ResourceListTile(
                            resource: resource,
                            onTap: () => setState(() {
                              globals.currentResource = resource;
                              MyResourcesPage.selectedIndex.value = 3;
                            }),
                          ),
                        );
                      },
                      emptyTitle: 'Sin recursos',
                      emptyMessage: 'No estás inscrito a ningún recurso',
                    )
                  : snapshot.connectionState == ConnectionState.waiting
                      ? const Padding(
                          padding:
                              EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : NoResourcesIllustration(
                          title: StringConst.NO_RESOURCES_TITLE,
                          subtitle: StringConst.NO_RESOURCES_SUBTITLE,
                          imagePath: ImagePath.NO_RESOURCES,
                        );
            },
          );
        },
      ),
    );
  }
}
