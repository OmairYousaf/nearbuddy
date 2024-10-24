import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

import '../../../helper/utils.dart';
import '../complete_profile_screen.dart';

class PortfolioInformation extends StatefulWidget {
  final PersonalData personalData;
  const PortfolioInformation({Key? key, required this.personalData}) : super(key: key);

  @override
  State<PortfolioInformation> createState() => _PortfolioInformationState();
}

class _PortfolioInformationState extends State<PortfolioInformation> {
  List<File?> pickedImageslst = [null, null, null, null, null, null, null];
  List<XFile?> webImagesLst = [null, null, null, null, null, null, null]; // since in web we need to save file in type XFile type for converting

  @override
  Widget build(BuildContext context) {
    Log.log(widget.personalData.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); //used to remove keyboard from the app
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Step 3",
                style:
                    TextStyle(color: Color(0xFFEDEDED), fontWeight: FontWeight.w300, fontSize: 22),
              ),
              const Text(
                "Select your 6 best shots 😎",
                style:
                    TextStyle(color: Color(0xFFF3F2F2), fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildImageWidget(false, 0),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildImageWidget(true, 1),
                      const SizedBox(
                        height: 5,
                      ),
                      _buildImageWidget(true, 2),
                      const SizedBox(
                        height: 5,
                      ),
                      _buildImageWidget(true, 3),
                    ],
                  )),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildImageWidget(true, 4),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: _buildImageWidget(true, 5),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: _buildImageWidget(true, 6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showModalBottomSheet(
      {required VoidCallback onGalleryPressed,
      required VoidCallback onCameraPressed,
      required VoidCallback onDelete}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
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
              (kIsWeb)
                  ? const SizedBox()
                  : TextButton(
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
                onPressed: onDelete,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.trash, color: kPurpleDeep),
                    const SizedBox(width: 10),
                    Text(
                      " Delete",
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

  _buildImageWidget(bool isSmall, int count) {
    return GestureDetector(
      onTap: () {
        _showModalBottomSheet(onGalleryPressed: () async {
          if(kIsWeb){
            webImagesLst[count]=await Utils().getImageFromGallery();
            pickedImageslst[count]=File(webImagesLst[count]!.path);
          }else{
            pickedImageslst[count] = await Utils().getImageFromGallery();
          }


          Navigator.pop(context);
          setState(() {
            updatePersonalDataObj(isSmall, count);
          });
        }, onCameraPressed: () async {
          pickedImageslst[count] = await Utils().getImageFromCamera();
          setState(() {
            updatePersonalDataObj(isSmall, count);
          });
          Navigator.pop(context);
          setState(() {});
        },
            onDelete: () {
          pickedImageslst[count] = null;

          Navigator.pop(context);
          setState(() {
            if (isSmall) {
              if (count >= 0 && count < widget.personalData.listofPhotos.length) {
                widget.personalData.listofPhotos.removeAt(count);
              }
            } else {
              widget.personalData.profilePhoto = null;
            }
          });
        });
      },
      child: Container(
        height: isSmall ? 100 : 300,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF1F1F1),
              Color(0xFFD9D9D9),
            ],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            width: 5,
            color: kWhiteColor,
          ),
        ),
        child: pickedImageslst[count] == null
            ? Icon(
                Icons.add_a_photo,
                size: isSmall ? 25 : 50,
              )
            : kIsWeb
                ? Image.network(pickedImageslst[count]!.path)
                : Image.file(
                    pickedImageslst[count]!,
                    fit: BoxFit.cover,
                  ),
      ),
    );
  }

  void updatePersonalDataObj(bool isNotProfile, int count) {
    if (isNotProfile) {
      if (widget.personalData.listofPhotos.length >= count && count >= 0) {
        Log.log("The listOfPhotos having the length(${widget.personalData.listofPhotos.length}) contain an image at $count, and we are deleting as its part of the GridView($isNotProfile)");
        widget.personalData.listofPhotos.removeAt(count-1);
        widget.personalData.webListPhotos.removeAt(count-1);
      } else {
        Log.log("Invalid index $count for gridView/listOfPhotos");
      }
      Log.log("Adding pictures to the data object if possible then after overriding");
      widget.personalData.listofPhotos.insert(count-1,pickedImageslst[count]!);
      widget.personalData.webListPhotos.insert(count-1,webImagesLst[count]!);
    } else {
      Log.log("Picked the profile photo");
      widget.personalData.profilePhoto = pickedImageslst[count]!;
      if(kIsWeb) {
        widget.personalData.webProfilePhoto = webImagesLst[count]!;
      }
    }
  }

  @override
  void dispose() {

    super.dispose();
  }
}
