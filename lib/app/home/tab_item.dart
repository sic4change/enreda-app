import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/custom_icons_icons.dart';


enum TabItem {resources, competencies, chat, account}

class TabItemData {
  const TabItemData({required this.title, required this.icon});

  final String title;
  final IconData icon;

  static Map<TabItem, TabItemData> allTabs = {
    TabItem.resources: TabItemData(title: StringConst.RESOURCES, icon: CustomIcons.recursos),
    TabItem.competencies: TabItemData(title: StringConst.COMPETENCIES, icon: CustomIcons.icon_competencies),
    TabItem.chat: TabItemData(title: 'Chat', icon: CustomIcons.chat),
    TabItem.account: TabItemData(title: 'Cuenta', icon: CustomIcons.cuenta)
  };
}