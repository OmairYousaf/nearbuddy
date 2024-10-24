import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/myProfile/components/show_intertest_screen.dart';

import '../../../../../components/interest_chip_widget.dart';
import '../../../../../constants/apis_urls.dart';
import '../../../../../constants/colors.dart';
import '../../../../../models/image_model.dart';
import '../../../../../models/interest_chip_model.dart';
import '../../../../../models/user_model.dart';
import '../../../../../routes/api_service.dart';
import '../widgets/image_widget.dart';

class EditProfileTabView extends StatefulWidget {
  UserModel userModel;
  List<ImageModel?> imagesList;
  File? tempProfileImage;

  List<InterestChipModel> myInterestList;
  Function({File? file, XFile? xfile}) onChangeProfileImage;
  Function(File?, int position) onChangeGridImage;
  Function(int index) onUndoGridPhotos;
  Function() onUndoProfile;

  EditProfileTabView(
      {Key? key,
      required this.userModel,
      required this.tempProfileImage,
      required this.onChangeProfileImage,
      required this.onChangeGridImage,
      required this.onUndoGridPhotos,
      required this.onUndoProfile,
      required this.imagesList,
      required this.myInterestList})
      : super(key: key);
  @override
  State<EditProfileTabView> createState() => _EditProfileTabViewState();
}

class _EditProfileTabViewState extends State<EditProfileTabView> {
  bool _isNameChanged = false;
  bool _isBirthdayChanged = false;
  bool _isGenderChanged = false;
  bool _isBioChanged = false;

  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _bioEditingController = TextEditingController();
  DateTime dateTime = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameEditingController = TextEditingController(text: widget.userModel.name);
    _bioEditingController = TextEditingController(text: widget.userModel.bio);

    _selectedDate = DateFormat("dd-MM-yyyy").parse(widget.userModel.birthday);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            _buildPersonalInfo(),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            _buildMainPhoto(),
            const SizedBox(
              height: 10,
            ),
            _buildPhotoGrid(),
            const Divider(),
            //  _buildInterests()
          ],
        ),
      ),
    );
  }

  _buildMainPhoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Portfolio",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            //PROFILE MAIN WIDGET
            ImageWidget(
              isSmall: false, //BECAUSE ITS MAIN
              isNetworkImage: widget.tempProfileImage == null, // IF THE TEMP FILE IS EMPTY THEN IT WILL PICK NETWORK IMAGE STORED
              imageUrl: "${ApiUrls.usersImageUrl}/${widget.userModel.image}", //NETWORK IMAGE URL
              assetImage: widget.tempProfileImage, //ANY IMAGE PICKED IS STORED IN TEMPROFILEIMAGE
              onChange: () {
                _showModalBottomSheet(onGalleryPressed: () async {
                  if(kIsWeb){
                    XFile selectedImage=await Utils().getImageFromGallery();
                    Log.log('found image in modal ${selectedImage.path}');
                    Navigator.pop(context);
                    widget.onChangeProfileImage(xfile: selectedImage);
                  }else {
                    File selectedImage = await Utils().getImageFromGallery();
                    Navigator.pop(context);
                    widget.onChangeProfileImage(file: selectedImage);
                  }

                }, onCameraPressed: () async {
                  File selectedImage = await Utils().getImageFromCamera();

                  Navigator.pop(context);
                  widget.onChangeProfileImage(file: selectedImage);
                }, onUndo: () {
                  setState(() {
                    // widget.tempProfileImage = null;
                    widget.onUndoProfile();
                  });
                });
              },
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 11,
                        ),
                        children: [
                          TextSpan(
                            text: 'Profile Guidelines\n',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF454545),
                                fontSize: 15),
                          ),
                          TextSpan(
                            text:
                                'Please note that any inappropriate or explicit images will be promptly removed and may result in account suspension or termination.',
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                color: Color(0xFF999999),
                                fontStyle: FontStyle.italic,
                                height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  _buildPhotoGrid() {
    return SizedBox(
      height: kIsWeb ? null : 250,
      child: GridView.builder(
        itemCount: 6,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          // If the imagesList has an ImageModel object at the current index, use its imageUrl,
          // otherwise use an empty string
          String imageUrl = "";
          if (index < widget.imagesList.length) {
            if (widget.imagesList[index] != null &&
                widget.imagesList[index]?.isNetworkImage == true) {
              imageUrl =
                  "${ApiUrls.usersImageUrl}/${widget.imagesList[index]!.image}";
            }
          }

          return ImageWidget(
            isSmall: true,
            assetImage: (widget.imagesList[index] != null)
                ? widget.imagesList[index]!.localImageFile
                : null,
            imageUrl: imageUrl,
            isNetworkImage: (widget.imagesList[index] != null)
                ? widget.imagesList[index]!.isNetworkImage
                : false,
            onChange: () {
              _showModalBottomSheet(onGalleryPressed: () async {
                ImageModel imageModel = ImageModel(
                    id: "id",
                    image: "image",
                    username: "username",
                    timeStamp: "timeStamp");

                imageModel.localImageFile = await Utils().getImageFromGallery();
                Navigator.pop(context);
                widget.onChangeGridImage(imageModel.localImageFile, index);
              }, onCameraPressed: () async {
                File selectedImage = await Utils().getImageFromCamera();
                ImageModel imageModel = ImageModel(
                    id: "id",
                    image: "image",
                    username: "username",
                    timeStamp: "timeStamp");

                imageModel.localImageFile = selectedImage;
                Navigator.pop(context);
                widget.onChangeGridImage(imageModel.localImageFile, index);
              }, onUndo: () {
                /*widget.imagesList[index] = null;*/

                setState(() {
                  widget.onUndoGridPhotos(index);
                });
              });
            },
          );
        },
      ),
    );
  }

  _showModalBottomSheet(
      {required VoidCallback onGalleryPressed,
      required VoidCallback onCameraPressed,
      required VoidCallback onUndo}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15), topLeft: Radius.circular(15))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                "Choose",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: onGalleryPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.photoFilm, color: kPurpleDeep),
                    const SizedBox(width: 10),
                    Text(
                      " Pick From Gallery",
                      style: TextStyle(color: kPurpleDeep),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onCameraPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.camera, color: kPurpleDeep),
                    const SizedBox(width: 10),
                    Text(
                      " Pick From Camera",
                      style: TextStyle(color: kPurpleDeep),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: kGrey,
                height: 1,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onUndo,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.undo, color: kPurpleDeep),
                    const SizedBox(width: 10),
                    Text(
                      " UNDO",
                      style: TextStyle(color: kPurpleDeep),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Personal Info",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        _buildListOption(
            title: "Full Name",
            isEditing: _isNameChanged,
            initialText: widget.userModel.name,
            subtitle: widget.userModel.name,
            textEditingController: _nameEditingController,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              setState(() {
                _isNameChanged = !_isNameChanged;
              });
            },
            onChanged: (value) {
              setState(() {
                widget.userModel.name = value;
              });
            },
            option: 1),
        _buildListOption(
            title: "Birthday",
            isEditing: _isBirthdayChanged,
            initialText: _selectedDate,
            subtitle: widget.userModel.birthday,
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _isBirthdayChanged = !_isBirthdayChanged;
              });
            },
            onChanged: (newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
            option: 2),
        _buildListOption(
            title: "Gender",
            initialText: widget.userModel.gender,
            isEditing: _isGenderChanged,
            subtitle: widget.userModel.gender,
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _isGenderChanged = true;
              });
            },
            onChanged: (v) {
              FocusScope.of(context).unfocus();
              setState(() {
                _isGenderChanged = false;
                widget.userModel.gender = v;
              });
            },
            option: 3),
        _buildListOption(
            title: "Bio",
            initialText: widget.userModel.bio,
            maxLines: 2,
            isEditing: _isBioChanged,
            subtitle: widget.userModel.bio,
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _isBioChanged = !_isBioChanged;
              });
            },
            textEditingController: _bioEditingController,
            onChanged: (value) {
              setState(() {
                widget.userModel.bio = value;
              });
            },
            option: 1),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const Text(
              "Interests",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            IconButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => ShowInterestScreen(
                              userModel: widget.userModel,
                              myInterestList: widget.myInterestList,
                              onSelectedChip: (InterestChipModel) {},
                            )));
                await updateInterests();
                setState(() {});
              },
              icon: Icon(
                FontAwesomeIcons.penToSquare,
                size: 15,
                color: kBlackLight,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        _buildInterestsChips(),
      ],
    );
  }

  _buildListOption(
      {required String title,
      required String subtitle,
      required VoidCallback onPressed,
      required int option,
      required isEditing,
      dynamic initialText,
      int maxLines = 1,
      TextEditingController? textEditingController,
      required Function(dynamic) onChanged}) {
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.all(1.0),
      title: Text(
        title,
        style:
            TextStyle(color: kBlack, fontWeight: FontWeight.w600, fontSize: 12),
      ),
      subtitle: (!isEditing)
          ? Text(
              subtitle,
              style: const TextStyle(
                  color: Color(0xFFA2A2A2),
                  fontWeight: FontWeight.w400,
                  fontSize: 15),
            )
          : _showAlternativeWidget(
              option: option,
              initialValue: initialText,
              maxLines: maxLines,
              textEditingController: textEditingController,
              onChanged: onChanged),
      trailing: IconButton(
        onPressed: onPressed,
        icon: Icon(
          FontAwesomeIcons.penToSquare,
          size: 15,
          color: (!isEditing) ? kBlackLight : kPrimaryColor,
        ),
      ),
    );
  }

  _showAlternativeWidget(
      {required int option,
      dynamic initialValue,
      int maxLines = 1,
      TextEditingController? textEditingController,
      required Function(dynamic) onChanged}) {
    if (option == 1) {
      return TextFormField(
        // pass the initial value here
        autofocus: true,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
        maxLines: maxLines,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        onChanged: onChanged,
        controller: textEditingController ?? TextEditingController(),
        decoration: const InputDecoration(
          hintText: 'e.g. John Doe',
          border: UnderlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.0))),
        ),
      );
    } else if (option == 2) {
      return Container(
        child: Column(
          children: [
            CalendarDatePicker(
              initialDate: initialValue!,
              firstDate: DateTime(1990),
              lastDate: DateTime.now(),
              onDateChanged: onChanged,
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    _isBirthdayChanged = false;
                    widget.userModel.birthday =
                        DateFormat('dd-MM-yyyy').format(_selectedDate);
                  });
                },
                child: const Text("SET"))
          ],
        ),
      );
    } else {
      return Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(15),
            border: InputBorder.none,
          ),
          value: initialValue,
          onChanged: onChanged,
          items: ['Male', 'Female']
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
        ),
      );
    }
  }

  _buildInterests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text(
              "Interests",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            IconButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => ShowInterestScreen(
                              userModel: widget.userModel,
                              myInterestList: widget.myInterestList,
                              onSelectedChip: (InterestChipModel) {},
                            )));
                await updateInterests();
                setState(() {});
              },
              icon: Icon(
                FontAwesomeIcons.penToSquare,
                size: 15,
                color: kBlackLight,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        _buildInterestsChips(),
      ],
    );
  }

  _buildInterestsChips() {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => ShowInterestScreen(
                      myInterestList: widget.myInterestList,
                      onSelectedChip: (InterestChipModel) {},
                      userModel: widget.userModel,
                    )));
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          spacing: 1,
          children: widget.myInterestList
              .map((interestChip) => InterestChipWidget(
                  backgroundColor: const Color(0x0fdcdcdc),
                  selectedColor: const Color(0x0fdcdcdc),
                  textColor: kBlackLight,
                  interestChipModel: interestChip,
                  interestSelected: (String name, InterestChipModel interest,
                      bool interestSelected) {}))
              .toList(),
        ),
      ),
    );
  }

  Future<void> updateInterests() async {
    List<InterestChipModel> temp = await ApiService().getInterests();

    widget.myInterestList = [];
    List<String> idList =
        widget.userModel.selectedInterests.split(",").map((id) => id).toList();
    if (mounted) {
      for (String id in idList) {
        for (InterestChipModel interest in temp) {
          if (interest.catID == id) {
            widget.myInterestList.add(interest);
            break; // Exit the inner loop once a match is found
          }
        }
      }

      if (widget.myInterestList.isEmpty && mounted) {
        updateInterests();
      }
    }
  }
}
