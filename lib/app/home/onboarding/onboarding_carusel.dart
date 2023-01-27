import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:enreda_app/app/home/onboarding/onboarding_page.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:flutter/material.dart';

import '../../../../../values/values.dart';
import '../../../common_widgets/enreda_button.dart';
import '../../../values/strings.dart';

const double kSpacing = 28.0;
const double kRunSpacing = 16.0;

class OnboardingCarrusel extends StatefulWidget {
  OnboardingCarrusel({
    Key? key}) : super(key: key);

  @override
  _OnboardingCarruselState createState() => _OnboardingCarruselState();
}

class _OnboardingCarruselState extends State<OnboardingCarrusel> {
  final int pageLength = Data.mainPageData.length;
  double currentPageIndex = 0;
  CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    double fontSizeDescription = responsiveSize(context, 15, 20, md: 18);
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.blueDark.withOpacity(0.9844),
              AppColors.blueLight.withOpacity(0.5104),
            ],
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: CarouselSlider.builder(
              itemCount: pageLength,
              carouselController: _carouselController,
              itemBuilder: (BuildContext context, int index,
                  int pageViewIndex) {
                OnboardingPageData page = Data.mainPageData[index];
                return OnboardingPage(
                  logoImagePath: page.logoImagePath,
                  logoImagePathText: page.logoImagePathText,
                  mainImagePath: page.mainImagePath,
                  logoWithTextImagePath: page.logoWithTextImagePath,
                  titleText: page.titleText,
                  descriptionText: page.descriptionText,
                  buttonText: page.buttonText,
                  circleImagePath: page.circleImagePath,
                );
              },
              options: CarouselOptions(
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: Duration(milliseconds: 3000),
                  autoPlayInterval: Duration(seconds: 5),
                  enlargeCenterPage: false,
                  autoPlay: true,
                  aspectRatio: 0.4,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentPageIndex = index.toDouble();
                    });
                  }
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: Visibility(
                      visible: currentPageIndex == 0 ? false : true,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _moveToNextCarousel(0);
                          });
                        },
                        child: Text('Saltar',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: fontSizeDescription,
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildDotsIndicator(
                      pageLength: pageLength,
                      currentIndex: currentPageIndex,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Visibility(
                      visible: currentPageIndex == 0 ? false : true,
                      child: InkWell(
                        onTap: () {
                          double currentPageIndexTap = currentPageIndex < pageLength - 1 ? currentPageIndex + 1 : 0;
                          _moveToNextCarousel(currentPageIndexTap.toInt());
                        },
                        child: SizedBox(
                            height: 77.0,
                            child: Image.asset(
                              ImagePath.ARROW,
                              width: 77,
                            ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  CarouselOptions carouselOptions({
    bool autoPlay = true,
    bool enlargeCenterPage = false,
    bool enableInfiniteScroll = true,
    double viewportFraction = 1.0,
    double aspectRatio = 0.1,
    int initialPage = 1,
    ScrollPhysics? scrollPhysics = const NeverScrollableScrollPhysics(),
  }) {
    return CarouselOptions(
        autoPlay: autoPlay,
        enableInfiniteScroll: enableInfiniteScroll,
        enlargeCenterPage: enlargeCenterPage,
        viewportFraction: viewportFraction,
        aspectRatio: aspectRatio,
        initialPage: initialPage,
        scrollPhysics: scrollPhysics,
        onPageChanged: (int index, CarouselPageChangedReason reason) {
          setState(() {
            currentPageIndex = index.toDouble();
          });
        });
  }

  Widget _buildDotsIndicator({
    required int pageLength,
    required double currentIndex,
  }) {
    return DotsIndicator(
      dotsCount: pageLength,
      position: currentIndex,
      onTap: (index) {
        _moveToNextCarousel(index.toInt());
      },
      decorator: DotsDecorator(
        color: AppColors.grey50,
        activeColor: AppColors.greenLight,
        size: Size(Sizes.SIZE_10, Sizes.SIZE_10),
        activeSize: Size(Sizes.SIZE_16, Sizes.SIZE_16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            const Radius.circular(Sizes.RADIUS_8),
          ),
        ),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            const Radius.circular(Sizes.RADIUS_8),
          ),
        ),
        spacing: EdgeInsets.symmetric(horizontal: Sizes.SIZE_4),
      ),
    );
  }

  _moveToNextCarousel(int index) {
    setState(() {
      currentPageIndex = index.toDouble();
      _carouselController.animateToPage(index);
    });
  }
}