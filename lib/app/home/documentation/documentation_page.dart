import 'package:enreda_app/app/home/documentation/pdf_preview.dart';
import 'package:enreda_app/app/home/models/personalDocument.dart';
import 'package:enreda_app/app/home/models/personalDocumentType.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:enreda_app/app/home/documentation/download_mobile.dart'
if (dart.library.html) 'package:enreda_app/app/home/documentation/download_web.dart' as my_controls;

import 'package:enreda_app/app/home/documentation/upload_mobile.dart'
if (dart.library.html) 'package:enreda_app/app/home/documentation/upload_web.dart' as my_upload;

import '../../../common_widgets/spaces.dart';

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

    return RoundedContainer(
      height: MediaQuery.of(context).size.height,
      margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
        const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      contentPadding: Responsive.isMobile(context) ?
      EdgeInsets.all(Sizes.mainPadding) :
      EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
      child: Stack(
        children: [
          CustomTextMediumBold(text: StringConst.DOCUMENTATION),
          StreamBuilder<UserEnreda>(
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
                          if(!containsDocument){
                            _userDocuments.add(PersonalDocument(name: element.title, order: snapshot.data!.indexOf(element), document: ''));
                          }

                        });
                        _userDocuments.sort((a, b) {
                          return a.order.compareTo(b.order);
                        },);

                        documentsCount = _userDocuments.length;

                      }
                      return Container(
                        margin: EdgeInsets.only(top: Sizes.kDefaultPaddingDouble * 2.5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.greyBorder)
                        ),
                        child:
                        SingleChildScrollView(
                          child: Column(
                              children: [
                                if (Responsive.isDesktop(context) && !Responsive.isDesktopS(context))
                                  _buildHeaderDesktop(() => _showSaveDialog(documentsCount++)),
                                if (!Responsive.isDesktop(context) || Responsive.isDesktopS(context))
                                  _buildHeaderMobile(() => _showSaveDialog(documentsCount++)),
                                Divider(
                                  color: AppColors.greyBorder,
                                  height: 0,
                                ),
                                Column(
                                    children: [
                                      for( var document in _userDocuments)
                                        _documentTile(context, document, widget.participantUser),
                                    ]
                                ),
                                SpaceH50(),
                              ]
                          ),
                        ),
                      );
                    }
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDesktop(VoidCallback onTap) {
    return Padding(
        padding: EdgeInsets.only(left: 50.0, top: 15.0, bottom: 15.0, right: 20.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
              Row(
                  children: [
                    InkWell(
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outlined,
                            color: AppColors.turquoiseBlue,
                            size: 24,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              StringConst.ADD_DOCUMENTS,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: onTap,
                    )
                  ]
              ),
            ]
        )
    );
  }

  Widget _buildHeaderMobile(VoidCallback onTap) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
              SpaceH8(),
              InkWell(
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outlined,
                      color: AppColors.turquoiseBlue,
                      size: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        StringConst.ADD_DOCUMENTS,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: onTap,
              ),
            ]
        )
    );
  }

  Widget _documentTile(BuildContext context, PersonalDocument document, UserEnreda user){
    bool paridad  = _userDocuments.indexOf(document) % 2 == 0;
    final database = Provider.of<Database>(context, listen: false);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: paridad ? AppColors.greySearch : AppColors.white,
        borderRadius: _userDocuments.indexOf(document) == _userDocuments.length-1 ?
        BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)) :
        BorderRadius.all(Radius.circular(0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: Responsive.isDesktop(context)? 50.0: 16.0),
              child: Text(
                document.name,
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: Responsive.isDesktop(context)? 16:12,
                  color: AppColors.chatDarkGray,
                ),
              ),
            ),
          ),
          Padding(
            padding: Responsive.isMobile(context) ? const EdgeInsets.only(right: 8) :
              const EdgeInsets.only(right: 30),
            child: document.document != '' ? Row(
              children: [
                IconButton(
                  icon: Image.asset(
                    ImagePath.PERSONAL_DOCUMENTATION_DELETE,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: (){
                    setPersonalDocument(context: context, document: PersonalDocument(name: document.name, order: -1, document: ''), user: user);
                    setState(() {

                    });
                  },
                ),
                Responsive.isMobile(context) ? SpaceW4() : SpaceW8(),
                IconButton(
                  icon: Image.asset(
                    ImagePath.PERSONAL_DOCUMENTATION_VIEW,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MyPreviewPdf(
                                  url: document.document, title: document.name,
                              )),
                    );
                  },
                ),
                Responsive.isMobile(context) ? SpaceW4() : SpaceW8(),
                IconButton(
                  icon: Image.asset(
                    ImagePath.PERSONAL_DOCUMENTATION_DOWNLOAD,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: () async {
                    my_controls.downloadDocument(document.document, document.name);
                  },
                ),
              ],
            ) :
            IconButton(
              icon: Image.asset(
                ImagePath.PERSONAL_DOCUMENTATION_ADD,
                width: 20,
                height: 20,
              ),
              onPressed: () async {
                my_upload.uploadDocument(context, user, document);
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showSaveDialog(int order) async{
    showDialog(
        context: context,
        builder: (context){
          TextEditingController newDocument = TextEditingController();
          GlobalKey<FormState> addDocumentKey = GlobalKey<FormState>();
          return AlertDialog(
            title: Text(StringConst.SET_DOCUMENT_NAME),
            content: Form(
              key: addDocumentKey,
              child: TextFormField(
                  controller: newDocument,
                  validator: (value){
                    bool used = false;
                    if(value!.isEmpty) return StringConst.FORM_GENERIC_ERROR;
                    _userDocuments.forEach((element) {
                      if(element.name.toUpperCase() == value.toUpperCase()){
                        used = true;
                      }
                    });
                    return used ? StringConst.NAME_IN_USE : null;
                  }
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop((false)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(StringConst.CANCEL,
                        style: TextStyle(
                            color: AppColors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            fontSize: 14)),
                  )),
              ElevatedButton(
                  onPressed: (){
                    if(addDocumentKey.currentState!.validate()){
                      setPersonalDocument(
                          context: context,
                          document: PersonalDocument(name: newDocument.text, order: order, document: ''),
                          user: widget.participantUser);
                      Navigator.of(context).pop((true));
                    }},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(StringConst.ADD,
                        style: TextStyle(
                            color: AppColors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            fontSize: 14)),
                  )),
            ],
          );
        }
    );
  }
}

Future<void> setPersonalDocument({
  required BuildContext context,
  required PersonalDocument document,
  required UserEnreda user,
}) async {
  final database = Provider.of<Database>(context, listen: false);
  //In case user already has a document with that name, remove and replace it
  if(user.personalDocuments.contains(document)){
    user.personalDocuments.remove(document);
  }
  //When update a document with negative order, delete it without replacing it
  if(document.order >= 0) {
    user.personalDocuments.add(document);
  }
  await database.setUserEnreda(user);
}


