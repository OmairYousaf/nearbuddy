import 'dart:io';

// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/myProfile/components/preview_profile_tab_view.dart';

import '../../../../../constants/colors.dart';
import '../../../../../models/image_model.dart';
import '../../../../../models/interest_chip_model.dart';
import '../../../../../models/user_model.dart';
import 'edit_profile_tab_view.dart';

class EditProfileScreen extends StatefulWidget {
  UserModel userModel;
  List<InterestChipModel> myInterestList;
  Function(UserModel userModel) onUpdate;
  EditProfileScreen(
      {Key? key,
      required this.userModel,
      required this.myInterestList,
      required this.onUpdate})
      : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ImageModel?> imagesList = [];

  File? tempProfileImage;

  List<ImageModel?> tempImageList = [null, null, null, null, null, null];
  List<ImageModel> serverImages = [];
  bool loadCompleted = false;
  late UserModel tempUser;

  @override
  void initState() {
    super.initState();
    tempUser = UserModel.copy(widget.userModel);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      (_tabController.index == 0)
          ? {FocusScope.of(context).unfocus()}
          : {FocusScope.of(context).unfocus()};
    });
    getImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: (kIsWeb)
            ? null
            : IconButton(
                onPressed: () {
                  if (tempUser == widget.userModel) {
                    Navigator.of(context).pop();
                  } else {
                    CustomDialogs.showAppDialog(
                        context: context,
                        message: "Do you want to exit without saving",
                        buttonLabel1: "YES",
                        callbackMethod1: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        buttonLabel2: "NO",
                        callbackMethod2: () {
                          widget.onUpdate(widget.userModel);
                        });
                  }
                },
                icon: Icon(
                  FontAwesomeIcons.chevronLeft,
                  color: kBlack,
                  size: 20,
                ),
              ),
        backgroundColor: kWhiteColor,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: kBlack, fontSize: 18),
        ),
        actions: [
          TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                _onSaveButtonClicked();
              },
              child: const Text("Save")),
        ],
      ),
      body: (loadCompleted)
          ? WillPopScope(
              onWillPop: () async {
                if (tempUser == widget.userModel) {
                  return true;
                } else {
                  CustomDialogs.showAppDialog(
                      context: context,
                      message: "Do you want to exit without saving",
                      buttonLabel1: "YES",
                      callbackMethod1: () {
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      buttonLabel2: "NO",
                      callbackMethod2: () {
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      });
                  return false;
                }
              },
              child: Container(
                color: kWhiteColor,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: kWhiteColor, boxShadow: [
                        BoxShadow(
                            color: kGrey,
                            offset: const Offset(0, 4),
                            blurRadius: 6)
                      ]),
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Edit'),
                          Tab(
                            text: 'Preview',
                          ),
                        ],
                        labelColor: kBlack,
                        unselectedLabelColor: kGreyDark,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        indicator: UnderlineTabIndicator(
                          borderSide:
                              BorderSide(width: 2.0, color: kPrimaryColor),
                          insets: const EdgeInsets.symmetric(horizontal: 70.0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          EditProfileTabView(
                              userModel: tempUser,
                              imagesList: imagesList,
                              tempProfileImage: tempProfileImage,
                              myInterestList: widget.myInterestList,
                              onUndoGridPhotos: (int index) {
                                imagesList[index] = tempImageList[index];
                                setState(() {
                                  Log.log("The onUndo$imagesList");
                                });
                              },
                              onUndoProfile: () {
                                tempProfileImage = null;
                                setState(() {});
                              },
                              onChangeProfileImage: ({File? file, XFile? xfile}) {
                                if(xfile!=null){
                                  tempProfileImage=File(xfile!.path);
                                }else{

                                  tempProfileImage = file;
                                }
                                setState(() {
                                });
                              },
                              onChangeGridImage: (File? file, int pos) {
                                setState(() {
                                  ImageModel imageModel = ImageModel(
                                      id: "id",
                                      image: "image",
                                      username: "username",
                                      timeStamp: "timeStamp");
                                  imageModel.isNetworkImage = false;
                                  imageModel.localImageFile = file;

                                  imagesList[pos] = imageModel;

                                  Log.log("The on ChangeGrid$imagesList");
                                });
                              }),
                          PreviewProfileTabView(
                              loggedUser: widget.userModel,
                              loggedInUser: widget.userModel,
                              imagesList: serverImages,
                              myInterestList: widget.myInterestList),
                          /*    Container()*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
                strokeWidth: 1,
              ),
            ),
    );
  }

  Future<void> getImages() async {
    serverImages =
        await ApiService().getImages(username: widget.userModel.username);
    int index = 0;

    for (ImageModel image in serverImages) {
      image.isNetworkImage = true;
      imagesList.insert(index, image);
      index++;

      if (index >= 6) {
        break; // Stop after inserting 6 images
      }
    }

// Fill the remaining spaces with null if needed
    while (index < 6) {
      imagesList.insert(index, null);
      index++;
    }

    if (mounted) {
      setState(() {
        loadCompleted = true;
        tempImageList = List.from(imagesList);
      });
    }
  }

  void _onSaveButtonClicked() async {
    if (tempUser != widget.userModel ||
        tempProfileImage != null ||
        tempImageList != imagesList) {
      CustomDialogs.showLoadingAnimation(context);
      bool result = await ApiService().updateProfile(
          name: tempUser.name,
          profilePath: (tempProfileImage != null)
              ? tempProfileImage!.path.split('/').last
              : tempUser.image,
          birthday: tempUser.birthday,
          location: tempUser.location,
          bio: tempUser.bio,
          isUpdate: true,
          gender: tempUser.gender,
          username: tempUser.username,
          selectedInterests: tempUser.selectedInterests,
          photos: imagesList,
          profileImageFile: tempProfileImage);
      if (result) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        widget.onUpdate(widget.userModel);
      } else {
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, "Error while saving data");
      }
    } else {
      CustomSnackBar.showWarnSnackBar(context, "You havent updated anything");
    }
  }
}
