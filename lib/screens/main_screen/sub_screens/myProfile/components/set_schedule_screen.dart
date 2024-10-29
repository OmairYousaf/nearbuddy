import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/schedule_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../components/controls.dart';
import '../../../../../constants/apis_urls.dart';
import '../../../../../constants/image_paths.dart';
import '../../../../../models/buddy_model.dart';
import '../../../../../models/interest_chip_model.dart';
import '../../../../../models/user_model.dart';

class SetScheduleScreen extends StatefulWidget {
  UserModel loggedInUser;
  bool isEditMode;
  ScheduleModel? scheduleModel;
  List<InterestChipModel> myInterestList;
  Function(bool)? onScheduleSet;
  SetScheduleScreen(
      {Key? key,
      required this.loggedInUser,
      required this.myInterestList,
      this.isEditMode = false,
        this.onScheduleSet,
      this.scheduleModel})
      : super(key: key);

  @override
  State<SetScheduleScreen> createState() => _SetScheduleScreenState();
}

class _SetScheduleScreenState extends State<SetScheduleScreen> {
  TextEditingController textEditingController = TextEditingController();
  late String _selectedInterestId;
  Map<String, bool> weekdays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  final TextEditingController _searchController = TextEditingController();
  String _selectedInterest = "";
  TimeOfDay selectedTime = const TimeOfDay(hour: -1, minute: 0);
  InterestChipModel? interestData;
  bool withSomeone = false;
  bool withEveryone = false;
  List<BuddyModel> selectedUsers = [];
  List<BuddyModel> usersFound = [];
  bool searchFlag = false;
  @override
  void initState() {
    _selectedInterestId = widget.myInterestList[0].catID;
    _selectedInterest = widget.myInterestList[0].label;
    if (widget.isEditMode) {
      interestData = getInterestChipModel(widget.scheduleModel!.interestId);
      selectedTime = TimeOfDay.fromDateTime(DateTime.parse(widget.scheduleModel!.time));
      updateWeekdaysFromString(
        widget.scheduleModel!.days,
      );
      if (widget.scheduleModel!.scheduleWith == 'specific') {
        withSomeone = true;
      } else {
        withEveryone = true;
      }
      if (withSomeone) {
        selectedUsers = widget.scheduleModel!.persons;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Set Schedule",
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "SET SCHEDULE FOR",
                  style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 17,
                        color: Color(0x52D5D5D5),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: (widget.isEditMode)
                      ? Text(
                          interestData!.label,
                          style: const TextStyle(fontSize: 16),
                        )
                      : DropdownButton<String>(
                          value: widget.myInterestList.isNotEmpty ? _selectedInterest : null,
                          onChanged: (String? newValue) {
                            // Handle the selection of a new item
                            setState(() {
                              // Update the selected value
                              _selectedInterest = newValue ?? "";
                              // Find the corresponding interest model
                              InterestChipModel? selectedInterest;
                              try {
                                selectedInterest = widget.myInterestList.firstWhere(
                                  (interest) => interest.label == newValue,
                                );
                              } catch (error) {
                                selectedInterest = null;
                              }
                              // Set the selected interestId
                              _selectedInterestId = selectedInterest!.catID;
                            });
                          },
                          items: widget.myInterestList.map((InterestChipModel interest) {
                            return DropdownMenuItem<String>(
                              value: interest.label,
                              child: Text(interest.label),
                            );
                          }).toList(),
                          underline: const SizedBox(), // Remove the default underline
                          iconSize: 0.0,
                        ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "SET DAYS",
                  style: TextStyle(
                      color: /*Color(0xFFADADAD)*/ kPrimaryColor,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < 7; i++)
                        CircularButton(
                          text: weekdays.keys.elementAt(i).substring(
                              0, 3), // Display the first 3 letters as "Mon"
                          isSelected: weekdays.values.elementAt(i),
                          onPressed: () {
                            setState(() {
                              var day = weekdays.keys.elementAt(i);
                              weekdays[day] = !weekdays[day]!;

                              Log.log(weekdays);
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "SET TIME",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, 4),
                          blurRadius: 17,
                          color: Color(0x52D5D5D5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      (selectedTime.hour == -1) ? "Tap to set time" : selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "SET UP SCHEDULE",
                  style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 17,
                        color: Color(0x52D5D5D5),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [

                      Visibility(
                        visible: selectedUsers.isNotEmpty && withSomeone,
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            itemCount: selectedUsers.length ?? 0,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return InkWell(
                                highlightColor: Colors.grey,
                                onTap: () {
                                  CustomDialogs.showAppDialog(
                                      context: context,
                                      message: "Remove this user?",
                                      buttonLabel1: "Yes",
                                      callbackMethod1: () => _removeUserFromSelectedList(index),
                                      buttonLabel2: "NO",
                                      callbackMethod2: () {
                                        Navigator.of(context).pop();
                                      });
                                },
                                child: Ink(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            "${ApiUrls.usersImageUrl}/${selectedUsers[index].image}",
                                        imageBuilder: (context, imageProvider) => CircleAvatar(
                                          radius: 16,
                                          backgroundColor: kGreyDark,
                                          child: CircleAvatar(
                                              backgroundColor: kGrey,
                                              radius: 15,
                                              backgroundImage: imageProvider),
                                        ),
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.grey.shade100,
                                          child: CircleAvatar(
                                            radius: 16.0,
                                            backgroundColor: Colors.white,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(100),
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => CircleAvatar(
                                          backgroundColor: kGrey,
                                          radius: 16,
                                          backgroundImage:
                                              const AssetImage(ImagesPaths.placeholderImage),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${selectedUsers[index].name}",
                                            style: TextStyle(
                                                color: kBlack,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11),
                                          ),
                                          Text(
                                            "${selectedUsers[index].username}",
                                            style: const TextStyle(
                                              color: Color(0xFF949AB9),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                        child: buildSearchTextField(
                            textEditingController: _searchController,
                            onChanged: (text) {
                              setState(() {
                                searchFlag = true;
                                usersFound.clear();
                              });
                              if (text.length > 3) {
                                usersFound.clear();
                                searchForBuddy(text);
                              } else if (text.isEmpty) {
                                setState(() {
                                  searchFlag = false;
                                  usersFound.clear();
                                  _searchController.text = "";
                                });
                              }
                            }),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      (_searchController.text.isEmpty)
                          ? const SizedBox()
                          : (searchFlag)
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                                    child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                )
                              : (usersFound.isEmpty)
                                  ? const SizedBox(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Not Found"),
                                      ),
                                    )
                                  : ListView.builder(
                                    itemCount: usersFound.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {},
                                        child: Ink(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl:
                                                    "${ApiUrls.usersImageUrl}/${usersFound[index].image}",
                                                imageBuilder: (context, imageProvider) =>
                                                    CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: kGreyDark,
                                                  child: CircleAvatar(
                                                      backgroundColor: kGrey,
                                                      radius: 28,
                                                      backgroundImage: imageProvider),
                                                ),
                                                placeholder: (context, url) =>
                                                    Shimmer.fromColors(
                                                  baseColor: Colors.grey.shade300,
                                                  highlightColor: Colors.grey.shade100,
                                                  child: CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundColor: Colors.white,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) =>
                                                    CircleAvatar(
                                                  backgroundColor: kGrey,
                                                  radius: 30,
                                                  backgroundImage: const AssetImage(
                                                      ImagesPaths.placeholderImage),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${usersFound[index].name}, ${Utils().calculateAge(usersFound[index].birthday!)}",
                                                      style: TextStyle(
                                                          color: kBlack,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 15),
                                                    ),
                                                    Text(
                                                      "${usersFound[index].username}",
                                                      style: const TextStyle(
                                                          color: Color(0xFF949AB9)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 25,
                                                child: Checkbox(
                                                  checkColor: Colors.white,
                                                  shape: const CircleBorder(),
                                                  value:
                                                      selectedUsers.contains(usersFound[index]),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value != null && value == true) {
                                                        selectedUsers.add(usersFound[index]);
                                                      } else {
                                                        selectedUsers.remove(usersFound[index]);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                    ],
                  ),
                ),
                /*         SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 17,
                        color: Color(0x52D5D5D5),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      "WITH EVERYONE",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              withEveryone ? FontWeight.bold : FontWeight.w400,
                          color: Colors.black54), // Set text color to white
                    ),
                    value: withEveryone,
                    activeColor:
                        kPrimaryColor, // Set the checkmark color to white
                    onChanged: (newValue) {
                      setState(() {
                        withEveryone = newValue!;
                        withSomeone =
                            false; // Automatically unselect "With Someone"
                      });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, // Position checkbox before the text
                  ),
                ),*/

                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => (widget.isEditMode) ? _updateSchedule() : _setSchedule(),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15.0)),
                  child: Text((widget.isEditMode) ? "Update Schedule" : "Save Schedule"),
                ),
              ],
            ),
          ),
        ));
  }

  void searchForBuddy(String text) async {
    List<BuddyModel> users = await ApiService().getUserByUsername(username: text,myUsername:widget.loggedInUser.username);
    usersFound = [];

    if (users.isNotEmpty) {
      //checks if user is not empty
      for (var element in users) {
        //every element in users should be checked
        bool isAlreadyMember = false;
        //setting isAlreadyMember false we consider that its not part of the widget.memberList
        if (widget.scheduleModel != null) {
          for (BuddyModel member in widget.scheduleModel!.persons) {
            if (member.username == element.username) {
              isAlreadyMember = true;
              break;
            }
          }
        }
        if (!isAlreadyMember) {
          if (element.username != widget.loggedInUser.username) {
            usersFound.add(element);
          }
        }
      }
    }

    setState(() {
      searchFlag = false;
    });
  }

  _setSchedule() async {
    if (areAllWeekdaysFalse(weekdays) || selectedTime.hour == -1) {
      CustomSnackBar.showErrorSnackBar(
          context, "Please make sure you select the days and time before setting up");
      return;
    }
    CustomDialogs.showLoadingAnimation(context);

    List<String?> usernames = selectedUsers.map((buddy) => buddy.username).toList();
    String usernamesString = usernames.join(',');
    bool result = await ApiService().addScheduling(
        username: widget.loggedInUser.username,
        interestID: _selectedInterestId ?? "",
        days: getSelectedWeekdaysString(weekdays),
        time: getTime(),
        isAll: withEveryone,
        usernames_list: usernamesString,
        isActive: "1");

      Navigator.of(context).pop();

    if (result) {
      CustomSnackBar.showSuccessSnackBar(context, "Added Successfully");
      if(!kIsWeb) {
        Navigator.of(context).pop(true);
      }else{
        widget.onScheduleSet!(true);
      }
    } else {
      CustomSnackBar.showErrorSnackBar(context, "Failed! Try again");
    }
  }

  bool areAllWeekdaysFalse(Map<String, bool> weekdays) {
    return weekdays.values.every((value) => !value);
  }

  _updateSchedule() async {
    if (areAllWeekdaysFalse(weekdays) || selectedTime.hour == -1) {
      CustomSnackBar.showErrorSnackBar(
          context, "Please make sure you select the days and time before setting up");
      return;
    }
    if (!withSomeone && !withEveryone) {
      CustomSnackBar.showWarnSnackBar(context, "Please choose with whom you want to schedule with");
      return;
    }
    if (withSomeone && selectedUsers.isEmpty) {
      CustomSnackBar.showWarnSnackBar(context, "Please add users you wish to tag along");
      return;
    }

    CustomDialogs.showLoadingAnimation(context);
    List<String?> usernames = selectedUsers.map((buddy) => buddy.username).toList();
    String usernamesString = usernames.join(',');
    await ApiService().updateScheduling(
        scheduleId: widget.scheduleModel!.id,
        username: widget.loggedInUser.username,
        interestID: interestData!.catID ?? "",
        days: getSelectedWeekdaysString(weekdays),
        isAll: withEveryone,
        usernames_list: usernamesString,
        time: getTime(),
        isActive: "1");

      Navigator.of(context).pop(true);


    CustomSnackBar.showSuccessSnackBar(context, "Updated Successfully");

      Navigator.of(context).pop(true);

  }

  String getSelectedWeekdaysString(Map<String, bool> weekdays) {
    List<String> selectedWeekdays = weekdays.entries
        .where((entry) => entry.value)
        .map((entry) =>
            entry.key.substring(0, 3)) // Use substring to get the first 3 letters as abbreviation
        .toList();

    return selectedWeekdays.join(', ');
  }

  getTime() {
    DateTime now = DateTime.now();
    DateTime selectedDateTime =
        DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime);

    print(formattedDateTime); // Output: 2024-05-13 01:18:00

    return formattedDateTime;
  }

  getDay(int day) {
    switch (day) {
      case 0:
        return 'mon';
      case 1:
        return 'tue';
      case 2:
        return 'wed';
      case 3:
        return 'thu';
      case 4:
        return 'fri';
      case 5:
        return 'sat';
      default:
        return 'sat';
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  InterestChipModel getInterestChipModel(String interestId) {
    Log.log(interestId);
    return widget.myInterestList.firstWhere((interestChip) => interestChip.catID == interestId);
  }

  void updateWeekdaysFromString(
    String days,
  ) {
    List<String> weekdayKeys = weekdays.keys.toList(); //Monday,...
    for (int i = 0; i < weekdayKeys.length; i++) {
      //7 itreration
      String weekdayKey = weekdayKeys[i]; //Monday
      if (days.toLowerCase().contains(weekdayKey.toLowerCase().substring(0, 3))) {
        weekdays[weekdayKey] = true;
      } else {
        weekdays[weekdayKey] = false;
      }
    }
  }

  _removeUserFromSelectedList(int index) {
    selectedUsers.removeAt(index);
    setState(() {
      Navigator.of(context).pop();
    });
  }
}

class CircularButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const CircularButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? kPrimaryColor : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
