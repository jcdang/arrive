import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class DisplayTile extends StatelessWidget {
  final String title, semiTitle, subTitle, image;
  final int number;
  DisplayTile(
      {@required this.title,
      @required this.image,
      @required this.subTitle,
      this.semiTitle,
      this.number});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: semiTitle == null ? 46.toHeight : 56.toHeight,
      child: Row(
        children: [
          Stack(
            children: [
              Image.asset(
                image,
                width: 46.toWidth,
                height: 46.toHeight,
              ),
              number != null
                  ? Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        alignment: Alignment.center,
                        height: 28.toHeight,
                        width: 28.toWidth,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: AllColors().LIGHT_GREY),
                        child: Text('+$number'),
                      ),
                    )
                  : Container(
                      height: 0,
                      width: 0,
                    ),
            ],
          ),
          Flexible(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyles().darkGrey14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                semiTitle != null
                    ? Text(
                        semiTitle,
                        style: CustomTextStyles().orange12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox(),
                Text(
                  subTitle,
                  style: CustomTextStyles().darkGrey12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )),
        ],
      ),
    );

    // ListTile(
    //   contentPadding: EdgeInsets.all(0),
    //   leading: Stack(
    //     children: [
    //       Container(
    //         height: 55.toHeight,
    //         width: 50.toWidth,
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(27.toHeight),
    //             color: number != null
    //                 ? AllColors().DARK_GREY
    //                 : AllColors().LIGHT_GREY),
    //       ),
    //       number != null
    //           ? Positioned(
    //               right: 0,
    //               bottom: 0,
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 height: 30.toHeight,
    //                 width: 30.toWidth,
    //                 decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.circular(15.0),
    //                     color: AllColors().LIGHT_GREY),
    //                 child: Text('+$number'),
    //               ),
    //             )
    //           : Container(
    //               height: 0,
    //               width: 0,
    //             ),
    //     ],
    //   ),
    //   title: Text(
    //     title,
    //     style: CustomTextStyles().darkGrey16,
    //   ),
    //   subtitle: Text(
    //     subTitle,
    //     style: CustomTextStyles().grey14,
    //   ),
    // );
  }
}
