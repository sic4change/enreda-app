import 'package:enreda_app/app/home/resources/empty_content.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class CompetenciesItemBuilderHorizontal<T> extends StatelessWidget {
  const CompetenciesItemBuilderHorizontal(
      {Key? key,
        this.snapshot,
        this.itemBuilder,
        this.emptyTitle,
        this.emptyMessage,
        this.scrollController})
      : super(key: key);
  final AsyncSnapshot<List<T>>? snapshot;
  final ItemWidgetBuilder<T>? itemBuilder;
  final String? emptyTitle;
  final String? emptyMessage;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (snapshot!.hasData) {
      final List<T> items = snapshot!.data!;
      if (items.isNotEmpty) {
        return _build(items, context);
      } else {
        return EmptyContent(title: emptyTitle, message: emptyMessage);
      }
    } else if (snapshot!.hasError) {
      return EmptyContent(
          title: StringConst.SOMETHING_WRONG, message: StringConst.CANNOT_LOAD_DATA);
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _build(List<T> items, BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4.0),
      itemCount: items.length,
      scrollDirection: Axis.horizontal,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.transparent,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: itemBuilder!(context, items[index]),
            )
        );
      },
    );
  }
}
