import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/models/buddy_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../components/custom_snack_bars.dart';
import '../../../../constants/apis_urls.dart';
import '../../../../constants/image_paths.dart';
import '../../../../helper/utils.dart';
import '../../../../models/group_member_model.dart';
import '../../../../models/group_model.dart';
import '../../../../routes/api_service.dart';
import '../../../../routes/profile_script.dart';
import 'myChannel/channel_chat_screen.dart';

class ChannelViewScreen extends StatefulWidget {
  UserModel loggedInUser;
  GroupModel groupModel;
  ChannelViewScreen({
    super.key,
    required this.groupModel,
    required this.loggedInUser,
  });

  @override
  State<ChannelViewScreen> createState() => _ChannelViewScreenState();
}

class _ChannelViewScreenState extends State<ChannelViewScreen> {
  BuddyModel adminModel = BuddyModel.empty();
  bool isLoading = true;
  int totalMembers = 0;

  @override
  void initState() {
    _getAdminInfo();
    _getMemberInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kBlack,
        backgroundColor: kWhiteColor,
        elevation: 0,
        title: const Text("Event Information"),
      ),
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          color: kGreyDark,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: '${ApiUrls.groupsImageUrl}/${widget.groupModel.groupIcon}',
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: const DecorationImage(
                                image: AssetImage(ImagesPaths.placeholderAttach),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 190,
                      ),
                      Center(
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: kWhiteColor,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: kPrimaryColor,
                            child: CachedNetworkImage(
                              imageUrl: '${ApiUrls.usersImageUrl}/${adminModel.image}',
                              errorWidget: (context, url, error) => const CircleAvatar(
                                radius: 70,
                                backgroundImage: AssetImage(ImagesPaths.placeholderImage),
                              ),
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: CircleAvatar(
                                  radius: 22.0,
                                  backgroundColor: Colors.white,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 70,
                                backgroundImage: imageProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: Row(
                          children: [
                            Text(
                              "${widget.groupModel.groupName}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: kPrimaryColor, borderRadius: BorderRadius.circular(5.0)),
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Row(
                                children: [
                                  Icon(
                                    widget.groupModel.isPrivate
                                        ? FontAwesomeIcons.lock
                                        : FontAwesomeIcons.lockOpen,
                                    size: 15,
                                    color: kWhiteColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.groupModel.isPrivate ? "Private" : "Public",
                                    style: TextStyle(color: kWhiteColor),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                        child: Text(
                          "${widget.groupModel.groupDescription}",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Organised by ',
                            style: const TextStyle(color: Colors.grey, fontSize: 15),
                            children: [
                              TextSpan(
                                text: "@${widget.groupModel.groupAdmin}",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    await Utils().openUrl(ApiUrls.urlPrivacyPolicy);
                                  },
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.peopleGroup,
                              color: Colors.grey,
                              size: 20,
                            ),
                            Text(
                              "   - ${totalMembers} Members",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: widget.groupModel.groupAdmin != widget.loggedInUser.username,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.groupModel.isJoined ? kGrey : kPrimaryColor,
                                foregroundColor:
                                    widget.groupModel.isJoined ? kBlackLight : kWhiteColor,
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25), // <-- Radius
                                ),
                              ),
                              onPressed: () async {
                                if (widget.groupModel.isJoined) {
                                  _goToChatScreen();
                                } else {
                                  _joinChannel();
                                }
                              },
                              child: widget.groupModel.isJoined
                                  ? const Text("Go to Event Chat")
                                  : const Text("JOIN"),
                            )),
                      ),
                      Visibility(
                        visible: widget.groupModel.groupAdmin == widget.loggedInUser.username,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kGrey,
                                  foregroundColor: kBlackLight,
                                  elevation: 0.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25), // <-- Radius
                                  ),
                                ),
                                onPressed: () => _goToChatScreen(),
                                child: const Text("Go to Event Chat"))),
                      ),
                      Visibility(
                        visible: widget.groupModel.isJoined,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                          child: TextButton.icon(
                            onPressed: () => _leaveChannel(),
                            icon: Icon(
                              Icons.logout_sharp,
                              color: kErrorColor,
                            ),
                            label: Text(
                              "Leave Event",
                              style: TextStyle(color: kErrorColor),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                        child: Visibility(
                          visible: totalMembers > 0,
                          child: Text(
                            "Group Members",
                            style: TextStyle(
                                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Column(
                        children: widget.groupModel.groupMemberList
                            .where((member) =>
                                member.isMember && member.username != widget.groupModel.groupAdmin)
                            .map(
                              (member) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 5.0, right: 5.0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                          color: kGrey,
                                          width: 3,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: CachedNetworkImage(
                                          imageUrl: "${ApiUrls.usersImageUrl}/${member.image}",
                                          width: 50,
                                          height: 50,
                                          placeholder: (context, url) => Shimmer.fromColors(
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
                                          errorWidget: (context, url, error) => CircleAvatar(
                                            backgroundColor: kGrey,
                                            radius: 30,
                                            backgroundImage:
                                                const AssetImage(ImagesPaths.placeholderImage),
                                          ),
                                          fadeInDuration: const Duration(milliseconds: 500),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            child: Text(
                                              '${member.name}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.0,
                                                color: kBlack,
                                              ),
                                            ),
                                            onTap: () {
                                              if (member.username != widget.loggedInUser.username) {
                                                // _goToUser(member);
                                              }
                                            },
                                          ),
                                          Text(
                                            '${member.username}',
                                            style:
                                                const TextStyle(fontSize: 12.0, color: Colors.grey),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Future<void> _getAdminInfo() async {
    adminModel = await ApiService().getUserProfile(
        username: widget.groupModel.groupAdmin!, myUsername: widget.loggedInUser.username);
    if (mounted) {
      setState(() {});
    }
  }

  void _getMemberInfo() async {
    widget.groupModel.groupMemberList =
        await ApiService().getGroupMembers(groupId: widget.groupModel.id);
    for (GroupMemberModel memberModel in widget.groupModel.groupMemberList) {
      //check if the events's groupAdmin is basically the one who is the member
      if (memberModel.isMember && widget.groupModel.groupAdmin != memberModel.username) {
        totalMembers++;
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _joinChannel() async {
    CustomDialogs.showLoadingAnimation(context);
    bool result = await ApiService().addGroupMember(
      groupID: widget.groupModel.id,
      groupMember: widget.loggedInUser.username,
    );
    if (result) {
      //add the member to the group
      widget.groupModel.groupMemberList.add(GroupMemberModel(
          id: '',
          username: widget.loggedInUser.username,
          groupId: widget.groupModel.id,
          name: widget.loggedInUser.name,
          image: widget.loggedInUser.image,
          isMember: true));
    }

    widget.groupModel.isJoined = result;
    totalMembers++;
    Navigator.of(context).pop();
    setState(() {
      Log.log(widget.groupModel);
    });
  }

  void _goToChatScreen() async {
    GroupMemberModel? groupMemberModel = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChannelChatScreen(
          groupChatList: widget.groupModel,
          userLoggedIn: widget.loggedInUser,
          isGroupNewChatlist: false,
          updateChatDetails: (GroupModel groupModel) {},
        ),
      ),
    );
    if (groupMemberModel != null) {
      CustomDialogs.showLoadingAnimation(context);
      widget.groupModel.groupMemberList
          .removeWhere((element) => element.username == groupMemberModel.username);
      widget.groupModel.isJoined = false;
      totalMembers--;
      Navigator.of(context).pop();
      setState(() {
        // Navigator.of(context).pop();
      });
    }
  }

  void _leaveChannel() async {
    CustomDialogs.showLoadingAnimation(context);
    bool result = await ApiService()
        .leaveChannel(username: widget.loggedInUser.username, channelID: widget.groupModel.id);
    if (result) {
      Navigator.of(context).pop(); //closes dialog

      CustomSnackBar.showSuccessSnackBar(context, "You have left the event");

      widget.groupModel.groupMemberList
          .removeWhere((element) => element.username == widget.loggedInUser.username);
      widget.groupModel.isJoined = false;
      totalMembers--;
    } else {
      Navigator.of(context).pop();

      CustomSnackBar.showErrorSnackBar(context, "Error while leaving the Event");
    }
    setState(() {
      Log.log(widget.groupModel);
    });
  }

  void _gotoAdmin() async {}
}
