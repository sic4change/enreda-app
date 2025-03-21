import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'empty_content.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemBuilderGrid<T> extends StatelessWidget {
  const ListItemBuilderGrid(
      {Key? key,
      required this.snapshot,
      required this.itemBuilder,
      this.emptyTitle,
      this.emptyMessage,
      this.fitSmallerLayout = false})
      : super(key: key);
  final AsyncSnapshot<List<T>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;
  final String? emptyTitle;
  final String? emptyMessage;
  final bool? fitSmallerLayout;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T> items = snapshot.data!;
      if (items.isNotEmpty) {
        return _build(context, items);
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

  Widget _build(BuildContext context, List<T> items) {
    return LayoutBuilder(builder: (context, constraints) {
      var crossAxisCount = constraints.maxWidth < 650
          ? 1
          : constraints.maxWidth > 650 && constraints.maxWidth < 900
              ? 3
              : constraints.maxWidth > 650 && constraints.maxWidth < 1321
                  ? 4
                  : 5;
      if (fitSmallerLayout ?? false) {
        crossAxisCount = constraints.maxWidth < 650
            ? 1
            : constraints.maxWidth > 650 && constraints.maxWidth < 900
                ? 3
                : 4;
      }

      final tileWidth = (constraints.maxWidth / crossAxisCount) + 60;

      return MasonryGridView.count(
        controller: ScrollController(),
        shrinkWrap: constraints.maxWidth < 650 ? true : false,
        padding: EdgeInsets.all(4.0),
        itemCount: items.length,
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        itemBuilder: (context, index) {
          return Container(
              height: index.isEven || constraints.maxWidth < 650
                  ? tileWidth / 1.3
                  : tileWidth * 1.5,
              child: itemBuilder(context, items[index]));
        },
      );
    });
  }
}
