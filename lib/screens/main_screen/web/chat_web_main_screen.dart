import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/chat/chat_main_screen.dart';

import '../../../../components/custom_snack_bars.dart';
import '../../../../models/interest_chip_model.dart';
import '../../../models/chat_model.dart';
import '../../../responsive.dart';
import '../sub_screens/chat/chatScreen/chat_screen.dart';
import '../sub_screens/chat/my_requests_screen.dart';
import '../sub_screens/myProfile/components/set_schedule_screen.dart';

class ChatWebMainScreen extends StatefulWidget {
  UserModel loggedInUser;
  List<InterestChipModel> myInterestList;
  ChatWebMainScreen({Key? key, required this.loggedInUser, required this.myInterestList})
      : super(key: key);

  @override
  State<ChatWebMainScreen> createState() => _ChatWebMainScreenState();
}

class _ChatWebMainScreenState extends State<ChatWebMainScreen> {
  bool showChatListScreens = true;
  bool showChatScreen = false;
  bool showScheduleScreen = false;
  List<InterestChipModel> refinedInterestList = [];
  ChatModel? chatModel;
  bool isLandMode = false;
  @override
  void initState() {
    isLandMode = (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        build(context);
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: MediaQuery.of(context).size.width > 600 //set your width threshold here
            ? Row(
                children: [
                  Expanded(
                    child: (showChatListScreens)
                        ? ChatMainScreen(
                            loggedInUser: widget.loggedInUser,
                            myInterestList: widget.myInterestList,
                            onRequestClick: () {
                              setState(() {
                                showChatListScreens = !showChatListScreens;
                              });
                            },
                            onSetScheduleScreen: (List<InterestChipModel> intereests) {
                              showScheduleScreen = true;
                              showChatScreen = false;
                              setState(() {
                                refinedInterestList = intereests;
                              });
                            },
                            onChatListClick: (ChatModel chat) {
                              setState(() {
                                chatModel = chat;
                                showChatScreen = true;
                              });
                            },
                          )
                        : MyRequestScreen(
                            loggedInUser: widget.loggedInUser,
                            onPressedBack: () {
                              setState(() {
                                showChatListScreens = !showChatListScreens;
                              });
                            },
                          ),
                  ),
                  Expanded(
                      flex: 2,
                      child: (showChatScreen)
                          ? ChatScreen(
                              chatList: chatModel!,
                              userLoggedIn: widget.loggedInUser,
                              isNewChatlist: false,
                            )
                          : (showScheduleScreen)
                              ? SetScheduleScreen(
                                  loggedInUser: widget.loggedInUser,
                                  myInterestList: refinedInterestList,
                                  onScheduleSet: (bool result) {
                                    if (result) {
                                      setState(() {
                                        showScheduleScreen = false;
                                        build(context);

                                      });
                                    } else {
                                      CustomSnackBar.showErrorSnackBar(context, "Please try again");
                                    }
                                  },
                                )
                              : const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Tap on ChatList to Chat with friends"),
                                  ],
                                ))
                ],
              )
            : ChatMainScreen(
                loggedInUser: widget.loggedInUser, myInterestList: widget.myInterestList),
      ),
    );
  }
}
