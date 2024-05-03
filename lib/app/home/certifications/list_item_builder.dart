import 'package:enreda_app/app/home/resources/empty_content.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

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
        return _build(items, context);
      } else {
        return EmptyContent(
            title: emptyTitle ?? '', message: emptyMessage ?? '');
      }
    } else if (snapshot.hasError) {
      return EmptyContent(
          title: StringConst.SEARCH_WARNING, message: StringConst.SEARCH_WARNING_DESCRIPTION);
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _build(List<T> items, BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
        child: GridView.extent(
          maxCrossAxisExtent: 550.0,
          childAspectRatio: 2.0,
          scrollDirection: Axis.vertical,
          crossAxisSpacing: 40,
          mainAxisSpacing: 40,
          children: items.map((e) => itemBuilder(context, e)).toList(),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: items.length + 2,
        itemBuilder: (context, index) {
          if (index == 0 || index == items.length + 1) {
            return Container();
          }
          return Container(
              padding: EdgeInsets.symmetric(vertical: 0),
              child: itemBuilder(context, items[index - 1]));
        },
      );
    }
    ;
  }

// Widget _build(List<T> items) {
//   return ListView.separated(
//
//       itemCount: items.length + 2,
//       itemBuilder: (context, index) {
//         if (index == 0 || index == items.length + 1) {
//           return Container();
//         }
//         return Container(
//           padding: EdgeInsets.symmetric(vertical: 16.0),
//             child: itemBuilder(context, items[index - 1])
//         );
//       },
//       separatorBuilder: (context, index) => Divider(
//             height: 0.0,
//           ));
// }
}
