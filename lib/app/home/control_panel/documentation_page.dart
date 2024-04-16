import 'package:enreda_app/app/home/account_main_page.dart';
import 'package:enreda_app/app/home/models/personalDocument.dart';
import 'package:enreda_app/app/home/models/personalDocumentType.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/my_scroll_behaviour.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ParticipantDocumentationPage extends StatefulWidget {
  ParticipantDocumentationPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  State<ParticipantDocumentationPage> createState() => _ParticipantDocumentationPageState();
}

class _ParticipantDocumentationPageState extends State<ParticipantDocumentationPage> {
  List<PersonalDocument> _userDocuments = [];

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    late int documentsCount = 0;
    final controller = ScrollController();
    var scrollJump = Responsive.isDesktopS(context) ? 150 : 150;
    return InkWell(
      onTap: () {
        setState(() {
          WebHome.controller.selectIndex(6);
        });
      },
      child: StreamBuilder<UserEnreda>(
          stream: database.userEnredaStreamByUserId(widget.participantUser.userId),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              _userDocuments = snapshot.data!.personalDocuments;
            }
            return StreamBuilder<List<PersonalDocumentType>>(
                stream: database.personalDocumentTypeStream(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    snapshot.data!.forEach((element) {
                      bool containsDocument = false;
                      _userDocuments.forEach((item) {
                        if(item.name == element.title){
                          containsDocument = true;
                        }
                      });
                    });
                    _userDocuments.sort((a, b) {
                      return a.order.compareTo(b.order);
                    },);
                    documentsCount = _userDocuments.length;
                  }
                  return _userDocuments.isEmpty ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Container(
                        margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
                          const EdgeInsets.only(top: 10.0, right: 10.0, left: 0.0, bottom: 10.0,),
                        padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextBoldTitle(title: StringConst.MY_DOCUMENTS),
                            SpaceH8(),
                            Center(child: CustomTextSubTitle(title: StringConst.NO_DOCUMENTS,)),
                          ],
                        )),
                  ) : Container(
                    margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
                      const EdgeInsets.only(top: 10.0, right: 10.0, left: 0.0, bottom: 10.0,),
                    padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextBoldTitle(title: StringConst.MY_DOCUMENTS),
                        SpaceH8(),
                        Container(
                          height: Responsive.isDesktop(context)? 160.0 : 160.0,
                          child: ScrollConfiguration(
                            behavior: MyCustomScrollBehavior(),
                            child: ListView(
                              controller: controller,
                              scrollDirection: Axis.horizontal,
                              children: _userDocuments.map((document) {
                                return _documentTile(context, document, widget.participantUser);
                              }).toList(),
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (controller.position.pixels >=
                                      controller.position.minScrollExtent)
                                    controller.animateTo(
                                        controller.position.pixels - scrollJump,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                },
                                child: Image.asset(
                                  ImagePath.ARROW_BACK_ALT,
                                  width: 30.0,
                                ),
                              ),
                              SpaceW12(),
                              InkWell(
                                onTap: () {
                                  if (controller.position.pixels <=
                                      controller.position.maxScrollExtent)
                                    controller.animateTo(
                                        controller.position.pixels + scrollJump,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                },
                                child: Image.asset(
                                  ImagePath.ARROW_FORWARD_ALT,
                                  width: 30.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
            );
          }
      ),
    );
  }


  Widget _documentTile(BuildContext context, PersonalDocument document, UserEnreda user){
    return Container(
      padding: const EdgeInsets.only(right: 10),
      constraints: BoxConstraints(
        maxWidth: 150,
        minWidth: 150
      ),
      child: document.document != '' ? Column(
        children: [
          Image.asset(ImagePath.ICON_DOCUMENT, width: 80,),
          SpaceH12(),
          Container(
            height: 50,
            child: Text(
              document.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: GoogleFonts.inter().fontFamily,
                fontWeight: FontWeight.w500,
                fontSize: Responsive.isDesktop(context)? 12 : 10,
                color: AppColors.chatDarkGray,
              ),
            ),
          ),
        ],
      ) : Container(),
    );
  }

}
