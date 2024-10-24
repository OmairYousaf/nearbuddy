import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_buddy_app/components/controls.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../../../constants/colors.dart';
import '../../../../../models/user_model.dart';

class ReportIssueScreen extends StatefulWidget {
  UserModel loggedInUser;

  ReportIssueScreen({
    Key? key,
    required this.loggedInUser,
  }) : super(key: key);
  @override
  _ReportIssueScreenState createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  bool isLoading = false;
  bool isSuccess = false;
  bool isFailed = false;

  String? selectedOption;

  final List<String> options = [
    "Bugs or Errors",
    "Usability and User Interface (UI) Issues",
    "Performance Issues",
    "Account and Authentication Problems",
    "Content Issues",
    "Payment and Purchase Problems",
    "Privacy and Security Concerns",
    "Feedback and Suggestions",
    "Other",
  ];
  final TextEditingController _detailsTxtController = TextEditingController();
/*  void _submitReport() {
    setState(() {
      isLoading = true;
      isSuccess = false;
      isFailed = false;
    });

    // Simulate API call. Replace this with your actual API request.
    Future.delayed(Duration(seconds: 2), () {
      bool apiResponse = true; // Replace with the actual API response.

      setState(() {
        isLoading = false;
        isSuccess = apiResponse;
        isFailed = !apiResponse;
      });

      // Do something with the response, like displaying a success message.
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: (kIsWeb)
            ? null
            : IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  FontAwesomeIcons.chevronLeft,
                  color: kBlack,
                  size: 20,
                ),
              ),
        backgroundColor: kWhiteColor,
        title: Text(
          "Report an Issue",
          style: TextStyle(color: kBlack, fontSize: 18),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (_detailsTxtController.text.isEmpty ||
                    selectedOption == null) {
                  CustomSnackBar.showWarnSnackBar(
                      context, "Please select a topic and describe your issue");
                } else {
                  CustomDialogs.showLoadingAnimation(context);
                  bool result = await ApiService().sendFeedback(
                      email: widget.loggedInUser.email,
                      name: widget.loggedInUser.name,
                      message:
                          "Reported Issue: $selectedOption\nTell us more about this issue: ${_detailsTxtController.text.trim()}");
                  Navigator.of(context).pop();
                  if (result) {
                    CustomSnackBar.showSuccessSnackBar(
                        context, "Your issue has been submitted");
                    _detailsTxtController.clear();
                    selectedImages.clear();
                    setState(() {
                      if (!kIsWeb) {
                        Navigator.of(context).pop();
                      }
                    });
                  } else {
                    CustomSnackBar.showSuccessSnackBar(
                        context, "Could not report your issue");
                  }
                }
              },
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 18),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Report an issue for',
                  style: TextStyle(
                      color: kBlack, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[
                        100], // Replace with your desired background color
                    borderRadius: BorderRadius.circular(
                        8.0), // Adjust the radius as needed
                  ),
                  child: DropdownButton<String>(
                    underline: Container(),
                    // Set the underline to an empty container
                    value: selectedOption,
                    hint: Text(
                      'Select an option',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        selectedOption = newValue!;
                      });
                    },
                    items: options.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 0.0), // Adjust the padding as needed
                          child: Text(option),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tell us more about this issue',
                  style: TextStyle(
                      color: kBlack, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                /*    buildTextAreaIconButton(
                  context: context,
                  hint: "Add details here",
                  textEditingController: _detailsTxtController,
                  icon: Icons.bug_report,
                  minLines: 10,
                  iconColor: kPrimaryColor,
                  fillColor: Colors.grey[100],
                ),*/
                buildTextAreaIconButton(
                    context: context,
                    hint: "Add Details here",
                    textEditingController: _detailsTxtController,
                    minLines: 10,
                    iconColor: kPrimaryColor,
                    icon: Icons.bug_report),
                const SizedBox(height: 20),
                Text(
                  'Attach images here',
                  style: TextStyle(
                      color: kBlack, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _showImageSourceDialog();
                        },
                        icon: const Icon(Icons.camera, size: 32),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedImages.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 100,
                              width: 100,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: (kIsWeb)
                                        ? Image.network(
                                            selectedImages[index].path)
                                        : Image.file(
                                            selectedImages[index],
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedImages.removeAt(index);
                                          Log.log(selectedImages);
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.grey,
                                      )),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Total Attachments: ${selectedImages.length}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _selectImageFromGallery();
              },
              child: const Text('Gallery'),
            ),
            (kIsWeb)
                ? const SizedBox()
                : ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _selectImageFromCamera();
                    },
                    child: const Text('Camera'),
                  ),
          ],
        ),
      ),
    );
  }

  List<File> selectedImages = [];

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }
}
