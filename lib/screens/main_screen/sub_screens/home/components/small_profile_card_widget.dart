import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/models/image_model.dart';

import '../../../../../components/interest_chip_widget.dart';
import '../../../../../constants/apis_urls.dart';
import '../../../../../models/buddy_model.dart';
import '../../../../../models/interest_chip_model.dart';
import '../../../../../models/user_model.dart';
import '../../../../../routes/api_service.dart';
import '../../userProfile/user_profile_screen.dart';

class ProfileCardWidgetSmall extends StatelessWidget {
  final BuddyModel buddyProfile;
  final UserModel loggedInUser;
  final List<InterestChipModel> interestList;

  const ProfileCardWidgetSmall(
      {super.key,
      required this.buddyProfile,
      required this.interestList,
      required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        CustomDialogs.showLoadingAnimation(context);
        List<ImageModel> imagesList = await getImages();
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                    buddyData: buddyProfile,
                    loggedInUser: loggedInUser,
                    viewAsBuddyProfile: true,
                    imagesList: imagesList,
                    myInterestList: interestList,
                  )),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),

        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          boxShadow: const [
            BoxShadow(
                color: Color(0xB3C0C0C0),
                offset: Offset(0.0, 0.15), //(x,y)
                blurRadius: 12.0,
                spreadRadius: -0.5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: "${ApiUrls.usersImageUrl}/${buddyProfile.image}",
                    fit: BoxFit.cover,
                    width:MediaQuery.of(context).size.width,
                    height: 100,
                    placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 1,
                    )),
                    // Optional
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error), // Optional
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: kPrimaryColor,
                      border: Border.all(color: kWhiteColor, width: 0.5)),
                  child: Text(
                    buddyProfile.distance!,
                    style: TextStyle(color: kWhiteColor),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              maxLines: 1,
              textAlign: TextAlign.center,
              "${buddyProfile.name}",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InterestChipWidget(
                      backgroundColor: const Color(0x0fdcdcdc),
                      selectedColor: const Color(0x0fdcdcdc),
                      textColor: kBlackLight,
                      interestChipModel: interestList[0],
                      fontSize: 11,
                      interestSelected: (String name,
                          InterestChipModel interest,
                          bool interestSelected) {}),
                  (interestList.length > 1)
                      ? InterestChipWidget(
                          backgroundColor: const Color(0x0fdcdcdc),
                          selectedColor: const Color(0x0fdcdcdc),
                          textColor: kBlackLight,
                          fontSize: 11,
                          interestChipModel: interestList[1],
                          interestSelected: (String name,
                              InterestChipModel interest,
                              bool interestSelected) {})
                      : const SizedBox(),
                  (interestList.length > 2)
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          decoration: const BoxDecoration(
                            color: Color(0x0fa1a1a1),
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: Text(
                            "+${interestList.length - 2}",
                            style: TextStyle(
                                color: kBlack,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            /*    ElevatedButton(onPressed: ()async{
              CustomDialogs.showLoadingAnimation(context);
              List<ImageModel>  imagesList= await getImages();
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => UserProfileScreen(
                      buddyData: copyBuddyToUser(buddyProfile),
                      loggedInUser:loggedInUser,
                      isBuddyProfile: true,
                      imagesList: imagesList,
                      myInterestList: interestList,)),
              );
            }, child: const Text("View Profile")),*/
          ],
        ),
      ),
    );
  }

  String convertLength(double length) {
    if (length >= 1000) {
      double kilometers = length / 1000;
      return "${kilometers.toStringAsFixed(2)} KM";
    } else {
      return "${length.toStringAsFixed(1)} M";
    }
  }

  UserModel copyBuddyToUser(BuddyModel buddy) {
    return UserModel(
      id: buddy.id ?? "",
      phone: buddy.phone ?? "",
      username: buddy.username ?? "",
      image: buddy.image ?? "",
      name: buddy.name ?? "",
      email: buddy.email ?? "",
      bio: buddy.bio ?? "",
      location: "${buddy.latitude!},${buddy.longitude!}",
      birthday: buddy.birthday ?? "",
      gender: buddy.gender ?? "",
      selectedInterests: buddy.selectedInterests ?? '',
      emailVerified: true,
    );
  }

  Future<List<ImageModel>> getImages() async {
    List<ImageModel> imagesList =
        await ApiService().getImages(username: buddyProfile.username);
    return imagesList;
  }
}
