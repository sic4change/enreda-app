import 'package:enreda_app/app/home/resources/empty_content.dart';
import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemBuilder<T> extends StatelessWidget {
  const ListItemBuilder({Key? key,
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
    return ListView.builder(
      controller: ScrollController(),
      padding: EdgeInsets.symmetric(vertical: 0),
      reverse: true,
      itemCount: snapshot.data?.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: itemBuilder(context, items[index]));
      },
    );
  }
}
