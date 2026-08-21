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
        stream: database.documentSubCategoriesByCategoryStream(
          widget.documentCategory.documentCategoryId,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.hasData) {
            List<PersonalDocumentType> documentSubCategories = snapshot.data!;
            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: documentSubCategories.map((documentSubCategory) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: Responsive.isMobile(context)
                          ? const EdgeInsets.only(left: 20.0, right: 17.0)
                          : const EdgeInsets.symmetric(
                              horizontal: 55.0,
                              vertical: 0.0,
                            ),
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
                                    builder: (context) {
                                      return AddDocumentsForm(
                                        documentSubCategory:
                                            documentSubCategory,
                                        participantUser: widget.participantUser,
                                      );
                                    },
                                  );
                                },
                                child: Image.asset(
                                  ImagePath.ICON_PLUS,
                                  height: Responsive.isMobile(context)
                                      ? 25
                                      : 30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          documentationParticipantBySubCategory(
                            documentSubCategory,
                            widget.participantUser,
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1, color: AppColors.grey400),
                  ],
                );
              }).toList(),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget documentationParticipantBySubCategory(
    PersonalDocumentType documentSubCategory,
    UserEnreda participantUser,
  ) {
    final database = Provider.of<Database>(context, listen: false);
    final DateFormat formatter = Responsive.isMobile(context)
        ? DateFormat('dd/MM')
        : DateFormat('dd/MM/yyyy');
    return StreamBuilder<List<DocumentationParticipant>>(
      stream: database.documentationParticipantBySubCategoryStream(
        documentSubCategory,
        participantUser,
      ),
      builder: (context, documentationParticipantSnapshot) {
        if (!documentationParticipantSnapshot.hasData) return Container();
        if (documentationParticipantSnapshot.hasData) {
          return ListItemBuilderDoc<DocumentationParticipant>(
            emptyTitle: 'Sin documentos',
            emptyMessage: 'Aún no se ha agreado ningún documento',
            snapshot: documentationParticipantSnapshot,
            itemBuilder: (context, documentParticipant) {
              return _DocumentItemTile(
                documentParticipant: documentParticipant,
                formatter: formatter,
                documentSubCategory: documentSubCategory,
                participantUser: participantUser,
              );
            },
          );
        }
        ;
        return Container();
      },
    );
  }
}

class _DocumentItemTile extends StatefulWidget {
  const _DocumentItemTile({
    required this.documentParticipant,
    required this.formatter,
    required this.documentSubCategory,
    required this.participantUser,
  });

  final DocumentationParticipant documentParticipant;
  final DateFormat formatter;
  final PersonalDocumentType documentSubCategory;
  final UserEnreda participantUser;

  @override
  State<_DocumentItemTile> createState() => _DocumentItemTileState();
}

class _DocumentItemTileState extends State<_DocumentItemTile> {
  bool _showObservations = false;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.file_copy_outlined,
                color: AppColors.greyAlt,
                size: 20.0,
              ),
              const SizedBox(width: 10),
              Container(
                alignment: Alignment.centerLeft,
                width: Responsive.isMobile(context)
                    ? 150
                    : Responsive.isDesktopS(context)
                    ? 200
                    : 350,
                height: 30,
                child: CustomTextSmall(
                  text: widget.documentParticipant.name,
                  height: 1,
                ),
              ),
              const Spacer(),
              Container(
                width: Responsive.isMobile(context) ? 50 : 85,
                child: CustomTextSmall(
                  text: widget.formatter.format(
                    widget.documentParticipant.createDate,
                  ),
                  color: AppColors.primary900,
                ),
              ),
              const SizedBox(width: 15),
              widget.documentParticipant.renovationDate == null
                  ? Container(width: Responsive.isMobile(context) ? 50 : 85)
                  : Container(
                      width: Responsive.isMobile(context) ? 50 : 85,
                      child: CustomTextSmall(
                        text: widget.formatter.format(
                          widget.documentParticipant.renovationDate!,
                        ),
                        color: AppColors.primary900,
                      ),
                    ),
              const SizedBox(width: 25),
              Responsive.isMobile(context)
                  ? Container()
                  : Container(
                      width: 25,
                      height: 25,
                      child: StreamBuilder<UserEnreda>(
                        stream: database.userEnredaStreamByUserId(
                          widget.documentParticipant.createdBy,
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container();
                          if (snapshot.hasData) {
                            UserEnreda user = snapshot.data!;
                            String _photo = user.photo ?? '';
                            return UserProfilePicture(context, _photo);
                          }
                          return Container();
                        },
                      ),
                    ),
              const Spacer(),
              Container(
                width: 30,
                alignment: Alignment.center,
                child:
                    widget.documentParticipant.observations != null &&
                        widget.documentParticipant.observations!
                            .trim()
                            .isNotEmpty
                    ? InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _showObservations = !_showObservations;
                          });
                        },
                        child: Image.asset(
                          ImagePath.ICON_OBSERVATIONS_BUBBLE,
                          width: 18,
                          height: 18,
                          color: _showObservations
                              ? const Color(0xFF18C5C1)
                              : const Color(0xFF535A5F),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 10),
              Container(
                alignment: Alignment.center,
                width: Responsive.isMobile(context) ? 25 : 30,
                child: PopupMenuButton<MenuItem>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  surfaceTintColor: Colors.white,
                  iconColor: AppColors.primary900,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_horiz, color: AppColors.primary900),
                  offset: Offset.fromDirection(0.6, 100),
                  iconSize: 30,
                  tooltip: widget.documentParticipant.name,
                  onSelected: (item) => onSelected(
                    context,
                    item,
                    widget.documentSubCategory,
                    widget.participantUser,
                    widget.documentParticipant,
                  ),
                  itemBuilder: (context) => [
                    CustomPopupMenuEntry(
                      child: null,
                      documentationParticipant: widget.documentParticipant,
                    ),
                    ...MenuItems.getItemOpen(context).map(buildItem).toList(),
                    ...MenuItems.getItemDownload(context)
                        .map(buildItem)
                        .toList(),
                    if (!widget.documentParticipant.techCreated) ...[
                      ...MenuItems.getItemEdit(context).map(buildItem).toList(),
                      ...MenuItems.getItemDelete(context)
                          .map(buildItemRed)
                          .toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showObservations &&
            widget.documentParticipant.observations != null &&
            widget.documentParticipant.observations!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 0.0,
              top: 4.0,
              bottom: 8.0,
              right: 30.0,
            ),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.greyTxtAlt, height: 1.4),
                children: [
                  TextSpan(
                    text: 'Observaciones: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary900,
                    ),
                  ),
                  TextSpan(
                    text: widget.documentParticipant.observations!,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
