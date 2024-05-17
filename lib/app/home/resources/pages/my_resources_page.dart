import 'package:enreda_app/app/home/resources/pages/favorite_resources_page.dart';
import 'package:enreda_app/app/home/resources/pages/my_enrolled_resources_page.dart';
import 'package:enreda_app/app/home/resources/resource_detail/resource_detail_page.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/common_widgets/custom_stepper_button.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';


class MyResourcesPage extends StatefulWidget {
  const MyResourcesPage({super.key});

  static ValueNotifier<int> selectedIndex = ValueNotifier(1);

  @override
  State<MyResourcesPage> createState() => _MyResourcesPageState();
}

class _MyResourcesPageState extends State<MyResourcesPage> {
  var bodyWidget = [];

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    bodyWidget = [
      Container(),
      MyEnrolledResourcesPage(),
      FavoriteResourcesPage(),
      ResourceDetailPage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContents(context);
  }

  Widget _buildContents(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: MyResourcesPage.selectedIndex,
        builder: (context, selectedIndex, child) {
          return RoundedContainer(
            borderColor: Responsive.isMobile(context) ? Colors.transparent : AppColors.primary020,
            borderWith: Responsive.isMobile(context) ? 0 : 1,
            radius: Responsive.isMobile(context) ? 0 : Sizes.kDefaultPaddingDouble,
            height: MediaQuery.of(context).size.height,
            contentPadding: Responsive.isMobile(context) ?
              EdgeInsets.all(0.0) :
              EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
            margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
              const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            child: Stack(
              alignment: Responsive.isMobile(context) ? Alignment.topCenter : Alignment.topLeft,
              children: [
                Container(
                  height: 50,
                  padding: Responsive.isMobile(context) ? EdgeInsets.only(left: 10, top: 0) : EdgeInsets.all(0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Responsive.isMobile(context) ? InkWell(
                          onTap: () {
                            setStateIfMounted(() {
                              WebHome.controller.selectIndex(0);});
                          },
                          child: Image.asset(ImagePath.ARROW_B, height: 30)) : Container(),
                      Responsive.isMobile(context) ?SpaceW12() : Container(),
                      InkWell(
                          onTap: () => {
                            setState(() {
                              MyResourcesPage.selectedIndex.value = 1;
                            })
                          },
                          child: selectedIndex == 1 || selectedIndex == 2 ? CustomTextMediumBold(text: StringConst.MY_RESOURCES_SPACE) :
                          CustomTextMedium(text: StringConst.MY_RESOURCES_SPACE) ),
                      selectedIndex == 3 ? CustomTextMediumBold(text: '> Detalle del recurso',) : Container()
                    ],
                  ),
                ),
                selectedIndex == 1 || selectedIndex == 2 ?
                Positioned(
                  top: 60,
                  child: Row(
                    children: [
                      SizedBox(width: 10,),
                      InkWell(
                        onTap: () => {
                          setState(() {
                            MyResourcesPage.selectedIndex.value = 1;
                          })
                        },
                        child: CustomStepperButton(
                          child: CustomTextBold(title: StringConst.ENROLLED_RESOURCES, color: MyResourcesPage.selectedIndex.value == 1 ? AppColors.white : AppColors.greyTxtAlt,),
                          icon: SizedBox(width: 21, child: Icon(Icons.check, color: MyResourcesPage.selectedIndex.value == 1 ? AppColors.white : AppColors.greyTxtAlt,)),
                          color: MyResourcesPage.selectedIndex.value == 1 ? AppColors.primaryColor : AppColors.greyUltraLight,
                        ),
                      ),
                      SizedBox(width: 10,),
                      InkWell(
                        onTap: () => {
                          setState(() {
                            MyResourcesPage.selectedIndex.value = 2;
                          })
                        },
                        child: CustomStepperButton(
                          child: CustomTextBold(title: StringConst.FAVORITES_RESOURCES, color: MyResourcesPage.selectedIndex.value == 2 ? AppColors.white : AppColors.greyTxtAlt,),
                          icon: SizedBox(width: 21, child: Icon(Icons.favorite, color: MyResourcesPage.selectedIndex.value == 2 ? AppColors.white : AppColors.greyTxtAlt, size: 21,)),
                          color: MyResourcesPage.selectedIndex.value == 2 ? AppColors.primaryColor : AppColors.greyUltraLight,
                        ),
                      ),
                    ],
                  ),
                ) : Container(),
                Container(
                  margin: selectedIndex == 1 || selectedIndex == 2 ? EdgeInsets.only(top: Sizes.mainPadding * 5) :
                  EdgeInsets.only(top: Sizes.mainPadding * 2.5 , bottom: Sizes.mainPadding),
                    child: bodyWidget[MyResourcesPage.selectedIndex.value],
                ),
              ],
            ),
          );
        });


  }
}
