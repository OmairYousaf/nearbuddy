import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/constants/lottie_paths.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/request_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../../components/custom_snack_bars.dart';
import '../../../../models/interest_chip_model.dart';
import '../../../../models/schedule_model.dart';
import '../../../../responsive.dart';
import '../../../../models/chat_model.dart';

import '../myProfile/components/my_schedule_screen.dart';
import '../myProfile/components/set_schedule_screen.dart';
import 'chatScreen/chat_screen.dart';
import 'chatScreen/components/shimmer_chat_widget.dart';
import 'components/chat_list_item.dart';
import 'my_requests_screen.dart';

class ChatMainScreen extends StatefulWidget {
  UserModel loggedInUser;
  List<InterestChipModel> myInterestList;

  Function? onRequestClick;
  Function(ChatModel)? onChatListClick;
  Function(List<InterestChipModel>)? onSetScheduleScreen;
  ChatMainScreen(
      {Key? key,
      required this.loggedInUser,
      required this.myInterestList,
      this.onRequestClick,
      this.onChatListClick,
      this.onSetScheduleScreen})
      : super(key: key);
  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedScreen = 0; //O means MyChats and 1 means MySchedule
  late StreamController<ChatModel> _chatStreamController;
  List<ChatModel> chatList = [];
  List<RequestModel> requestList = [];
  String searchText = '';
  int receivedRequests = 0;
  int seconds =
      100; //seconds for refresh after which the chat will be updated with new firebase data
  List<ScheduleModel> scheduleList = [];
  late Timer _everySecond;
  late Timer _everySecond2;
  bool isLandMode = false;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _chatStreamController = StreamController.broadcast();
    isLandMode =
        (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());
    init();

    super.initState();
  }

  void init() async {
    await getChatList();
    await getSchedules();
    await getRequests(false);
   _initTimers();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: _tabController.index == 1,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            onPressed: () async {
              if (refineInterestList(widget.myInterestList, scheduleList)
                  .isEmpty) {
                CustomSnackBar.showBasicSnackBar(
                    context, "All interests schedule has been set");
                return;
              }
              if (isLandMode) {
                widget.onSetScheduleScreen!(
                    refineInterestList(widget.myInterestList, scheduleList));
              } else {
               bool? result= await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SetScheduleScreen(
                      loggedInUser: widget.loggedInUser,
                      myInterestList: refineInterestList(
                          widget.myInterestList, scheduleList),
                    ),
                  ),
                );
               if(result??false){
                 getSchedules();
                 setState(() {

                 });
               }
              }
            },
            backgroundColor: kPrimaryColor,
            foregroundColor: kWhiteColor,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Chat",
          style: TextStyle(
              fontSize: 18, color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                InkWell(
                  onTap: () async {
                    if (!isLandMode) {
                      bool? reload = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (c) => MyRequestScreen(
                                  loggedInUser: widget.loggedInUser)));
                      setState(() {
                        getRequests(reload ?? false);
                      });
                    } else {
                      widget.onRequestClick!();
                    }
                  },
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.group,
                      size: 24,
                      color: Color(0xFF949AB9),
                    ),
                  ),
                ),
                if (receivedRequests>0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red, // Choose your desired badge color
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${receivedRequests}', // Or any number you want to display as a badge
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Chats'),
            Tab(
              text: 'My Schedule',
            ),
          ],
          labelColor: kBlack,
          unselectedLabelColor: kGreyDark,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: kPrimaryColor),
            insets: const EdgeInsets.symmetric(horizontal: 100.0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatTabView(),
                  _buildScheduleTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  _buildChatTabView() {
    return StreamBuilder<ChatModel>(
      stream: _chatStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot<ChatModel> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.id == '-1') {
            return Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      LottieFiles.animationChat,
                      repeat: true,
                      reverse: true,
                    ),
                  ),
                  const Text(
                    "Personal chats are a great way of sharing information",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            // Sort the chatLists based on newTimeStamp in descending order


           /* List<ChatModel> filteredChatList = chatList.where((chat) {
              final String username = chat.fullName.toLowerCase();
              final String message = chat.message.toLowerCase();
              final String searchValue = searchText.toLowerCase();
              return username.contains(searchValue) ||
                  message.contains(searchValue);
            }).toList();*/

            // Display the filtered chat list
            return ListView.builder(
              itemCount: chatList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int ind) {
                return ChatListItem(
                  isNewChatList: false,
                  index: ind,
                  loggedInUser: widget.loggedInUser,
                  chatList: chatList[ind],
                  isLandMode: isLandMode,
                  onTapPress: () async {
                    if (isLandMode) {
                      widget.onChatListClick!(chatList[ind]);
                    } else {

                     await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatList: chatList[ind],
                              userLoggedIn: widget.loggedInUser,
                              isNewChatlist: false,
                            )),
                      );

                    }
                  },
                  onLongPress: () async {
                    await CustomDialogs.showAppDialog(
                      context: context,
                      message: 'Are you sure you want to delete this chat?',
                      callbackMethod2: () =>
                          _deleteChatList(chatListId: chatList[ind]),
                      buttonLabel2: 'Yes',
                      callbackMethod1: () async {
                        Navigator.of(context).pop();
                      },
                      buttonLabel1: 'No',
                    );
                  },

                );
              },
            );
          }
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: 3,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return const ShimmerChatWidget();
            },
          );
        }
      },
    );
  }


  _updateChatListData(bool isNewChats) async {
    if (isNewChats) {
      getChatList();
    }
    try {
      await Future.forEach(chatList, (ChatModel chat) async {
        CollectionReference collectionReference =
            FirebaseFirestore.instance.collection(chat.id);

        QuerySnapshot querySnapshot = await collectionReference
            .orderBy('time_stamp', descending: true)
            .limit(1)
            .get();

        // Rest of your existing logic
        // Get data from docs and convert map to List
        if (querySnapshot.docs.isNotEmpty) {
          var a = querySnapshot.docs[0];
          if (a['type'] == 0) {
            chat.message = a['message'];
          } else if (a['type'] == 1) {
            chat.message = '📷 Shared an Image';
          } else if (a['type'] == 2) {
            chat.message = '📄 Shared a Document';
          } else if (a['type'] == 3) {
            chat.message = 'Shared a Post';
          }

          if (a['receiver'].toString() == widget.loggedInUser.username) {
            chat.isRead = a['isRead'];
          }
          chat.newTimeStamp = a['time_stamp'].toDate();
          QuerySnapshot querySnapshot2 = await collectionReference
              .where('isRead', isEqualTo: false)
              .where('receiver', isEqualTo: widget.loggedInUser.username)
              .get();
          if (chat.count != querySnapshot2.docs.length) {
            chat.count = querySnapshot2.docs.length;
          }
        }

        if (chat.message.isNotEmpty &&
            chat.deletedBy != widget.loggedInUser.username) {
          // Update the chatList locally
          _chatStreamController.sink.add(chat);
        }
      });

      if (mounted) {
        chatList.sort((a, b) => b.newTimeStamp.compareTo(a.newTimeStamp));
        setState(() {});
      }

    } catch (e) {

      Log.log('Error in updateChatList loop: ${e.toString()}');
    }
  }
  _updateChatOnlineStatus(bool isNewChats) async {
    if (isNewChats) {
      getChatList();
    }
    try {
      await Future.forEach(chatList, (ChatModel chat) async {
        chat.userStatus = await ApiService().getUserStatus(
            username: chat.user1 != widget.loggedInUser.username
                ? chat.user1
                : chat.user2);
      });

      if(mounted){
        setState(() {

        });
      }

    } catch (e) {

      Log.log('Error in updateChatList loop: ${e.toString()}');
    }
  }

  Future<void> getChatList() async {
    try{
      chatList =
      await ApiService().getChatList(username: widget.loggedInUser.username);
      ChatModel.sortByTimeStamp(chatList);
      if (mounted) {

        if (chatList.isNotEmpty) {
          for (ChatModel element in chatList) {
            _chatStreamController.sink.add(element);
          }
        } else {
          _chatStreamController.sink.add(ChatModel(id: '-1'));
        }
        _updateChatOnlineStatus(false);
        _updateChatListData(false);
        setState(() {

        });
      }
    }catch(e){
      if (mounted) {

        _chatStreamController.sink.add(ChatModel(id: '-1'));


        _updateChatListData(false);
        setState(() {

        });
      }
    }
  }

  _buildScheduleTabView() {
    return FutureBuilder<List<ScheduleModel>>(
      future: Future.value(scheduleList),
      builder:
          (BuildContext context, AsyncSnapshot<List<ScheduleModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () => getSchedules(),
              child: ListView.builder(
                cacheExtent: 900,
                itemCount: scheduleList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  ScheduleModel schedule = scheduleList[index];
                  return ScheduleItem(
                      isOn: schedule.switchValue == "1",
                      isScheduledByMe: scheduleList[index].username ==
                          widget.loggedInUser.username,
                      interest: scheduleList[index].interest.name,
                      days: schedule.days,
                      time: schedule.time,
                      persons: schedule.persons,
                      username: scheduleList[index].username,
                      onChanged: (bool? value) async {
                        CustomDialogs.showLoadingAnimation(context);
                        String switchValue = value ?? false ? "1" : "0";
                        await ApiService().schedulingSwitch(
                            isActive: switchValue,
                            scheduleId: scheduleList[index].id);
                        setState(() {
                          scheduleList[index].switchValue =
                          value ?? false ? "1" : "0";
                        });

                        Navigator.of(context).pop();
                        (scheduleList[index].switchValue == "1")
                            ? CustomSnackBar.showBasicSnackBar(
                            context, "Schedule has been notified!")
                            : CustomSnackBar.showBasicSnackBar(context,
                            "Schedule for this interest has been removed!");
                      },
                      onTap: () async {
                        try {
                          bool result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SetScheduleScreen(
                                isEditMode: true,
                                loggedInUser: widget.loggedInUser,
                                myInterestList: widget.myInterestList,
                                scheduleModel: scheduleList[index],
                              ),
                            ),
                          );
                          if(result??false){
                            getSchedules();
                            setState(() {

                            });
                          }
                        } catch (e) {
                          Log.log(e.toString());
                        }
                      });
                },
              ),
            );
          } else {
            return RefreshIndicator(
                onRefresh: () => getSchedules(),
                child: Stack(
                  children: <Widget>[
                    ListView(),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.faceSmile,
                            color: kGreyDark,
                            size: 50,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "You will get your connection requests here",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: kGreyDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () => getSchedules(),
            child: ListView.builder(
              padding: const EdgeInsets.all(5),
              itemCount: 3,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return const ShimmerChatWidget();
              },
            ),
          );
        }
      },
    );
  }

  Future<List<ScheduleModel>> getSchedules() async {
    scheduleList =
    await ApiService().showSchedule(username: widget.loggedInUser.username);
    setState(() {});
    return scheduleList;
  }

  getRequests(bool reload) async {
    var list = await ApiService()
        .getRecievedRequests(username: widget.loggedInUser.username);
    receivedRequests = list.length;
    _updateChatListData(reload);
    if (mounted) {
      setState(() {});
    }
  }

  List<InterestChipModel> refineInterestList(
      List<InterestChipModel> myInterestList,
      List<ScheduleModel> scheduleList) {
    final List<String> interestIds =
        scheduleList.map((schedule) => schedule.interest.id).toList();

    return myInterestList
        .where((interest) => !interestIds.contains(interest.catID))
        .toList();
  }

  _deleteChatList({required ChatModel chatListId}) async {
    Navigator.of(context).pop();
    CustomDialogs.showLoadingAnimation(context);
    try {
      bool result = await ApiService().deleteChatList(
          username: widget.loggedInUser.username, chatID: chatListId.id);
      if (result) {
        FirebaseFirestore.instance
            .collection(chatListId.id)
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            if (doc['deleted_by'].toString().isEmpty) {
              Log.log(
                  "Deleting message for ${chatListId.id} and the message is ${doc['message']}");
              doc.reference
                  .update({'deleted_by': widget.loggedInUser.username});
            } else {
              Log.log(
                  "Deleting message for ${chatListId.id} is already checked for deleted");
              doc.reference.delete();
            }
          }
        });
        chatList.remove(chatListId);
        await _updateChatListData(true);

        Navigator.of(context).pop();
        setState(() {});
      } else {
        CustomSnackBar.showErrorSnackBar(
            context, 'Unknown Error! Please try again');
      }
    } catch (e) {
      Log.log(e.toString());
    }
  }

  _initTimers(){
    _everySecond2 = Timer.periodic(const Duration(seconds: 20), (Timer t) {
      Log.log("updating status and getting schedules");
      _updateChatOnlineStatus(false);
      if (kIsWeb) {
        getSchedules();
      }
    });
    _everySecond = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      Log.log("updating chatList");
      _updateChatListData(false);
      if (kIsWeb) {
        getSchedules();
      }
    });
  }
  _cancelTimers(){
    _everySecond.cancel();
    _everySecond2.cancel();
  }
}
