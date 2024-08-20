
import 'package:enreda_app/app/home/models/documentCategory.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/database.dart';
import '../../../utils/responsive.dart';
import '../../../values/strings.dart';
import '../../../values/values.dart';
import '../assistant/list_item_builder.dart';
import '../models/userEnreda.dart';
import '../web_home.dart';
import 'expandable_doc_category_tile.dart';
import 'list_item_builder_doc.dart';

class ParticipantDocumentationPage extends StatefulWidget {
  ParticipantDocumentationPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  State<ParticipantDocumentationPage> createState() => _ParticipantDocumentationPageState();
}

class _ParticipantDocumentationPageState extends State<ParticipantDocumentationPage> {


  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(widget.participantUser.userId),
        builder: (context, snapshot) {
          return RoundedContainer(
            margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
            const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            contentPadding: Responsive.isMobile(context) ?
            EdgeInsets.symmetric(horizontal: 0.0) :
            const EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                    border: Responsive.isMobile(context) ? null : Border.all(color: AppColors.greyBorder)
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Responsive.isMobile(context) ? InkWell(
                          onTap: () {
                            setStateIfMounted(() {
                              WebHome.controller.selectIndex(0);});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0, left: 15.0, right: 15.0),
                            child: Row(
                              children: [
                                Image.asset(ImagePath.ARROW_B, height: 30),
                                Spacer(),
                                CustomTextMediumBold(text: StringConst.PERSONAL_DOCUMENTATION),
                                Spacer(),
                                SizedBox(width: 30),
                              ],
                            ),
                          ),
                        ) : Padding(
                          padding: Responsive.isMobile(context) ? EdgeInsets.only(left: 20.0 , top: 10, bottom: 15)
                              : EdgeInsets.only(left: 50, top: 15, bottom: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomTextMediumBold(text: StringConst.PERSONAL_DOCUMENTATION),
                            ],
                          ),
                        ),
                        Divider(color: AppColors.greyBorder, height: 0,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: Responsive.isMobile(context) ? EdgeInsets.only(left: 20.0, top: 10, bottom: 10)
                                : EdgeInsets.only(left: 50, top: 10, bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: Responsive.isMobile(context) ? 170 : Responsive.isDesktopS(context) ? 220 : 370,
                                    child: CustomTextSmallIcon(text: StringConst.DOC_NAME)),
                                Spacer(),
                                Container(
                                    width: 85,
                                    child: CustomTextSmallIcon(text: StringConst.CREATION_DATE)),
                                Spacer(),
                                Container(
                                    width: 88,
                                    child: CustomTextSmallIcon(text: StringConst.RENEW_DATE)),
                                Spacer(),
                                Responsive.isMobile(context) ? Container() : Container(
                                    width: 94,
                                    child: CustomTextSmallIcon(text: 'Creado por')),
                                Spacer(),
                                Container(
                                  width: Responsive.isMobile(context) ? 25 : 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: AppColors.greyBorder, height: 0,),
                      ],
                    ),
                    Container(
                      color: Colors.white,
                      margin: Responsive.isMobile(context) ? const EdgeInsets.only(top: 79) : const EdgeInsets.only(top: 103),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            documentCategoriesList(widget.participantUser),
                          ],
                        ),
                      )),
                  ],
                )),
          );
        }
    );
  }

  Widget documentCategoriesList(UserEnreda participantUser) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<DocumentCategory>>(
      stream: database.documentCategoriesStream(),
      builder: (context, documentCategoriesSnapshot) {
        if (!documentCategoriesSnapshot.hasData) return Container();
        return ListItemBuilderDoc<DocumentCategory>(
          snapshot: documentCategoriesSnapshot,
          itemBuilder: (context, documentCategory) {
            return ExpandableDocCategoryTile(documentCategory: documentCategory, participantUser: participantUser);
          },
        );
      },
    );
  }
}
