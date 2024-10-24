/*
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/models/interest_chip_model.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SideNavWidget extends StatelessWidget {
  const SideNavWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      width: 300,
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                      child: Text(
                        "Filter",
                        style: TextStyle(fontSize: 18),
                      )),
                  IconButton(
                      onPressed: _toggleNavigation,
                      icon: Icon(
                        Icons.close,
                        color: kPrimaryColor,
                      ))
                ],
              ),
              Divider(
                height: 1,
                color: kGreyDark,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Distance"),
              _buildSlider(true),
              const SizedBox(
                height: 20,
              ),
              const Text("Age"),
              _buildSlider(false),
              const SizedBox(
                height: 20,
              ),
              const Text("Gender"),
              const SizedBox(
                height: 10,
              ),
              ToggleSwitch(
                minWidth: 129.0,
                initialLabelIndex: 1,
                cornerRadius: 5.0,
                activeFgColor: Colors.white,
                inactiveBgColor: const Color(0xFFF1F1F1),
                inactiveFgColor: Colors.grey,
                totalSwitches: 2,
                labels: ['Male', 'Female'],
                icons: [FontAwesomeIcons.mars, FontAwesomeIcons.venus],
                activeBgColors: [
                  [kPrimaryColor],
                  [kPrimaryColor]
                ],
                onToggle: (index) {
                  print('switched to: $index');
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Interests"),
              const SizedBox(
                height: 10,
              ),
              interestWidget,
            ],
          ),
        ),
      ),
    );
  }
  _buildSlider(bool basicSlider) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
        overlayColor: Colors.purple.withOpacity(0.2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
        showValueIndicator: ShowValueIndicator.always,
        valueIndicatorColor: Colors.purple, // color of the value indicator
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: (basicSlider)
          ? Slider(
        value: _value,
        min: 0,
        max: 100,
        label: _value.round().toString(),
        onChanged: (value) {
          setState(() {
            _value = value;
          });
        },
      )
          : RangeSlider(
        values: _values,
        max: 60,
        min: 18,
        divisions: 5,
        labels: RangeLabels(
          _values.start.round().toString(),
          _values.end.round().toString(),
        ),
        onChanged: (RangeValues values) {
          setState(() {
            _values = values;
          });
        },
      ),
    );
  }
}
*/
