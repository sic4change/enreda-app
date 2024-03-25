import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_app/app/home/account/account_page.dart';
import 'package:enreda_app/app/home/account_main_page.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/resources/pages/resources_page.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/custom_icons_icons.dart';
import '../../services/database.dart';
import 'models/userEnreda.dart';

class WebHomeScaffold extends StatefulWidget {
  const WebHomeScaffold({Key? key, required this.showChatNotifier})
      : super(key: key);

  final ValueNotifier<bool> showChatNotifier;

  static ValueNotifier<int> selectedIndex = ValueNotifier(0);

  static goToResources() {
    selectedIndex.value = 0;
  }

  @override
  State<WebHomeScaffold> createState() => _WebHomeScaffoldState();
}

class _WebHomeScaffoldState extends State<WebHomeScaffold> {
  Color _underlineColor = Constants.lilac;
  var bodyWidget = [];
  late UserEnreda _userEnreda;
  String _userName = "";
  late TextTheme textTheme;

  @override
  void initState() {
    bodyWidget = [
      ResourcesPage(),
      CompetenciesPage(showChatNotifier: widget.showChatNotifier),
      WebHome(),
    ];
    super.initState();

  }

  Widget _buildMyUserName(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    textTheme = Theme.of(context).textTheme;
    return StreamBuilder<User?>(
        stream: Provider.of<AuthBase>(context).authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<UserEnreda>(
              stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _userEnreda = snapshot.data!;
                  _userName = '${_userEnreda.firstName} ${_userEnreda.lastName}';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(_userName,
                          style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.bluePetrol,
                                  fontSize: 16.0,)
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      height: 20.0,
                      width: 20.0,
                    ),
                  ),);
                }
              },
            );
          } else if (!snapshot.hasData) {
            return Container();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ValueListenableBuilder<int>(
        valueListenable: WebHomeScaffold.selectedIndex,
        builder: (context, selectedIndex, child) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 120,
              elevation: 1.0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  color: AppColors.grey100),
              ),
              title: Padding(
                padding: Responsive.isMobile(context)
                    ? EdgeInsets.symmetric(horizontal: 30)
                    : Responsive.isDesktopS(context)
                    ? EdgeInsets.symmetric(horizontal: 60)
                    : EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  children: [
                    Padding(
                      padding: Responsive.isMobile(context)
                          ? EdgeInsets.only(right: 30)
                          : Responsive.isDesktopS(context)
                          ? EdgeInsets.only(right: 60)
                          : EdgeInsets.only(right: 60),
                      child: InkWell(
                        onTap: () => launchURL(StringConst.NEW_WEB_ENREDA_URL),
                        child: Image.asset(
                          ImagePath.LOGO,
                          height: 55,
                          width: 125,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 120,
                      color: AppColors.grey100,
                    ),
                    SpaceW24(),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                          color: selectedIndex == 0
                              ? _underlineColor
                              : Colors.transparent,
                          width: 4.0,
                        ),
                      )),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            WebHomeScaffold.selectedIndex.value = 0;
                            ResourcesPage.selectedIndex.value = 0;
                          });
                        },
                        child: Text(
                          StringConst.RESOURCES,
                          style: GoogleFonts.ibmPlexMono(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SpaceW24(),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                          color: WebHomeScaffold.selectedIndex.value == 1
                              ? _underlineColor
                              : Colors.transparent,
                          width: 4.0,
                        ),
                      )),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            WebHomeScaffold.selectedIndex.value = 1;
                          });
                        },
                        child: Text(
                          StringConst.COMPETENCIES,
                          style: GoogleFonts.ibmPlexMono(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (!auth.isNullUser)
                  Container(
                    width: 1,
                    height: 120,
                    color: AppColors.grey100,
                  ),
                SizedBox(width: 20),
                IconButton(
                  icon: const Icon(
                    CustomIcons.cuenta,
                    color: AppColors.bluePetrol,
                    size: 30,
                  ),
                  tooltip: 'Cuenta',
                  onPressed: () {
                    setState(() {
                      WebHomeScaffold.selectedIndex.value = 2;
                    });
                  },
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        WebHomeScaffold.selectedIndex.value = 2;
                      });
                    },
                    child: _buildMyUserName(context)
                ),
                if (!auth.isNullUser)
                SizedBox(width: 20),
                if (!auth.isNullUser)
                  Container(
                    width: 30,
                    child: InkWell(
                      onTap: () => _confirmSignOut(context),
                      child: Image.asset(
                        ImagePath.LOGOUT,
                        height: Sizes.ICON_SIZE_30,
                      ),),
                  ),
                Padding(
                  padding: Responsive.isMobile(context)
                      ? EdgeInsets.only(right: 30)
                      : Responsive.isDesktopS(context)
                      ? EdgeInsets.only(right: 30)
                      : EdgeInsets.only(right: 100),
                  child: SizedBox(),
                ),
              ],
            ),
            body: bodyWidget[selectedIndex],
          );
        });
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Cerrar sesión',
        content: '¿Estás seguro que quieres cerrar sesión?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Cerrar');
    if (didRequestSignOut == true) {
      await auth.signOut();
      GoRouter.of(context).go(StringConst.PATH_HOME);
    }
  }


  Future<void> updateFieldsFromJsonArray(String jsonStr, String collectionName) async {
    try {
      // Parse the JSON string into an array of objects
      List<dynamic> jsonArray = jsonDecode(jsonStr);

      // Get an instance of Firestore
      FirebaseFirestore db = FirebaseFirestore.instance;

      // Create a batch to perform multiple writes as a single operation
      WriteBatch batch = db.batch();

      for (var jsonObj in jsonArray) {
        // Check if each object has the necessary fields
        String? name = jsonObj['name'];
        var fieldValueA = jsonObj['competencyCategoryId']; // Replace 'var' with the expected type
        var fieldValueB = jsonObj['competencySubCategoryId']; // Replace 'var' with the expected type

        // Query the documents in the collection matching the productName
        QuerySnapshot querySnapshot = await db.collection(collectionName)
            .where('name', isEqualTo: name)
            .limit(1)
            .get();

        for (var doc in querySnapshot.docs) {
          // Update fields 'a' and 'b' in each matched document
          DocumentReference docRef = doc.reference;
          batch.update(docRef, {'competencyCategoryId': fieldValueA, 'competencySubCategoryId': fieldValueB});
        }
      }

      // Commit the batch
      await batch.commit();
      print('All fields updated successfully.');
    } catch (e) {
      print('Error updating fields: $e');
    }
  }


}
