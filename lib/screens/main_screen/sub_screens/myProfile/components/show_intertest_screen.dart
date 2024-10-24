import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/interest_chip_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';

import '../../../../../components/interest_chip_widget.dart';
import '../../../../../routes/api_service.dart';

class ShowInterestScreen extends StatefulWidget {
  final List<InterestChipModel> myInterestList;
  final Function(InterestChipModel) onSelectedChip;
  final UserModel userModel;
  const ShowInterestScreen(
      {Key? key,
      required this.myInterestList,
      required this.onSelectedChip,
      required this.userModel})
      : super(key: key);

  @override
  State<ShowInterestScreen> createState() => _ShowInterestScreenState();
}

class _ShowInterestScreenState extends State<ShowInterestScreen> {
  List<InterestChipModel> interestDataList = [];
  List<int> selectedChips = [];
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    getInterests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(FontAwesomeIcons.close)),
          title: const Text(
            'Select Interests',
            style: TextStyle(),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    widget.userModel.selectedInterests =
                        selectedChips.join(',');
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("SAVE"))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: (loaded)
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    spacing: 5,
                    children: interestDataList
                        .map((interestChip) => InterestChipWidget(
                            backgroundColor: kWhiteColor,
                            selectedColor: kPurple,
                            textColor: kBlackLight,
                            interestChipModel: interestChip,
                            interestSelected: (String name,
                                InterestChipModel interest,
                                bool interestSelected) {
                              if (selectedChips.length >= 3 &&
                                  !interestSelected) {
                                selectedChips.remove(int.parse(interest.catID));
                                setState(() {
                                  int index =
                                      interestDataList.indexOf(interest);
                                  if (index != -1) {
                                    interestDataList[index] =
                                        interest.copy(interestSelected);
                                    setState(() {});
                                  }
                                });
                              } else if (selectedChips.length > 3) {
                                CustomSnackBar.showBasicSnackBar(
                                    context, "Please Select 3 only");
                              } else {
                                int index = interestDataList.indexOf(interest);
                                if (index != -1) {
                                  interestDataList[index] =
                                      interest.copy(interestSelected);
                                  setState(() {
                                    selectedChips
                                        .add(int.parse(interest.catID));
                                  });
                                }
                              }
                            }))
                        .toList(),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                  strokeWidth: 1,
                )),
        ));
  }

  Future<void> getInterests() async {
    interestDataList = await ApiService().getInterests();
    // Update isSelected property based on myInterestList
    for (int i = 0; i < interestDataList.length; i++) {
      InterestChipModel interest = interestDataList[i];

      int index = widget.myInterestList
          .indexWhere((element) => element.catID == interest.catID);

      if (index != -1) {
        interestDataList[i].isSelected = true;
        selectedChips.add(int.parse(interestDataList[i].catID));
        Log.log(selectedChips.toString());
      }
    }

    setState(() {
      loaded = true;
    });
  }
}
