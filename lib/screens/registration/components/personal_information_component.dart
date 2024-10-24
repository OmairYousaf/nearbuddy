import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/components/controls.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../constants/colors.dart';
import '../../../helper/utils.dart';
import '../../../responsive.dart';
import '../complete_profile_screen.dart';

class PersonalInformation extends StatefulWidget {
  final TextEditingController fullnameController;
  final TextEditingController bioTxtCntrl;
  final PersonalData personalData;

  const PersonalInformation({
    Key? key,
    required this.personalData,
    required this.fullnameController,
    required this.bioTxtCntrl,
  }) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  bool isMale = false;
  bool isFemale = false;
  bool _isDateSet = false;
  bool _OpenBrowserCalendar = false;

  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 18));

  @override
  Widget build(BuildContext context) {
    return _buildContentSet(
        stepCount: 'Step 1', stepTitle: 'Tell us a little about yourself');
  }

  _buildContentSet({
    required String stepCount,
    required String stepTitle,
  }) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.isMobile() ? 15.0 : 100.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              stepCount,
              style: const TextStyle(
                  color: Color(0xFFEDEDED),
                  fontWeight: FontWeight.w300,
                  fontSize: 22),
            ),
            Text(
              stepTitle,
              style: const TextStyle(
                  color: Color(0xFFF3F2F2),
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
            const SizedBox(
              height: 10,
            ),
            buildTextIconFormField(
                context: context,
                hint: 'Full Name',
                onChanged: (value) {},
                textInputType: TextInputType.text,
                textEditingController: widget.fullnameController,
                icon: FontAwesomeIcons.user,
                iconColor: widget.fullnameController.text.isNotEmpty
                    ? const Color(0xFF000000)
                    : const Color(0xFFCCCCCC),
                fontSize: 18),
            const SizedBox(
              height: 15,
            ),
            buildDateFormField(
                showHint: _isDateSet,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  if (kIsWeb) {
                    _OpenBrowserCalendar = true;
                    setState(() {});
                  } else {
                    _selectedDate = await Utils().pickDate(
                      _selectedDate,
                      context,
                    );
                    _isDateSet = true;
                    setState(() {
                      widget.personalData.birthdate = _selectedDate;
                    });
                  }
                },
                date: _selectedDate,
                hintText: "Birthday"),
            (_OpenBrowserCalendar)
                ? const SizedBox(
                    height: 15,
                  )
                : const SizedBox(),
            (_OpenBrowserCalendar)
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: kWhiteColor,
                        border: Border.all(color: kWhiteColor, width: 1)),
                    child: SfDateRangePicker(
                      maxDate:
                          DateTime(DateTime.now().year - 18, 12, 31),
                      showActionButtons: true,
                      onSubmit: (value) {
                        Log.log(value);
                        _selectedDate = DateTime.parse(value.toString());
                        _isDateSet = true;
                        setState(() {
                          widget.personalData.birthdate = _selectedDate;
                          _OpenBrowserCalendar = false;
                        });
                      },
                      onCancel: () {
                        setState(() {
                          _OpenBrowserCalendar = false;
                        });
                      },
                      onSelectionChanged:
                          (DateRangePickerSelectionChangedArgs args) {},
                      selectionMode: DateRangePickerSelectionMode.single,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 15,
            ),
            buildTextAreaIconButton(
                context: context,
                hint: "A little about yourself...",
                textEditingController: widget.bioTxtCntrl,
                icon: FontAwesomeIcons.info),
            const SizedBox(
              height: 15,
            ),
            _buildRadioGenderButtons(),
          ],
        ),
      ),
    );
  }

  _buildRadioGenderButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: buildTextIconButton(
            label: "Male  ",
            onPressed: () {
              setState(() {
                isMale = !isMale;
                isFemale = false;
                widget.personalData.gender = isMale ? 'Male' : 'Female';
              });
            },
            backgroundColor: (isMale) ? kPrimaryLight : const Color(0xFF36034E),
            foregroundColor: kWhiteColor,
            icon: const Icon(FontAwesomeIcons.person),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: buildTextIconButton(
            label: "Female",
            onPressed: () {
              setState(() {
                isMale = false;
                isFemale = !isFemale;
                widget.personalData.gender = isMale ? 'Male' : 'Female';
              });
            },
            backgroundColor:
                (isFemale) ? kPrimaryLight : const Color(0xFF36034E),
            foregroundColor: kWhiteColor,
            icon: const Icon(FontAwesomeIcons.personDress),
          ),
        ),
      ],
    );
  }
}
