import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/empty_content.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class CompetenciesItemBuilder<T> extends StatelessWidget {
  const CompetenciesItemBuilder(
      {Key? key,
        required this.user,
      required this.snapshot,
      required this.itemBuilder,
      this.emptyTitle,
      this.emptyMessage,
      this.fitSmallerLayout = false})
      : super(key: key);
  final UserEnreda? user;
  final AsyncSnapshot<List<Competency>> snapshot;
  final ItemWidgetBuilder<Competency> itemBuilder;
  final String? emptyTitle;
  final String? emptyMessage;
  final bool? fitSmallerLayout;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      List<Competency> items = snapshot.data!;
      if (user != null) {
        final competenciesIds = user!.competencies.keys.toList();
        items = items.where((competency) => competenciesIds.any((id) => competency.id == id )).toList();
      }

      if (items.isNotEmpty) {
        return _build(items, context);
      } else {
        return EmptyContent(
            title: emptyTitle ?? '', message: emptyMessage ?? '');
      }
    } else if (snapshot.hasError) {
      return EmptyContent(
          title: StringConst.SOMETHING_WRONG, message: StringConst.CANNOT_LOAD_DATA);
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _build(List<Competency> items, BuildContext context) {

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
              padding: Responsive.isDesktop(context)? EdgeInsets.symmetric(horizontal: 12.0) : EdgeInsets.only(top: 10.0),
              child: Wrap(
                children: items.map((c) => itemBuilder(context, c)).toList(),
                spacing: Responsive.isMobile(context) ? 10 : 15.0,
                runSpacing: Responsive.isMobile(context) ? 10 : 15.0,
              ),
            ),
    );
  }
}
