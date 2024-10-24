import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

import '../../../../../../components/shimmer_widget.dart';




class ShimmerChatWidget extends StatelessWidget {
  const ShimmerChatWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            child: Row(
              children: [
                 ShimmerWidget.circular(
                  width: 64,
                  height: 64,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                     ShimmerWidget.rectangular(
                        height: 16, width: double.infinity),
                    SizedBox(
                      height: 10,
                    ),
                     ShimmerWidget.rectangular(
                        height: 16, width: double.infinity),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ))

              ],
            ),
          ),
        ),
      ),
    );
  }
}
