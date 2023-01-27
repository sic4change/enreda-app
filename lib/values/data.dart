part of values;

class Data {
  static List<SocialButtonData> socialData = [
    SocialButtonData(
      tag: StringConst.TWITTER_URL,
      iconData: FontAwesomeIcons.twitter,
      url: StringConst.TWITTER_URL,
    ),
    SocialButtonData(
      tag: StringConst.FACEBOOK_URL,
      iconData: FontAwesomeIcons.facebook,
      url: StringConst.FACEBOOK_URL,
    ),
    SocialButtonData(
      tag: StringConst.LINKED_IN_URL,
      iconData: FontAwesomeIcons.linkedin,
      url: StringConst.LINKED_IN_URL,
    ),
    SocialButtonData(
      tag: StringConst.INSTAGRAM_URL,
      iconData: FontAwesomeIcons.instagram,
      url: StringConst.INSTAGRAM_URL,
    ),
  ];

  static List<OnboardingPageData> mainPageData = [
    OnboardingPageData(
      logoImagePath: ImagePath.LOGO_ALONE,
      logoImagePathText: ImagePath.LOGO_TEXT,
      buttonText: StringConst.LET_US_GO,
      circleImagePath: ImagePath.BLOB_1,
    ),
    OnboardingPageData(
      logoWithTextImagePath: ImagePath.LOGO,
      mainImagePath: ImagePath.PAGE_1,
      titleText: StringConst.ONBOARDING_TITLE,
      descriptionText: StringConst.ONBOARDING_DESC,
      circleImagePath: ImagePath.BLOB_2,
    ),
    OnboardingPageData(
      logoWithTextImagePath: ImagePath.LOGO,
      mainImagePath: ImagePath.PAGE_2,
      titleText: StringConst.ONBOARDING_CHAT,
      descriptionText: StringConst.ONBOARDING_CHAT_DESC,
      circleImagePath: ImagePath.BLOB_3,
    ),
    OnboardingPageData(
      logoWithTextImagePath: ImagePath.LOGO,
      mainImagePath: ImagePath.PAGE_3,
      titleText: StringConst.ONBOARDING_IDENTTIFY,
      descriptionText: StringConst.ONBOARDING_IDENTIFY_DESC,
      circleImagePath: ImagePath.BLOB_4,
    ),
  ];

}
