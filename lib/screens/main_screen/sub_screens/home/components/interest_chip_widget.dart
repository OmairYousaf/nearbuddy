import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

import '../../../../../components/interest_chip_widget.dart';
import '../../../../../models/interest_chip_model.dart';

class InterestListChipWidget extends StatelessWidget {
  List<InterestChipModel> interestDataList;
  Color backgroundColor;
  Color textColor;
  Function(String selectedCategoryName, InterestChipModel categoryChipModel,
      bool isSelected) interestSelected;
  InterestListChipWidget(
      {Key? key,
      required this.interestDataList,
        required this.backgroundColor,
        required this.textColor,
      required this.interestSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        spacing: 5,
        children: interestDataList
            .map((interestChip) => InterestChipWidget(
          backgroundColor: backgroundColor,
                textColor:kWhiteColor,
            selectedColor: backgroundColor,
                interestChipModel: interestChip,
                interestSelected: (String name, InterestChipModel interest,
                    bool interestSelected) {
                  this.interestSelected(name, interest, interestSelected);
                }))
            .toList(),
      ),
    );
  }
}
