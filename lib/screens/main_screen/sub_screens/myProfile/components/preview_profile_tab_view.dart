import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/models/buddy_model.dart';
import '../../../../../models/image_model.dart';
import '../../../../../models/interest_chip_model.dart';
import '../../../../../models/user_model.dart';
import '../../userProfile/user_profile_screen.dart';

class PreviewProfileTabView extends StatefulWidget {
  UserModel loggedUser;
  UserModel loggedInUser;
  List<ImageModel> imagesList;
  List<InterestChipModel> myInterestList;
  PreviewProfileTabView(
      {Key? key,
      required this.loggedUser,
      required this.loggedInUser,
      required this.imagesList,
      required this.myInterestList})
      : super(key: key);

  @override
  State<PreviewProfileTabView> createState() => _PreviewProfileTabViewState();
}

class _PreviewProfileTabViewState extends State<PreviewProfileTabView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UserProfileScreen(
            buddyData: copyBuddyToUser(widget.loggedUser),
            loggedInUser: widget.loggedInUser,
            imagesList: widget.imagesList,
            viewAsBuddyProfile:false,
            myInterestList: widget.myInterestList),
      ],
    );
  }
  BuddyModel copyBuddyToUser(UserModel buddy) {
    return BuddyModel(
      id: buddy.id,
      phone: buddy.phone ?? "",
      username: buddy.username ?? "",
      image: buddy.image ?? "",
      name: buddy.name,
      email: buddy.email,
      bio: buddy.bio,

      birthday: buddy.birthday ?? "",
      gender: buddy.gender,
      selectedInterests: buddy.selectedInterests,

    );
  }

}
