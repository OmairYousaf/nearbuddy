import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/models/group_member_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../components/controls.dart';
import '../../../../../../constants/apis_urls.dart';
import '../../../../../../constants/colors.dart';
import '../../../../../../constants/image_paths.dart';
import '../../../../../../helper/utils.dart';
import '../../../../../../models/buddy_model.dart';
import '../../../../../../models/group_model.dart';
import '../../../../../../models/user_model.dart';
import '../../../../../../routes/api_service.dart';

class AddMemberGroupScreen extends StatefulWidget {
  final bool isEditMode;
  List<GroupMemberModel> membersList = [];
  String groupID;
  GroupModel? groupModel;
  final UserModel userLoggedIn;
  final Function(List<BuddyModel>) onNextPressed;

  AddMemberGroupScreen(
      {required this.isEditMode,
      this.groupID = '-1',
      required this.onNextPressed,
      required this.userLoggedIn,
      this.membersList = const [],
      this.groupModel,
      super.key});

  @override
  State<AddMemberGroupScreen> createState() => _AddMemberGroupScreenState();
}

class _AddMemberGroupScreenState extends State<AddMemberGroupScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StreamController<BuddyModel> _userController =
      StreamController.broadcast();
  List<BuddyModel> selectedUsers = [];
  List<BuddyModel> usersFound = [];
  bool searchFlag = false;
  String searchResult = "Search by typing in usernames";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhiteColor,
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor: kWhiteColor,
          foregroundColor: const Color(0xFF575757),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop(false);
            },
          ),
          title: Text(
            (selectedUsers.isNotEmpty)
                ? "Add Members (${selectedUsers.length})"
                : "Add Members",
            style: TextStyle(color: kPurple, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (widget.isEditMode) {
                    FocusScope.of(context).unfocus();
                    addMembersGroup();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true); //true means updated
                  } else {
                    widget.onNextPressed(selectedUsers);
                  }
                },
                child: (widget.isEditMode)
                    ? const Text("Save")
                    : const Text("Next")),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: selectedUsers.isNotEmpty,
                    child: SizedBox(
                        height: 100,
                        child: GridView.count(
                          crossAxisCount: 5,
                          crossAxisSpacing: 5,
                          children:
                              List.generate(selectedUsers.length, (index) {
                            return Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      "${ApiUrls.usersImageUrl}/${selectedUsers[index].image}",
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                    radius: 40,
                                    backgroundColor: kGreyDark,
                                    child: CircleAvatar(
                                        backgroundColor: kGrey,
                                        radius: 35,
                                        backgroundImage: imageProvider),
                                  ),
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: CircleAvatar(
                                      radius: 30.0,
                                      backgroundColor: Colors.white,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Container(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                    backgroundColor: kGrey,
                                    radius: 30,
                                    backgroundImage: const AssetImage(
                                        ImagesPaths.placeholderImage),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: kBlack,
                                        size: 15,
                                      ),
                                      onPressed: () {
                                        // Handle the button press event
                                        selectedUsers.removeAt(index);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        )),
                  ),
                  buildSearchTextField(
                      textEditingController: _searchController,
                      onChanged: (text) {
                        setState(() {
                          searchFlag = true;
                          usersFound.clear();
                        });
                        if (text.length > 3) {
                          usersFound.clear();
                          searchForBuddy(text);
                        }
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  (searchFlag)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                              strokeWidth: 1,
                            ),
                          ),
                        )
                      : (usersFound.isEmpty)
                          ? TextButton.icon(
                              onPressed: null,
                              icon: (searchResult ==
                                      'Search by typing in usernames')
                                  ? const Icon(Icons.search)
                                  : const Icon(Icons.error),
                              label: Text(searchResult),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: ListView.builder(
                                itemCount: usersFound.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl:
                                              "${ApiUrls.usersImageUrl}/${usersFound[index].image}",
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  CircleAvatar(
                                            radius: 30,
                                            backgroundColor: kGreyDark,
                                            child: CircleAvatar(
                                                backgroundColor: kGrey,
                                                radius: 28,
                                                backgroundImage: imageProvider),
                                          ),
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: CircleAvatar(
                                              radius: 30.0,
                                              backgroundColor: Colors.white,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Container(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              CircleAvatar(
                                            backgroundColor: kGrey,
                                            radius: 30,
                                            backgroundImage: const AssetImage(
                                                ImagesPaths.placeholderImage),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${usersFound[index].name}, ${Utils().calculateAge(usersFound[index].birthday!)}",
                                                style: TextStyle(
                                                    color: kBlack,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15),
                                              ),
                                              Text(
                                                "${usersFound[index].username}",
                                                style: const TextStyle(
                                                    color: Color(0xFF949AB9)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 25,
                                          child: Checkbox(
                                            checkColor: Colors.white,
                                            fillColor: MaterialStateProperty
                                                .resolveWith(getColor),
                                            shape: const CircleBorder(),
                                            value: selectedUsers
                                                .contains(usersFound[index]),
                                            onChanged: (value) {
                                              setState(() {
                                                if (value != null &&
                                                    value == true) {
                                                  selectedUsers
                                                      .add(usersFound[index]);
                                                } else {
                                                  selectedUsers.remove(
                                                      usersFound[index]);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                ],
              ),
            ),
          ),
        ));
  }

  void searchForBuddy(String text) async {
    List<BuddyModel> users = await ApiService().getUserByUsername(
      username: text,
      myUsername: widget.userLoggedIn.username,
    );
    usersFound = [];

    if (users.isNotEmpty) {
      //checks if user is not empty
      for (var element in users) {
        //every element in users should be checked
        bool isAlreadyMember = false;
        //setting isAlreadyMember false we consider that its not part of the widget.memberList
        for (GroupMemberModel member in widget.membersList) {
          if (member.username == element.username) {
            isAlreadyMember = true;
            break;
          }
        }
        if (!isAlreadyMember) {
          usersFound.add(element);
        } else {
          searchResult = 'User is already part of the group chat';
        }
      }
    } else {
      searchResult = 'No User Found!';
    }

    setState(() {
      searchFlag = false;
    });
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return kPrimaryColor;
  }

  void addMembersGroup() async {
    CustomDialogs.showLoadingAnimation(context);
    for (BuddyModel users in selectedUsers) {
      widget.groupModel!.groupMemberList
          .add(GroupMemberModel(username: users.username));
    }
    String groupMembers = widget.groupModel!.groupMemberList
        .map((user) => user.username)
        .join(', ');
    bool result = await ApiService().updateGroup(
      groupId: widget.groupModel!.id,
      groupAdmin: widget.groupModel!.groupAdmin ?? "",
      groupDescription: widget.groupModel!.groupDescription ?? "",
      groupMembers: groupMembers,
      location: widget.groupModel!.location ?? "",
      groupIcon: widget.groupModel!.groupIcon ?? '',
      groupName: widget.groupModel!.groupName ?? '',
      isPrivate: widget.groupModel!.isPrivate ? '1' : '0',
    );
  }
}
