import 'package:flutter/material.dart';

import '../../../../../constants/colors.dart';

class SliderWidget extends StatelessWidget {
  double radius;
  Function(double) onChanged;
  VoidCallback onClosed;
  SliderWidget(
      {Key? key,
      required this.radius,
      required this.onChanged,
      required this.onClosed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
          thumbColor: kPrimaryColor,
          activeTrackColor: kPrimaryColor,
          inactiveTrackColor: kPrimaryTransparent,
          valueIndicatorColor: kPrimaryColor,
          activeTickMarkColor: Colors.transparent,
          inactiveTickMarkColor: Colors.transparent,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),

          trackHeight:5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    topLeft: Radius.circular(5.0)),
              ),
              child: Slider(
                value: radius,
                min: 1,
                max: 100,
                divisions: 100,
                label: radius.round().toString(),
                onChanged: (newValue) {
                  onChanged(newValue);
                },
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(

            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0)),
            ),
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (radius).round().toString(),
                  style: TextStyle(
                      fontSize: 19, color: kBlack, fontWeight: FontWeight.w600),
                ),
                Text(
                  "KM",
                  style: TextStyle(
                      fontSize: 10, color: kBlack, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
