import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/app/home/models/documentationParticipant.dart';
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

/// Compact "Mis Documentos" card rendered on the participant's Panel de
/// control. Lists the latest documents uploaded for this participant.
///
/// Reads from the `documentationParticipants` Firestore collection (where
/// both the participant's own upload form and the técnico's upload form
/// write) via `documentationParticipantStreamByUserId`. Previously this
/// widget read `user.personalDocuments`, which is a vestigial array that
/// no current upload flow writes to — that's why the card was always empty
/// even when documents had been uploaded.
class ParticipantDocumentationList extends StatefulWidget {
  ParticipantDocumentationList({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  State<ParticipantDocumentationList> createState() => _ParticipantDocumentationListState();
}

class _ParticipantDocumentationListState extends State<ParticipantDocumentationList> {

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final controller = ScrollController();
    var scrollJump = Responsive.isDesktopS(context) ? 150 : 150;
    final userId = widget.participantUser.userId ?? '';
    return InkWell(
      onTap: () {
        setState(() {
          Responsive.isMobile(context) ?
          WebHome.controller.selectIndex(9) :
          WebHome.controller.selectIndex(7);
        });
      },
      child: StreamBuilder<List<DocumentationParticipant>>(
          stream: database.documentationParticipantStreamByUserId(userId),
          builder: (context, snapshot) {
            // CLAUDE.md §10 DoD — every StreamBuilder handles waiting + error
            // + data.
            if (snapshot.hasError) {
              return _emptyCard(context, StringConst.NO_DOCUMENTS);
            }
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _emptyCard(context, '');
            }
            final userDocuments = snapshot.data ?? const <DocumentationParticipant>[];

            return userDocuments.isEmpty
                ? _emptyCard(context, StringConst.NO_DOCUMENTS)
                : Container(
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
                              children: userDocuments.map((document) {
                                return _documentTile(context, document);
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
      ),
    );
  }

  /// Empty/placeholder state — used while the stream is still pending AND for
  /// the "no documents uploaded yet" final state. Pass an empty [subtitle] to
  /// suppress the inner text while data is loading.
  Widget _emptyCard(BuildContext context, String subtitle) {
    return Padding(
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
              if (subtitle.isNotEmpty)
                Center(child: CustomTextSubTitle(title: subtitle)),
            ],
          )),
    );
  }


  Widget _documentTile(BuildContext context, DocumentationParticipant document){
    final url = document.urlDocument ?? '';
    return Container(
      padding: const EdgeInsets.only(right: 10),
      constraints: BoxConstraints(
        maxWidth: 150,
        minWidth: 150
      ),
      child: url.isNotEmpty ? Column(
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
