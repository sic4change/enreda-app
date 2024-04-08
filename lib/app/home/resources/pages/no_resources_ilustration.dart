import 'package:enreda_app/app/home/cupertino_scaffold.dart';
import 'package:enreda_app/app/home/web_home_scafold.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';

class NoResourcesIlustration extends StatelessWidget {
  const NoResourcesIlustration(
      {Key? key, required this.title, required this.imagePath})
      : super(key: key);
  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: 300.0,
            ),
            SpaceH20(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall
                  ?.copyWith(fontSize: 22.0, color: Constants.deleteRed),
            ),
            SpaceH20(),
            TextButton(
              onPressed: () {
                Responsive.isDesktop(context)
                    ? WebHomeScaffold.selectedIndex.value = 0
                    : CupertinoScaffold.controller.index = 0;
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'VER RECURSOS',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Constants.white,
                  ),
                ),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Constants.turquoise),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ))),
            ),
          ],
        ),
      ),
    );
  }
}
