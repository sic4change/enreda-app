import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/resources/streams/wrap_builder_list.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InterestsByResource extends StatelessWidget {
  const InterestsByResource({super.key, required this.interestsIdList});

  final List<String?> interestsIdList;

  @override
  Widget build(BuildContext context) {
    return _buildContents(context);
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Interest>>(
        stream: database.interestStream(),
        builder: (context, snapshot) {
          return snapshot.hasData && snapshot.data!.isNotEmpty
              ? WrapBuilderList<Interest>(
            emptyTitle: 'Sin intereses',
            emptyMessage: 'El recurso no tiene intereses',
            snapshot: snapshot,
            itemBuilder: (context, interest) {
              for (var interestId in interestsIdList) {
                if (interest.interestId == interestId) {
                  return Container(
                      key: Key(
                          'resource-${interest.interestId}'),
                      child: Container(
                          margin: const EdgeInsets.only(left: 0, right: 4, top: 4, bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: AppColors
                                    .greyLight2
                                    .withOpacity(0.2),
                                width: 1),
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets
                                .symmetric(
                                vertical: 4.0,
                                horizontal: 8),
                            child: CustomText(
                                title: interest.name),
                          )));
                }

              }
              return Container();
            },

          )
              : snapshot.connectionState == ConnectionState.active
              ? CustomTextTitle(
              title: '¡El recurso aun no tiene intereses!')
              : const Center(child: CircularProgressIndicator());
          ;
        });
  }

}
