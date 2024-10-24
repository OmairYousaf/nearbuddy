import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../../../components/custom_dialogs.dart';
import '../../../../../constants/apis_urls.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/image_paths.dart';
import '../../../../../models/buddy_model.dart';
import '../../../../../models/image_model.dart';
import '../../../../../models/interest_chip_model.dart';
import '../../../../../models/user_model.dart';
import '../../../../../routes/profile_script.dart';
import '../../userProfile/user_profile_screen.dart';

class MyFriendsScreen extends StatefulWidget {
  UserModel userModel;
  List<InterestChipModel> myInterestList;
  MyFriendsScreen({
    Key? key,
    required this.userModel,
    required this.myInterestList,
  }) : super(key: key);
  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  List<BuddyModel>? friendList;

  @override
  void initState() {
    getFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor: kWhiteColor,
          foregroundColor: kBlack,
          title: Text(
            "My Friends",
            style: TextStyle(color: kBlack, fontSize: 18),
          ),
          actions: [],
        ),
        body: RefreshIndicator(
          onRefresh: () => getFriends(),
          child: friendList == null
              ? const Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : friendList!.isEmpty
                  ? const Center(
                      child: Text(
                        "You don't have any friend yet",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      cacheExtent: 900,
                      itemCount: friendList!.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        BuddyModel friendModel = friendList![index];
                        return InkWell(
                          onTap: () => getUser(
                              friendUsername: friendModel.username ?? ""),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFF2F2F2),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                    offset: Offset(0, 4),
                                    color: Color(0x49CDCDCD),
                                    blurRadius: 8)
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "${ApiUrls.usersImageUrl}/${friendModel.image}",
                                        width: 60,
                                        height: 60,
                                        placeholder: (context, url) =>
                                            Image.asset(
                                                ImagesPaths.placeholderImage),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                ImagesPaths.placeholderImage),
                                        fadeInDuration:
                                            const Duration(milliseconds: 500),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            "${friendModel.name}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "@${friendModel.username}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.blueGrey,
                                            ),
                                            onPressed: () async {
                                              await blockUser(
                                                  friendModel.username ?? "");
                                            },
                                            label: const Text("Remove",
                                                style: TextStyle(fontSize: 12)),
                                            icon: const Icon(Icons.block)),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ));
  }

  Future<List<BuddyModel>?> getFriends() async {
    friendList =
        await ApiService().showFriendList(username: widget.userModel.username);
    setState(() {});
    return friendList;
  }

  getUser({required String friendUsername}) async {
    CustomDialogs.showLoadingAnimation(context);

    BuddyModel buddyProfile =
        await getUserProfile(friendUsername, widget.userModel.username);
    List<InterestChipModel> myInterestList = [];
    List<ImageModel> imageList = [];
    if (buddyProfile.id.isNotEmpty) {
      imageList = await getImages(friendUsername);
      myInterestList = await getInterests(buddyProfile.selectedInterests!);
    }
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => UserProfileScreen(
                buddyData: buddyProfile,
                loggedInUser: widget.userModel,
                viewAsBuddyProfile: true,
                imagesList: imageList,
                myInterestList: myInterestList,
              )),
    );
  }

  blockUser(String otherUsername) async {
    CustomDialogs.showLoadingAnimation(context);
    bool result = await ApiService().blockUser(
        otherUsername: otherUsername, username: widget.userModel.username);
    if (result) {
      await getFriends();
      Navigator.of(context).pop();
      CustomSnackBar.showSuccessSnackBar(context, "User has been blocked!");
    } else {
      Navigator.of(context).pop();
      CustomSnackBar.showErrorSnackBar(context, "Error while blocking");
    }
  }
}
