import 'package:enreda_app/app/home/competencies/competencies_page_mobile.dart';
import 'package:enreda_app/app/home/competencies/competencies_page_web.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';

class CompetenciesPage extends StatelessWidget {
  const CompetenciesPage({Key? key, required this.showChatNotifier}) : super(key: key);
  final ValueNotifier<bool> showChatNotifier;

  @override
  Widget build(BuildContext context) {
    return Responsive.isDesktop(context)? CompetenciesPageWeb(showChatNotifier: showChatNotifier) : CompetenciesPageMobile(showChatNotifier: showChatNotifier);
  }
}
