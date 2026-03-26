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
import 'package:enreda_app/app/home/resources/models/resource_metadata.dart';
import 'package:async/async.dart' show StreamGroup;
import 'package:enreda_app/services/location_cache.dart';
import 'dart:async';

class RecommendedResourcesPage extends StatefulWidget {
  @override
  State<RecommendedResourcesPage> createState() => _RecommendedResourcesPageState();
}

class _RecommendedResourcesPageState extends State<RecommendedResourcesPage> {
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
                      scrollController: ScrollController(),
                      snapshot: snapshot,
                      fitSmallerLayout: true,
                      itemBuilder: (context, resource) {
                        resource.organizerName = _metadata.organizerNames[resource.organizer] ?? '';
                        resource.organizerImage = _metadata.organizerImages[resource.organizer];
                        resource.countryName = _metadata.countryNames[resource.country] ?? '';
                        resource.provinceName = _metadata.provinceNames[resource.province] ?? '';
                        resource.cityName = _metadata.cityNames[resource.city] ?? '';
                        resource.setResourceTypeName();
                        resource.setResourceCategoryName();

                        return Container(
                          key: Key('resource-${resource.resourceId}'),
                          child: ResourceListTile(
                            resource: resource,
                            onTap: () => context.push(
                                '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                          ),
                        );
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
