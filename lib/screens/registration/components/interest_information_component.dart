import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/interest_chip_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../components/interest_chip_widget.dart';
import '../complete_profile_screen.dart';

class InterestInformation extends StatefulWidget {
  final PersonalData personalData;
  const InterestInformation({Key? key, required this.personalData})
      : super(key: key);

  @override
  State<InterestInformation> createState() => _InterestInformationState();
}

class _InterestInformationState extends State<InterestInformation> {
  List<InterestChipModel> interestDataList = [];

  @override
  void initState() {
    super.initState();
    getInterests();
  }

  @override
  Widget build(BuildContext context) {
    return (interestDataList.isEmpty)
        ? CircularProgressIndicator(
            color: kWhiteColor,
            strokeWidth: 1,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: kIsWeb?50.0:30.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context)
                    .unfocus(); //used to remove keyboard from the app
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Step 4",
                      style: TextStyle(
                          color: Color(0xFFEDEDED),
                          fontWeight: FontWeight.w300,
                          fontSize: 22),
                    ),
                    const Text(
                      "Please add a bio describing yourself and pick at least 3 interests",
                      style: TextStyle(
                          color: Color(0xFFF3F2F2),
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    buildInterestsChips(),
                  ],
                ),
              ),
            ),
          );
  }

  buildInterestsChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        spacing:kIsWeb?10: 5,
        runSpacing: kIsWeb?10:0,
        children: interestDataList
            .map((interestChip) => InterestChipWidget(
                backgroundColor: kWhiteColor,
                selectedColor: kWhiteColor,
                textColor: kBlackLight,
                interestChipModel: interestChip,
                interestSelected: (String name, InterestChipModel interest,
                    bool interestSelected) {
                  if (interestSelected) {
                    widget.personalData.selectedInterests.add(interest);
                    Log.log(widget.personalData.toString());
                  } else {
                    widget.personalData.selectedInterests.remove(interest);
                  }
                  setState(() {
                    interestDataList = interestDataList.map((chip) {
                      Log.log(widget.personalData.toString());
                      /*   final newChip = chip.copy(false);
                          return interestChip == newChip
                              ? newChip.copy(interestSelected)
                              : newChip;*/

                      return interestChip == chip
                          ? chip.copy(interestSelected)
                          : chip;
                    }).toList();
                  });
                }))
            .toList(),
      ),
    );
  }

  Future<void> getInterests() async {
    interestDataList = await ApiService().getInterests(
    );
   if(mounted){
     setState(() {

     });
   }
  }
  @override
  void dispose() {

    super.dispose();
  }
}
