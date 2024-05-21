import 'package:enreda_app/app/home/contact/menu_item.dart';
import 'package:enreda_app/app/home/contact/menu_items.dart';
import 'package:enreda_app/app/home/contact/on_selected.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ActionButtonsByRole extends StatefulWidget {
  const ActionButtonsByRole({Key? key, required  this.userEnreda}) : super(key: key);
  final UserEnreda userEnreda;

  @override
  State<ActionButtonsByRole> createState() => _ActionButtonsByRoleState();
}

class _ActionButtonsByRoleState extends State<ActionButtonsByRole> {

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuItem>(
      icon: _buildMyUserPhoto(context, widget.userEnreda.profilePic!.src),
      offset: Offset.fromDirection(1.5, 60),
      iconSize: 30,
      tooltip: StringConst.ACCESS,
      constraints: BoxConstraints(
        minWidth: 200,
        maxWidth: 200,
      ),
      onSelected: (item) => onSelected(context, item),
      itemBuilder: (context) => [
        ...MenuItems.itemsOne.map(buildItem).toList(),
        ...MenuItems.itemsTwo.map(buildItem).toList(),
      ],
    );
  }

  Widget _buildMyUserPhoto(BuildContext context, String profilePic) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !kIsWeb ?
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child:
              Center(
                child:
                profilePic == "" ?
                Container(
                  color:  Colors.transparent,
                  height: 40,
                  width: 40,
                  child: Image.asset(ImagePath.USER_DEFAULT),
                ) :
                Image.network(
                  profilePic,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ) :
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child:
              profilePic == "" ?
              Container(
                color:  Colors.transparent,
                height: 40,
                width: 40,
                child: Image.asset(ImagePath.USER_DEFAULT),
              ) :
              Container(
                child: FadeInImage.assetNetwork(
                  image: profilePic,
                  placeholder: ImagePath.USER_DEFAULT,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}


