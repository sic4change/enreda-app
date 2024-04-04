import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/main_container.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnredaContactPage extends StatefulWidget {
  const EnredaContactPage({Key? key}) : super(key: key);

  @override
  State<EnredaContactPage> createState() => _EnredaContactPageState();
}

class _EnredaContactPageState extends State<EnredaContactPage> {
  String? _assignedEntityId;
  String? _assignedUserName;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return RoundedContainer(
        contentPadding: Responsive.isMobile(context) ?
        EdgeInsets.all(Sizes.mainPadding) :
        EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
        child: StreamBuilder<User?>(
          stream: Provider.of<AuthBase>(context).authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            if (snapshot.hasData) {
              return StreamBuilder<List<UserEnreda>>(
                stream: database.userStream(auth.currentUser!.email),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  if (snapshot.hasData) {
                    final userEnreda = snapshot.data![0];
                    _assignedEntityId = userEnreda.assignedById;
                    return StreamBuilder<UserEnreda>(
                      stream: database.enredaUserStream(_assignedEntityId!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
                        if (snapshot.hasData) {
                          final assignedUser = snapshot.data!;
                          _assignedUserName = assignedUser.firstName;
                          return _buildContent(context, assignedUser);
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          })
    );
  }

  Widget _buildContent(BuildContext context, UserEnreda user) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: MainContainer(
          padding: const EdgeInsets.symmetric(vertical: Sizes.kDefaultPaddingDouble * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextTitle(title: StringConst.ASSIGNED_USER),
                  CustomTextBold(title: '${user.firstName} ${user.lastName}',
                    color: AppColors.turquoiseBlue,),
                ],
              ),
              SpaceH20(),
              Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.4,
                  ),
                  child: CustomTextLargeBold(text: StringConst.ASSIGNED_CONTACT)),
              SpaceH20(),
              Flex(
                direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedContainer(
                    width: 300,
                    height: 300,
                  ),
                  RoundedContainer(
                    width: 300,
                    height: 300,
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }

}
