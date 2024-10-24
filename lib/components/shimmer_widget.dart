import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final Color? color;

   const ShimmerWidget.rectangular({super.key,
    required this.width,
    required this.height,
    this.color,
  }) : shapeBorder = const RoundedRectangleBorder();

   const ShimmerWidget.circular({super.key,
    required this.width,
    required this.height,
    this.color,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: color??kGrey,
      highlightColor: kGreyDark,
      child: Container(
        width: width,
        height: height,
        decoration:
            ShapeDecoration(color: color??kGrey, shape: shapeBorder),
      ),
    );
  }
}
