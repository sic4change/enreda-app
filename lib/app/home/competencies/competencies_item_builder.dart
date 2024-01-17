import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/empty_content.dart';
import 'package:enreda_app/utils/responsive.dart';
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
          title: 'Algo fue mal', message: 'No se pudo cargar los datos');
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _build(List<Competency> items, BuildContext context) {

    final padding = Responsive.isDesktop(context)? 12.0: 0.0;
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Wrap(
                children: items.map((c) => itemBuilder(context, c)).toList(),
                spacing: 15.0,
                runSpacing: 15.0,
              ),
            ),
    );
  }
}
