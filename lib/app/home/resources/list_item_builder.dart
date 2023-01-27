import 'package:enreda_app/app/home/resources/empty_content.dart';
import 'package:flutter/material.dart';

import '../../../utils/responsive.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemBuilder<T> extends StatelessWidget {
  const ListItemBuilder(
      {Key? key,
        required this.snapshot,
        required this.itemBuilder,
        this.emptyTitle,
        this.emptyMessage})
      : super(key: key);
  final AsyncSnapshot<List<T>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T> items = snapshot.data!;
      if (items.isNotEmpty) {
        return _build(context, items);
      } else {
        return EmptyContent(title: emptyTitle??'', message: emptyMessage??'');
      }
    } else if (snapshot.hasError) {
      return EmptyContent(
          title: 'Algo fue mal', message: 'No se pudo cargar los datos');
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _build(BuildContext context, List<T> items) {
    return LayoutBuilder(builder: (context, constraints) {
      if(constraints.maxWidth >= 650){
        return Padding(
          padding: const EdgeInsets.only(left: 150.0, right: 150.0),
          child: GridView.extent(
            maxCrossAxisExtent: 550.0,
            childAspectRatio: 1.25,
            scrollDirection: Axis.vertical,
            crossAxisSpacing: 40,
            mainAxisSpacing: 40,
            children: items
                .map((e) => itemBuilder(context, e))
                .toList(),
          ),
        );
      } else {
        return ListView.builder(
          itemCount: items.length + 2,
          itemBuilder: (context, index) {
            if (index == 0 || index == items.length + 1) {
              return Container();
            }
            return AspectRatio(
              aspectRatio: Responsive.isMobile(context) ? 0.9 : 1,
              child: Container(
                  child: itemBuilder(context, items[index - 1])),
            );
          },
        );
      }
    });
  }
}
