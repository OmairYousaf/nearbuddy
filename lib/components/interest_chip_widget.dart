import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/models/interest_chip_model.dart';

import '../responsive.dart';

// ignore: must_be_immutable
class InterestChipWidget extends StatelessWidget {
  InterestChipModel interestChipModel;
  Color backgroundColor;
  Color selectedColor;
  Color textColor;
  double fontSize;
  Function(String selectedCategoryName, InterestChipModel categoryChipModel,
      bool isSelected) interestSelected;

  InterestChipWidget({super.key,
    required this.interestChipModel,
    required this.interestSelected,
    required this.backgroundColor,
    required this.selectedColor,
    required this.textColor,
    this.fontSize=12,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      elevation: 1,
      labelPadding:  EdgeInsets.symmetric(horizontal:(Responsive.isWeb())?15.0: 12.0),
      label: Text(interestChipModel.label),
      shape: StadiumBorder(
          side: BorderSide(
              color: (interestChipModel.isSelected)
                  ?kPrimaryColor
                  :backgroundColor)),
      labelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: (interestChipModel.isSelected)
              ? kWhiteColor
              : textColor,
          fontSize: fontSize),
      selected: interestChipModel.isSelected,
      selectedColor:kPrimaryColor,
      backgroundColor:(interestChipModel.isSelected)?selectedColor:backgroundColor,
      onSelected: (isSelected) {
        interestSelected(interestChipModel.label,
            interestChipModel, isSelected);
      },
    );
  }
}
