import 'package:enreda_app/app/home/resources/pages/discarded_resources_page.dart';
import 'package:enreda_app/app/home/resources/pages/favorite_resources_page.dart';
import 'package:enreda_app/app/home/resources/pages/invited_resources_page.dart';
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
      InvitedResourcesPage(),
      DiscardedResourcesPage(),
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
          final isTabSelected = selectedIndex >= 1 && selectedIndex <= 4;
          return RoundedContainer(
            borderColor: Responsive.isMobile(context)
                ? Colors.transparent
                : AppColors.primary020,
            borderWith: Responsive.isMobile(context) ? 0 : 1,
            radius:
                Responsive.isMobile(context) ? 0 : Sizes.kDefaultPaddingDouble,
            height: MediaQuery.of(context).size.height,
            contentPadding: Responsive.isMobile(context) &&
                    MyResourcesPage.selectedIndex.value == 5
                ? EdgeInsets.zero
                : Responsive.isMobile(context)
                    ? const EdgeInsets.symmetric(horizontal: 10)
                    : const EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
            margin: Responsive.isMobile(context)
                ? const EdgeInsets.all(0)
                : const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            child: Stack(
              alignment: Responsive.isMobile(context)
                  ? Alignment.topCenter
                  : Alignment.topLeft,
              children: [
                Container(
                  height: 50,
                  padding: Responsive.isMobile(context)
                      ? const EdgeInsets.only(left: 10, top: 0)
                      : const EdgeInsets.all(0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Responsive.isMobile(context)
                          ? InkWell(
                              onTap: () {
                                setStateIfMounted(() {
                                  WebHome.controller.selectIndex(0);
                                  MyResourcesPage.selectedIndex.value = 1;
                                });
                              },
                              child: Image.asset(ImagePath.ARROW_B, height: 30))
                          : Container(),
                      Responsive.isMobile(context) ? SpaceW12() : Container(),
                      InkWell(
                          onTap: () => {
                                setState(() {
                                  MyResourcesPage.selectedIndex.value = 1;
                                })
                              },
                          child: isTabSelected
                              ? CustomTextMediumBold(
                                  text: StringConst.MY_RESOURCES_SPACE)
                              : CustomTextMedium(
                                  text: StringConst.MY_RESOURCES_SPACE)),
                      selectedIndex == 5
                          ? CustomTextMediumBold(
                              text: '> Detalle del recurso',
                            )
                          : Container()
                    ],
                  ),
                ),
                isTabSelected
                    ? Positioned(
                        top: 60,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => setState(() {
                                  MyResourcesPage.selectedIndex.value = 1;
                                }),
                                child: CustomStepperButton(
                                  child: CustomTextBold(
                                    title: StringConst.ENROLLED_RESOURCES,
                                    color: selectedIndex == 1
                                        ? AppColors.white
                                        : AppColors.greyTxtAlt,
                                  ),
                                  icon: SizedBox(
                                    width: 21,
                                    child: Icon(
                                      Icons.check,
                                      color: selectedIndex == 1
                                          ? AppColors.white
                                          : AppColors.greyTxtAlt,
                                    ),
                                  ),
                                  color: selectedIndex == 1
                                      ? AppColors.primaryColor
                                      : AppColors.greyUltraLight,
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => setState(() {
                                  MyResourcesPage.selectedIndex.value = 2;
                                }),
                                child: CustomStepperButton(
                                  child: CustomTextBold(
                                    title: StringConst.FAVORITES_RESOURCES,
                                    color: selectedIndex == 2
                                        ? AppColors.white
                                        : AppColors.greyTxtAlt,
                                  ),
                                  icon: SizedBox(
                                    width: 21,
                                    child: Icon(
                                      Icons.favorite,
                                      color: selectedIndex == 2
                                          ? AppColors.white
                                          : AppColors.greyTxtAlt,
                                      size: 21,
                                    ),
                                  ),
                                  color: selectedIndex == 2
                                      ? AppColors.primaryColor
                                      : AppColors.greyUltraLight,
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => setState(() {
                                  MyResourcesPage.selectedIndex.value = 3;
                                }),
                                child: CustomStepperButton(
                                  child: CustomTextBold(
                                    title: StringConst.INVITED_RESOURCES,
                                    color: selectedIndex == 3
                                        ? AppColors.white
                                        : AppColors.greyTxtAlt,
                                  ),
                                  icon: SizedBox(
                                    width: 21,
                                    child: Icon(
                                      Icons.email,
                                      color: selectedIndex == 3
                                          ? AppColors.white
                                          : AppColors.greyTxtAlt,
                                      size: 21,
                                    ),
                                  ),
                                  color: selectedIndex == 3
                                      ? AppColors.primaryColor
                                      : AppColors.greyUltraLight,
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => setState(() {
                                  MyResourcesPage.selectedIndex.value = 4;
                                }),
                                child: CustomStepperButton(
                                  child: CustomTextBold(
                                    title: StringConst.DISCARDED_RESOURCES,
                                    color: selectedIndex == 4
                                        ? AppColors.white
                                        : AppColors.greyTxtAlt,
                                  ),
                                  icon: SizedBox(
                                    width: 21,
                                    child: Icon(
                                      Icons.block,
                                      color: selectedIndex == 4
                                          ? AppColors.white
                                          : AppColors.greyTxtAlt,
                                      size: 21,
                                    ),
                                  ),
                                  color: selectedIndex == 4
                                      ? AppColors.primaryColor
                                      : AppColors.greyUltraLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Container(
                  margin: isTabSelected
                      ? EdgeInsets.only(top: Sizes.mainPadding * 5)
                      : EdgeInsets.only(
                          top: Sizes.mainPadding * 2.5,
                          bottom: Sizes.mainPadding),
                  child: bodyWidget[MyResourcesPage.selectedIndex.value],
                ),
              ],
            ),
          );
        });
  }
}
