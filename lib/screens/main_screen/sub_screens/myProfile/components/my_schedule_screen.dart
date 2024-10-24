import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

import '../../../../../models/buddy_model.dart';

class ScheduleItem extends StatelessWidget {
  ScheduleItem({
    Key? key,
    required this.isOn,
    required this.isScheduledByMe,
    required this.onChanged,
    required this.interest,
    required this.days,
    required this.time,
    required this.onTap,
    required this.persons,
    required this.username,
  }) : super(key: key);
  bool isOn;
  bool isScheduledByMe;
  Function onTap;
  ValueChanged<bool> onChanged;
  String interest;
  String days;
  String time;
  String username;
  List<BuddyModel> persons;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Ink(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [BoxShadow(offset: Offset(0, 4), blurRadius: 17, color: Color(0x52D5D5D5))],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      interest,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isScheduledByMe,
                    child: CupertinoSwitch(
                      // This bool value toggles the switch.
                      value: isOn,
                      activeColor: kPurple,
                      onChanged: (bool? v) {
                        onChanged(v ?? false);
                      },
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: !isScheduledByMe,
                  child: const SizedBox(
                    height: 10,
                  )),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      formatDaysString(days),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      DateFormat('hh:mm a').format(DateTime.parse(time)),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              (isScheduledByMe) ?  RichText(
                text: TextSpan(
                  text: 'With ',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  children: [
                    for (var person in persons)
                      TextSpan(
                        text: '${person.name}, ',
                        style: TextStyle(
                          color: kPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (persons.isEmpty)
                      TextSpan(
                        text: 'everyone',
                        style: TextStyle(
                          color: kPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ],
                ),
              ):RichText(
                text: TextSpan(
                  text: 'Created By ',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  children: [

                      TextSpan(
                        text: '@$username',
                        style: TextStyle(
                          color: kPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDaysString(String daysString) {
    // Convert the daysString to a list of individual day abbreviations
    List<String> daysList = daysString.split(',');

    // Capitalize and trim each day abbreviation
    daysList = daysList.map((day) => day.trim().toUpperCase()).toList();

    if (daysList.length == 7) {
      return 'Everyday';
    } else if (daysList.length == 1) {
      return 'Only ${daysList[0]}';
    } else if (daysList.length == 2) {
      return 'Only ${daysList[0]} and ${daysList[1]}';
    } else {
      return daysList.join(', ');
    }
  }
}

class InfoPopup extends StatelessWidget {
  const InfoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info,
            size: 48.0,
            color: kPrimaryColor,
          ),
          const SizedBox(height: 16.0),
          const Text(
            'How does scheduling work?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'When you add an interest, it will be automatically enabled.'
            '\n\nThis feature notifies your buddies that when you are working on your interests.'
            ' By doing so, people around you can connect with you and join in your schedule.\n\nYou have the flexibility to disable these updates. If you choose to turn off the updates, we will inform your buddies that you are no longer available for the selected interest',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
