import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/enreda-contact/enreda_contact_detail.dart';
import 'package:enreda_app/app/home/models/addressUser.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/card_button_contact.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_app/common_widgets/main_container.dart';
import 'package:enreda_app/common_widgets/precached_avatar.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnredaContactPage extends StatefulWidget {
  const EnredaContactPage({Key? key}) : super(key: key);

  @override
  State<EnredaContactPage> createState() => _EnredaContactPageState();
}

class _EnredaContactPageState extends State<EnredaContactPage> {
  String? _assignedContactId;
  String? _assignedSocialEntity;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    String cityName = '';
    String countryName = '';
    String location = '';
    return RoundedContainer(
      height: MediaQuery.of(context).size.height,
        margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
          const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
        contentPadding: Responsive.isMobile(context) ? EdgeInsets.zero :
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
                      _assignedContactId = userEnreda.assignedById;
                      _assignedSocialEntity = userEnreda.assignedEntityId;
                      return StreamBuilder<UserEnreda>(
                        stream: database.enredaUserStream(_assignedContactId!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container();
                          if (snapshot.hasData) {
                            final assignedUser = snapshot.data!;
                            return StreamBuilder<SocialEntity>(
                              stream: database.socialEntityStream(
                                  _assignedSocialEntity!),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Container();
                                if (snapshot.hasData) {
                                  final socialEntity = snapshot.data!;
                                  Address fullLocation = socialEntity.address ??
                                      Address();
                                  return StreamBuilder<City>(
                                    stream: database.cityStream(
                                        fullLocation.city!),
                                    builder: (context, snapshot) {
                                      final city = snapshot.data;
                                      cityName = city == null ? '' : city.name;
                                      return StreamBuilder<Country>(
                                          stream: database.countryStream(
                                              fullLocation.country),
                                          builder: (context, snapshot) {
                                            final country = snapshot.data;
                                            countryName =
                                            country == null ? '' : country.name;
                                            if (countryName != '') {
                                              location = countryName;
                                            } else if (cityName != '') {
                                              location = cityName;
                                            }
                                            if (cityName != '' &&
                                                countryName != '') {
                                              location =
                                                  location + ', ' + cityName;
                                            }
                                            return _buildContent(context, assignedUser, socialEntity, cityName, countryName);
                                          }
                                      );
                                    },
                                  );
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
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
                  });
            }
            return Container();
          })
    );
  }

  Widget _buildContent(BuildContext context, UserEnreda user, SocialEntity socialEntity, String cityName, String countryName) {
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
              Column(
                children: [
                  Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                        minWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: Column(
                        children: [
                          CustomTextLargeBold(text: StringConst.ASSIGNED_CONTACT1 + '${socialEntity.name}'),
                          CustomTextLargeBold(text: StringConst.ASSIGNED_CONTACT2),
                        ],
                      )),
                ],
              ),
              SpaceH30(),
              Flex(
                direction: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ContactDetail(
                    widget: _buildMyUserPhoto(context, user.profilePic!.src),
                    title: '${user.firstName} ${user.lastName}',
                    description: StringConst.ASSIGNED_CONTACT_DESCRIPTION,
                    icon: InkWell(
                        onTap: (){
                          kIsWeb ?
                          sendWhatsAppWebMessage(socialEntity.contactMobilePhone!, StringConst.HELLO_WP_MESSAGE1 + user.firstName! + StringConst.HELLO_WP_MESSAGE2) :
                          sendWhatsAppMessage(socialEntity.contactMobilePhone!, StringConst.HELLO_WP_MESSAGE1 + user.firstName! + StringConst.HELLO_WP_MESSAGE2);
                        },
                        child: Image.asset(ImagePath.WHATSAPP_ICON)),
                  ),
                  ContactDetail(
                    widget: _buildMyUserPhoto(context, socialEntity.photo!),
                    title: '${socialEntity.name}',
                    description: '$cityName, $countryName',
                    icon: _buildEntityActions(context, socialEntity),
                  ),
                ],
              ),
              SpaceH30(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyUserPhoto(BuildContext context, String profilePic) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !kIsWeb ?
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child:
              Center(
                child:
                profilePic == "" ?
                Container(
                  color:  Colors.transparent,
                  height: isSmallScreen ? 60 : 80,
                  width: isSmallScreen ? 60 : 80,
                  child: Image.asset(ImagePath.USER_DEFAULT),
                ):
                CachedNetworkImage(
                    width: isSmallScreen ? 60 : 80,
                    height: isSmallScreen ? 60 : 80,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    imageUrl: profilePic),
              ),
            ) :
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child:
              profilePic == "" ?
              Container(
                color:  Colors.transparent,
                height: isSmallScreen ? 60 : 80,
                width: isSmallScreen ? 60 : 80,
                child: Image.asset(ImagePath.USER_DEFAULT),
              ):
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.turquoiseUltraLight,
                    )
                ),
                child: PrecacheAvatarCard(
                  imageUrl: profilePic,
                  width: isSmallScreen ? 60 : 80,
                  height: isSmallScreen ? 60 : 80,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildEntityActions(BuildContext context, SocialEntity socialEntity) {
    return Container(
      height: 40,
      width: double.infinity,
      padding: EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CardButtonContact(
            title: StringConst.EMAIL,
            icon: Icon(Icons.email_outlined, color: AppColors.turquoiseBlue, size: 20,),
            onTap: () {
              sendEmail(
                toEmail: socialEntity.email!,
                subject: StringConst.SUBJECT,
                body: StringConst.BODY,
              ).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hubo un error al enviar el correo: $error')),
                );
              });
            },
          ),
          SpaceW4(),
          Container(
              height: 15,
              child: VerticalDivider(color: AppColors.white,)),
          SpaceW4(),
          CardButtonContact(
            title: StringConst.CALL,
            icon: Icon(Icons.phone, color: AppColors.turquoiseBlue, size: 20),
            onTap: () {
              kIsWeb ? showCustomDialog(
              context,
              content: Container(
                  height: 100,
                  width: 200,
                  child: Center(child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SpaceH12(),
                        CustomTextBold(title:StringConst.CALL_NUMBER),
                        SpaceH12(),
                        socialEntity.entityPhone!.isNotEmpty ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_phone, color: AppColors.turquoiseBlue, size: 20),
                            CustomTextBold(title: socialEntity.entityPhone!, color: AppColors.turquoiseBlue,),
                          ],) : Container(),
                        SpaceH8(),
                        socialEntity.entityMobilePhone!.isNotEmpty ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_android, color: AppColors.turquoiseBlue, size: 20),
                            CustomTextBold(title: socialEntity.entityMobilePhone!, color: AppColors.turquoiseBlue,),
                          ],) : Container(),
                      ]
                    ))),
            ) : socialEntity.entityMobilePhone!.isNotEmpty ?
                makePhoneCall(socialEntity.entityMobilePhone!) : null;
            },
          ),
        ],
      ),
    );
  }

}
