import 'package:enreda_app/app/home/documentation/custom_menu_entry.dart';
import 'package:enreda_app/app/home/documentation/menu_item.dart';
import 'package:enreda_app/app/home/documentation/menu_items.dart';
import 'package:enreda_app/app/home/documentation/popup_menu_actions.dart';
import 'package:enreda_app/app/home/documentation/user_profile_picture.dart';
import 'package:enreda_app/app/home/models/documentationParticipant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../services/database.dart';
import '../assistant/list_item_builder.dart';
import '../models/documentCategory.dart';
import '../models/personalDocumentType.dart';
import '../models/userEnreda.dart';
import 'add_documents_form.dart';
import 'list_item_builder_doc.dart';

class DocumentCategoryTile extends StatefulWidget {
  const DocumentCategoryTile({
    Key? key,
    required this.documentCategory,
    required this.participantUser,
  }) : super(key: key);
  final DocumentCategory documentCategory;
  final UserEnreda participantUser;

  @override
  State<DocumentCategoryTile> createState() => _DocumentCategoryTileState();
}

class _DocumentCategoryTileState extends State<DocumentCategoryTile> {

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: StreamBuilder<List<PersonalDocumentType>>(
          stream: database.documentSubCategoriesByCategoryStream(widget.documentCategory.documentCategoryId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            if (snapshot.hasData){
              List<PersonalDocumentType> documentSubCategories =  snapshot.data!;
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: documentSubCategories.map((documentSubCategory) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: Responsive.isMobile(context) ? const EdgeInsets.only(left: 20.0, right: 31.0) :
                        const EdgeInsets.symmetric(horizontal: 55.0, vertical: 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomTextSmall(text: documentSubCategory.title),
                                Spacer(),
                                InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context){
                                            return AddDocumentsForm(
                                              documentSubCategory: documentSubCategory,
                                              participantUser: widget.participantUser,);
                                          }
                                      );
                                    },
                                    child: Image.asset(
                                      ImagePath.ICON_PLUS,
                                      height: Responsive.isMobile(context) ? 25 : 30,)),
                              ],
                            ),
                            SizedBox(height: 10),
                            documentationParticipantBySubCategory(documentSubCategory, widget.participantUser),
                          ],
                        ),
                      ),
                      Divider(thickness: 1, color: AppColors.grey400,),
                    ],
                  );
                }).toList(),
              );
            }
            return Container();
          }
      ),
    );
  }

  Widget documentationParticipantBySubCategory(PersonalDocumentType documentSubCategory, UserEnreda participantUser) {
    final database = Provider.of<Database>(context, listen: false);
    final DateFormat formatter = Responsive.isMobile(context) ? DateFormat('dd/MM') : DateFormat('dd/MM/yyyy');
    return StreamBuilder<List<DocumentationParticipant>>(
      stream: database.documentationParticipantBySubCategoryStream(documentSubCategory, participantUser),
      builder: (context, documentationParticipantSnapshot) {
        if (!documentationParticipantSnapshot.hasData) return Container();
        if(documentationParticipantSnapshot.hasData) {
          return ListItemBuilderDoc<DocumentationParticipant>(
            emptyTitle: 'Sin documentos',
            emptyMessage: 'Aún no se ha agreado ningún documento',
            snapshot: documentationParticipantSnapshot,
            itemBuilder: (context, documentParticipant) {
              return Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.file_copy_outlined, color: AppColors.greyAlt, size: 20.0,),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: Responsive.isMobile(context) ? 150 : Responsive.isDesktopS(context) ? 200 : 350,
                        height: 30,
                        child: CustomTextSmall(text: documentParticipant.name, height: 1,)),
                    Spacer(),
                    Container(
                        width: Responsive.isMobile(context) ? 50 : 85,
                        child: CustomTextSmall(text: formatter.format(documentParticipant.createDate), color: AppColors.primary900,)),
                    Spacer(),
                    documentParticipant.renovationDate == null ? Container(width: Responsive.isMobile(context) ? 50 : 85) :
                    CustomTextSmall(text: formatter.format(documentParticipant.renovationDate!), color: AppColors.primary900,),
                    Spacer(),
                    Responsive.isMobile(context) ? Container() : StreamBuilder<UserEnreda>(
                        stream: database.userEnredaStreamByUserId(documentParticipant.createdBy),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container();
                          if (snapshot.hasData) {
                            UserEnreda user = snapshot.data!;
                            String _photo = user.photo ?? '';
                            return UserProfilePicture(context, _photo);
                          }
                          return Container();
                        }),
                    Spacer(),
                    Container(
                      alignment: Alignment.center,
                      width: Responsive.isMobile(context) ? 25 : 30,
                      child: PopupMenuButton<MenuItem>(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        surfaceTintColor: Colors.white,
                        iconColor: AppColors.primary900,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_horiz, color: AppColors.primary900,),
                        offset: Offset.fromDirection(0.6, 100),
                        iconSize: 30,
                        tooltip: documentParticipant.name,
                        onSelected: (item) => onSelected(context, item, documentSubCategory, participantUser, documentParticipant),
                        itemBuilder: (context) => [
                          CustomPopupMenuEntry(child: null, documentationParticipant: documentParticipant),
                          ...MenuItems.getItemOpen(context).map(buildItem).toList(),
                          ...MenuItems.getItemDownload(context).map(buildItem).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        };
        return Container();
      },
    );
  }


}