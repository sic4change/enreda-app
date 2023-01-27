import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AccessBackgroundWeb extends StatelessWidget {
  AccessBackgroundWeb({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = widthOfScreen(context);
    double sizeOfBlobSm = screenWidth * 0.3;
    double sizeOfGoldenGlobe = screenWidth * 0.2;
    double dottedGoldenGlobeOffset = sizeOfBlobSm * 0.4;
    //double heightOfBlobAndGlobe = computeHeight(dottedGoldenGlobeOffset, sizeOfGoldenGlobe, sizeOfBlobSm);
    //double heightOfStack = heightOfBlobAndGlobe * 2;
    //double blobOffset = heightOfStack * 0.3;

    return Container(
      color: Constants.lightGreen.withOpacity(0.2),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned(
                    left: -(sizeOfBlobSm * 0.75),
                    //top: blobOffset,
                    top: 300,
                    child: Image.asset(
                      ImagePath.BLOB_BLACK,
                      height: sizeOfBlobSm,
                      width: sizeOfBlobSm,
                    )),

                Positioned(
                  child:
                  Image.asset(ImagePath.BOX_COVER_GOLD, height: sizeOfBlobSm, width: sizeOfBlobSm,),
                  right: (-sizeOfBlobSm*0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

