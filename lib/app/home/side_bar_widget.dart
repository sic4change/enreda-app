
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/resources/pages/resources_page.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_sidebar_button.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/precached_avatar.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';


class SideBarWidget extends StatefulWidget {
  const SideBarWidget({
    Key? key,
    required SidebarXController controller,
    required this.profilePic,
    required this.user,
    required this.keyWebHome}) : _controller = controller, super(key: key);
  final SidebarXController _controller;
  final String profilePic;
  final UserEnreda user;
  final GlobalKey<ScaffoldState> keyWebHome;

  @override
  State<SideBarWidget> createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  void _clearResourcesNavigation() {
    setState(() {
      ResourcesPage.selectedIndex.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    TextTheme textTheme = Theme.of(context).textTheme;
    return SidebarX(
      controller: widget._controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: AppColors.primary050,
        hoverTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.turquoiseBlue,
          fontSize: 15,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
              color: AppColors.turquoiseBlue,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
        selectedTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.turquoiseBlue,
          fontSize: 15,
        ),
        itemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemTextPadding: const EdgeInsets.only(left: 10),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: WebHome.selectedIndex.value == 0 ||
                WebHome.selectedIndex.value == 1 ?
            Colors.transparent : AppColors.primary100,
          ),
          color: WebHome.selectedIndex.value == 0 ||
              WebHome.selectedIndex.value == 1 ?
          Colors.transparent : AppColors.primary100,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.turquoiseBlue,
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: AppColors.turquoiseBlue,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 210,
        decoration: BoxDecoration(
          color: AppColors.white,
        ),
      ),
      //footerDivider: Divider(color: Colors.grey.withOpacity(0.5), height: 1),
      showToggleButton: false,
      headerBuilder: (context, extended) {
        final database = Provider.of<Database>(context, listen: false);
        return Container(
          height: Responsive.isMobile(context) ? 250 : Responsive.isTablet(context) ? 300 : 260,
          child: Padding(
            padding: Responsive.isMobile(context) ? EdgeInsets.only(top: 20.0, left: 0, right: 0) : EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isSmallScreen ? Image.asset(
                  ImagePath.LOGO,
                  height: 30,
                ) : Container(),
                Column(
                  children: [
                    SizedBox(height: 20),
                    StreamBuilder<UserEnreda>(
                        stream: database.userEnredaStreamByUserId(widget.user.userId),
                        builder: (context, snapshot) {
                          if(snapshot.hasData && snapshot.data!.photo != null){
                            print(snapshot.data!.profilePic!.src);
                            PaintingBinding.instance.imageCache.clear();
                            return _buildMyUserPhoto(context, snapshot.data!.profilePic!.src);
                          } else return Container();
                        }
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CustomTextBoldCenter(title: '${widget.user.firstName ?? ""} ${widget.user.lastName ?? ""}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 0.0, bottom: 10),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 0), // optional for spacing
                        height: 6, // Thickness of the 'divider'
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary100, // Color for the 'divider'
                          borderRadius: BorderRadius.all(Radius.circular(10)), // The border radius
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      items: [
        SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_PANEL), width: 20,), label: 'Panel de control', onTap: _clearResourcesNavigation),
        SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_MY_CV_SIDEBAR), width: 20,), label: 'Mi curriculum', onTap: _clearResourcesNavigation),
        SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_PERSONAL_DATA_SIDEBAR), width: 20,), label: 'Datos personales' , onTap: _clearResourcesNavigation),
        SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_COMPETENCIES_SIDEBAR), width: 20,), label: 'Mis competencias' , onTap: _clearResourcesNavigation),
        SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_RESOURCES_SIDEBAR), width: 20,), label: 'Mis recursos', onTap: _clearResourcesNavigation),
        SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_GAMIFICATION_SIDEBAR), width: 20,), label: 'Gamificación', onTap: _clearResourcesNavigation),
        if(isSmallScreen) SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_RESOURCES_SIDEBAR), width: 20,), label: 'Recursos', onTap: _clearResourcesNavigation),
        if(isSmallScreen) SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_COMPETENCIES_SIDEBAR), width: 20,), label: 'Competencias', onTap: _clearResourcesNavigation),
        if(widget.user.assignedEntityId != null && widget.user.assignedEntityId != "") SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_CONTACT_SIDEBAR), width: 20,), label: 'Contacto Enreda', onTap: _clearResourcesNavigation),
        if(widget.user.assignedEntityId != null && widget.user.assignedEntityId != "") SidebarXItem(iconWidget: Container(child: Image.asset(ImagePath.ICON_DOCUMENTS_SIDEBAR), width: 20,), label: 'Mis documentos', onTap: _clearResourcesNavigation),
      ],
    );
  }

  Widget _buildMyUserPhoto(BuildContext context, String profilePic) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return InkWell(
      onTap: () {
        setState(() {
          widget.keyWebHome.currentState?.closeDrawer();
          WebHome.controller.selectIndex(2);
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              !kIsWeb ?
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.turquoiseUltraLight,
                    )
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(60)),
                  child:
                  Center(
                    child:
                    profilePic == "" ?
                    Container(
                      color:  Colors.transparent,
                      height: isSmallScreen ? 80 : 100,
                      width: isSmallScreen ? 80 : 100,
                      child: Image.asset(ImagePath.USER_DEFAULT),
                    ) :
                    Image.network(
                      profilePic,
                      width: isSmallScreen ? 80 : 100,
                      height: isSmallScreen ? 80 : 100,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ) :
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.turquoiseUltraLight,
                    )
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(60)),
                  child:
                  profilePic == "" ?
                  Container(
                    color:  Colors.transparent,
                    height: isSmallScreen ? 80 : 100,
                    width: isSmallScreen ? 80 : 100,
                    child: Image.asset(ImagePath.USER_DEFAULT),
                  ) :
                  Container(
                    child: FadeInImage.assetNetwork(
                      image: profilePic,
                      placeholder: ImagePath.USER_DEFAULT,
                      width: isSmallScreen ? 80 : 100,
                      height: isSmallScreen ? 80 : 100,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
  
}