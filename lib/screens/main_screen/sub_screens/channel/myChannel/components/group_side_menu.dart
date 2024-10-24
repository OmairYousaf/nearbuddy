import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/group_member_model.dart';
import 'package:nearby_buddy_app/models/group_message_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../components/custom_snack_bars.dart';
import '../../../../../../components/image_full_screen.dart';
import '../../../../../../constants/apis_urls.dart';
import '../../../../../../constants/image_paths.dart';
import '../../../../../../models/buddy_model.dart';
import '../../../../../../models/group_model.dart';
import '../../../../../../models/image_model.dart';
import '../../../../../../models/interest_chip_model.dart';
import '../../../../../../routes/api_service.dart';
import '../../../../../../routes/profile_script.dart';
import '../../../userProfile/user_profile_screen.dart';
import '../create_group_screen.dart';
import 'add_member_group_screen.dart';

class GroupSideMenu extends StatefulWidget {
  GroupModel groupModel;
  final UserModel userLoggedIn;
  Function(GroupModel) updateChatDetails;
  GroupSideMenu(
      {Key? key,
      required this.groupModel,
      required this.userLoggedIn,
      required this.updateChatDetails})
      : super(key: key);

  @override
  State<GroupSideMenu> createState() => _GroupSideMenuState();
}

class _GroupSideMenuState extends State<GroupSideMenu> {
  bool _isOptionAppbar = false;
  List<String> selectedUsers = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(isOptionAppbar: _isOptionAppbar),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            // Group icon and change button
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: kGreyDark,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageFullScreen(
                                imageUrlsList: const [],
                                imageUrl:
                                    "${ApiUrls.groupsImageUrl}/${widget.groupModel.groupIcon}",
                                imageName: widget.groupModel.groupName!),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: kGreyDark,
                            width: 1,
                          ),
                        ),
                        child: Hero(
                          tag: "${ApiUrls.groupsImageUrl}/${widget.groupModel.groupIcon}",
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: "${ApiUrls.groupsImageUrl}/${widget.groupModel.groupIcon}",
                              width: 150,
                              height: 150,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                              ),
                              errorWidget: (context, url, error) =>
                                  Image.asset(ImagesPaths.placeholderImage),
                              fadeInDuration: const Duration(milliseconds: 500),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Group name and description
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.groupModel.groupName}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18.0,
                              color: Color(0xff3A3D43)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          widget.groupModel.isPrivate
                              ? FontAwesomeIcons.lock
                              : FontAwesomeIcons.lockOpen,
                          size: 15,
                          color: Color(0xff3A3D43),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${widget.groupModel.groupDescription}',
                        style: TextStyle(fontSize: 15.0, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (builder) => MapScreen(
                          myLat: widget.groupModel.latitude, myLong: widget.groupModel.longitude),
                    ),
                  );
                },
                trailing: const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 15,
                ),
                title: const Text(
                  "View Event Location",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (builder) => MediaEventScreen(
                      userLoggedIn: widget.userLoggedIn,
                      groupModel: widget.groupModel,
                    ),
                  ));
                },
                trailing: const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 15,
                ),
                title: const Text(
                  "View Media",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Visibility(
                visible: widget.groupModel.groupAdmin == widget.userLoggedIn.username,
                child: _adminSetting()),

            Visibility(
              visible: widget.groupModel.groupAdmin != widget.userLoggedIn.username,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  onTap: () async {
                    await CustomDialogs.showAppDialog(
                      context: context,
                      message: 'Are you sure you want to leave the event?',
                      buttonLabel2: 'Yes',
                      callbackMethod2: () => _leaveGroup(
                        username: widget.userLoggedIn.username,
                        channelID: widget.groupModel.id,
                      ),
                      buttonLabel1: 'No',
                      callbackMethod1: () async {
                        Navigator.of(context).pop(true);
                      },
                    );
                  },
                  trailing: const Icon(
                    FontAwesomeIcons.trashCan,
                    size: 15,
                    color: Color(0xFFF5505C),
                  ),
                  title: const Text(
                    "Leave Event",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFF5505C),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
              child: Text(
                "Group Members",
                style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            ...widget.groupModel.groupMemberList
                .where((member) => member.isMember) // Filter members where isMember is true
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
                                backgroundImage: const AssetImage(ImagesPaths.placeholderImage),
                              ),
                              fadeInDuration: const Duration(milliseconds: 500),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
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
                                if (member.username != widget.userLoggedIn.username &&
                                    widget.groupModel.isPrivate) {
                                  _goToUser(member);
                                }
                              },
                            ),
                            Text(
                              '${member.username}',
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                        (widget.groupModel.groupAdmin == member.username)
                            ? Container(
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  color: kPrimaryTransparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  "Admin",
                                  style: TextStyle(fontSize: 12, color: kPrimaryColor),
                                ))
                            : (widget.groupModel.groupAdmin == widget.userLoggedIn.username)
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (!(selectedUsers.contains(member.username))) {
                                          selectedUsers.add(member.username ?? "");
                                        } else {
                                          selectedUsers.remove(member.username);
                                        }
                                        _isOptionAppbar = true;
                                      });
                                    },
                                    icon: (_isOptionAppbar)
                                        ? (selectedUsers.contains(member.username)
                                            ? Icon(
                                                Icons.check,
                                                color: kPrimaryColor,
                                              )
                                            : Icon(
                                                Icons.remove,
                                                color: kErrorColor,
                                              ))
                                        : const Icon(Icons.more_vert_outlined),
                                  )
                                : const SizedBox(),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  _adminSetting() {
    return Column(
      children: [
        ListTile(
          onTap: () async {
            GroupModel groupModel = GroupModel();
            groupModel = await Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) => CreateGroupScreen(
                      loggedInUser: widget.userLoggedIn,
                      isEditMode: true,
                      groupModel: widget.groupModel,
                    )));
            if (groupModel.id != '-1') {
              widget.groupModel = groupModel;
              updateUsers(true);
              setState(() {});
            }
          },
          trailing: const Icon(
            FontAwesomeIcons.chevronRight,
            size: 15,
            color: Color(0xFF6F7895),
          ),
          title: const Text(
            "Edit Channel",
            style: TextStyle(fontSize: 15),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Divider(
            height: 1,
            color: Color(0xFFD6DBFD),
          ),
        ),
        ListTile(
          onTap: () {},
          trailing: Text(
            widget.groupModel.isPrivate ? "Private" : "Public",
            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          title: const Text(
            "Keep Channel Private",
            style: TextStyle(fontSize: 15),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Divider(
            height: 1,
            color: Color(0xFFD6DBFD),
          ),
        ),
        ListTile(
          onTap: () async {
            bool result = false;
            try {
              result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => AddMemberGroupScreen(
                      isEditMode: true,
                      userLoggedIn: widget.userLoggedIn,
                      groupModel: widget.groupModel,
                      membersList: widget.groupModel.groupMemberList,
                      onNextPressed: (selectedUsers) {
                        Navigator.of(context).pop();
                        //update the users;
                        updateUsers(result);
                      })));
              updateUsers(result);
            } catch (E) {
              Log.log(E.toString());
            }
          },
          trailing: const Icon(
            FontAwesomeIcons.chevronRight,
            size: 15,
            color: Color(0xFF6F7895),
          ),
          title: const Text(
            "Add Members",
            style: TextStyle(fontSize: 15),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Divider(
            height: 1,
            color: Color(0xFFD6DBFD),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void updateUsers(result) async {
    if (result) {
      CustomDialogs.showLoadingAnimation(context);
      widget.groupModel.groupMemberList =
          await ApiService().getGroupMembers(groupId: widget.groupModel.id);
      widget.updateChatDetails(widget.groupModel);
      setState(() {
        Navigator.of(context).pop();
      });
    }
  }

  _buildAppBar({required bool isOptionAppbar}) {
    return (isOptionAppbar)
        ? AppBar(
            title: Text(
              'Users Selected ( ${selectedUsers.length} )',
              style: TextStyle(color: kWhiteColor, fontSize: 17),
            ),
            backgroundColor: kPrimaryLight,
            foregroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () async {
                  Log.log(selectedUsers.toString());
                  await CustomDialogs.showAppDialog(
                    context: context,
                    message: 'Are you sure you want to remove these users?',
                    callbackMethod2: () => _deleteUsers(),
                    buttonLabel2: 'Yes',
                    callbackMethod1: () async {
                      Navigator.of(context).pop();
                    },
                    buttonLabel1: 'No',
                  );
                },
                icon: Icon(
                  FontAwesomeIcons.trashCan,
                  color: kWhiteColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isOptionAppbar = false;
                    selectedUsers = [];
                  });
                },
                icon: Icon(
                  Icons.close,
                  color: kWhiteColor,
                ),
              ),
            ],
          )
        : AppBar(
            title: const Text('Channel Information'),
            backgroundColor: kWhiteColor,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop(widget.groupModel);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.create,
                    color: kWhiteColor,
                  ))
            ],
          );
  }

  _deleteUsers() async {
    String commaSeparatedUsers = selectedUsers.join(', ');
    CustomDialogs.showLoadingAnimation(context);
    bool result = await ApiService()
        .deleteGroupMember(groupId: widget.groupModel.id, groupMembers: commaSeparatedUsers);
    if (result) {
      widget.groupModel.groupMemberList =
          await ApiService().getGroupMembers(groupId: widget.groupModel.id);
      setState(() {
        selectedUsers = [];
        _isOptionAppbar = false;
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        CustomSnackBar.showSuccessSnackBar(context, "Members are removed");
      });
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      CustomSnackBar.showErrorSnackBar(context, "Members couldnt be removed");
    }
  }

  getGroupData() async {
    widget.groupModel.groupMemberList =
        await ApiService().getGroupMembers(groupId: widget.groupModel.id);
    setState(() {});
  }

  _leaveGroup({required String username, required String channelID}) async {
    CustomDialogs.showLoadingAnimation(context);
    bool result = await ApiService().leaveChannel(username: username, channelID: channelID);
    if (result) {
      Navigator.of(context).pop(); //closes dialog
      Navigator.of(context).pop(); //closes loading
      CustomSnackBar.showSuccessSnackBar(context, "You have left the event");
      // Find the member who is leaving and remove them from the groupMemberList
      GroupMemberModel memberToRemove = widget.groupModel.groupMemberList.firstWhere(
        (element) => element.username == username,
      );

      Navigator.of(context).pop(); // closes the side menu
      Navigator.of(context)
          .pop(memberToRemove); // closes the group chat and sends back the groupmember that left
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      CustomSnackBar.showErrorSnackBar(context, "Error while leaving the Event");
    }
  }

  void _goToUser(GroupMemberModel member) async {
    CustomDialogs.showLoadingAnimation(context);

    BuddyModel buddyProfile = await getUserProfile(member.username!, widget.userLoggedIn.username);
    List<InterestChipModel> myInterestList = [];
    List<ImageModel> imageList = [];
    if (buddyProfile.id.isNotEmpty) {
      imageList = await getImages(member.username!);
      myInterestList = await getInterests(buddyProfile.selectedInterests!);
    }
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => UserProfileScreen(
                buddyData: buddyProfile,
                loggedInUser: widget.userLoggedIn,
                viewAsBuddyProfile: true,
                imagesList: imageList,
                myInterestList: myInterestList,
              )),
    );
  }
}

class MapScreen extends StatelessWidget {
  final double myLat;
  final double myLong;

  const MapScreen({super.key, required this.myLat, required this.myLong});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Location',
          style: TextStyle(color: Colors.black, fontSize: 17),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'share') {
                // Handle share location logic
                _shareLocation();
              } else if (value == 'openInMaps') {
                // Handle open in Google Maps logic
                _openInGoogleMaps();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'share',
                child: Text('Share'),
              ),
              const PopupMenuItem<String>(
                value: 'openInMaps',
                child: Text('Open in Google Maps'),
              ),
            ],
          ),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(myLat, myLong),
          zoom: 20,
        ),
        markers: {
          Marker(markerId: const MarkerId("Event Location"), position: LatLng(myLat, myLong)),
        },
        zoomControlsEnabled: false,
      ),
    );
  }

  void _shareLocation() {
    // Implement share location logic
    final String shareText = 'Here is where the EVENT name is happening at $myLat, $myLong';
    // Use share plugin or any other method to share the text
  }

  void _openInGoogleMaps() {
    // Implement open in Google Maps logic
    // You can use a URL scheme to open Google Maps with the specified location
    // Example URL: 'https://www.google.com/maps?q=$myLat,$myLong'
  }
}

class MediaEventScreen extends StatefulWidget {
  GroupModel groupModel;

  UserModel userLoggedIn;

  MediaEventScreen({super.key, required this.groupModel, required this.userLoggedIn});

  @override
  State<MediaEventScreen> createState() => _MediaEventScreenState();
}

class _MediaEventScreenState extends State<MediaEventScreen> {
  List<GroupMessageModel> msgPhotoList = [];

  @override
  void initState() {
    getAllPhotosViaFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Media"),
        backgroundColor: kWhiteColor,
        foregroundColor: kPrimaryColor,
        elevation: 0.2,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemCount: msgPhotoList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _openImage(index: index);
                  /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageFullScreen(
                                  imageUrlsList: const [],
                                  imageUrl:
                                  '${ApiUrls.chatAttachments}/${msgPhotoList[index].message}',
                                  imageName: widget.chatModel.fullName),
                            ),
                          );*/
                },
                child: CachedNetworkImage(
                  imageUrl: "${ApiUrls.groupsImageUrl}/${msgPhotoList[index].message}",
                  placeholder: (context, url) => Image.asset(ImagesPaths.placeholderAttach),
                  errorWidget: (context, url, error) => Image.asset(ImagesPaths.placeholderAttach),
                ),
              );
            },
          ),
          if (msgPhotoList.isEmpty)
            Center(
              child: Text(
                "NO MEDIA FOUND",
                style: TextStyle(color: kGreyDark),
              ),
            ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  void getAllPhotosViaFirebase() async {
    //get firebase collection using the widget.chatModel.id
    //Since all the chatModel is based
    msgPhotoList = await GroupService.getAllPhotosViaFirebase(
        widget.groupModel.id, widget.userLoggedIn.username);

    if (mounted) {
      setState(() {});
    }
  }

  _openImage({int index = 0}) {
    List<String> imageUrlList = [];
    for (GroupMessageModel group in msgPhotoList) {
      imageUrlList.add("${ApiUrls.groupsImageUrl}/${group.message}");
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageFullScreen(
          imageUrlsList: imageUrlList,
          isCarousel: true,
          initialIndex: index,
          imageUrl: "",
          imageName: "${msgPhotoList[index].sender}",
        ),
      ),
    );
  }
}
