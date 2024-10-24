import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../components/custom_dialogs.dart';
import '../../../../constants/colors.dart';
import '../../../../models/buddy_model.dart';
import '../../../../models/image_model.dart';
import '../../../../models/interest_chip_model.dart';
import '../../../../models/user_model.dart';
import '../../../../models/request_model.dart';
import '../../../../responsive.dart';
import '../../../../routes/api_service.dart';
import '../../../../routes/profile_script.dart';
import '../userProfile/user_profile_screen.dart';
import 'chatScreen/components/shimmer_chat_widget.dart';
import 'components/chat_provider.dart';
import 'components/request_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRequestScreen extends StatefulWidget {
  UserModel loggedInUser;
  Function? onPressedBack;

  MyRequestScreen({Key? key, required this.loggedInUser, this.onPressedBack})
      : super(key: key);

  @override
  State<MyRequestScreen> createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen>
    with SingleTickerProviderStateMixin {
  List<RequestModel> receivedRList = [];
  List<RequestModel> sentRList = [];
  late TabController _tabController; //controller
  final bool _showAppBar = false;
  bool isLandMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    isLandMode =
        (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());
    getConnectionRequests();
  }

  Future<void> getConnectionRequests() async {
    sentRList = await ApiService()
        .getSentRequests(username: widget.loggedInUser.username);
    receivedRList = await ApiService()
        .getRecievedRequests(username: widget.loggedInUser.username);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            if (isLandMode) {
              widget.onPressedBack!();
            } else {
              Navigator.of(context).pop(true);
            }
          },
        ),
        title: const Text(
          'My Connect Request',
          style: TextStyle(fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received'),
            Tab(
              text: 'Sent',
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
                  _buildRecievedRequest(),
                  _buildSentRequest(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildSentRequest() {
    return FutureBuilder<List<RequestModel>>(
      future: Future.value(sentRList),
      builder:
          (BuildContext context, AsyncSnapshot<List<RequestModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () => getConnectionRequests(),
              child: ListView.builder(
                cacheExtent: 900,
                itemCount: sentRList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return RequestListItem(
                    index: index,
                    isSentRequests: true,
                    requestModel: sentRList[index],
                    loggedInUser: widget.loggedInUser,
                    onSetRequestStatus: (
                        {required String chatID, required int index}) {
                      sentRList.removeAt(index);
                      setState(() {});
                    },
                    getProfileUser: () =>
                        getUser(sentRList[index].username ?? ""),
                  );
                },
              ),
            );
          } else {
            return RefreshIndicator(
                onRefresh: () => getConnectionRequests(),
                child: Stack(
                  children: <Widget>[
                    ListView(),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.smile,
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
            onRefresh: () => getConnectionRequests(),
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

  _buildRecievedRequest() {
    return FutureBuilder<List<RequestModel>>(
      future: Future.value(receivedRList),
      builder:
          (BuildContext context, AsyncSnapshot<List<RequestModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () => getConnectionRequests(),
              child: ListView.builder(
                cacheExtent: 900,
                itemCount: receivedRList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int ind) {
                  return RequestListItem(
                    requestModel: receivedRList[ind],
                    loggedInUser: widget.loggedInUser,
                    index: ind,
                    onSetRequestStatus: (
                        {required String chatID, required int index}) {
                      _createChatList(
                          requesterUsername:
                              receivedRList[index].username ?? "",
                          message: receivedRList[index].msg ?? "",
                          chatId: chatID,
                          index: index);
                    },
                    getProfileUser: () =>
                        getUser(receivedRList[ind].username ?? ""),
                  );
                },
              ),
            );
          } else {
            return RefreshIndicator(
                onRefresh: () => getConnectionRequests(),
                child: Stack(
                  children: <Widget>[
                    ListView(),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.smile,
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
            onRefresh: () => getConnectionRequests(),
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

  Future<void> _createChatList(
      {required String requesterUsername,
      required String message,
      required String chatId,
      required int index}) async {
    CustomDialogs.showLoadingAnimation(context);
    /*  String chatID = await ApiService().createNewChatList(
        sender: requesterUsername, receiver: widget.loggedInUser.username);*/
    if (chatId.isNotEmpty) {
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection(chatId);
      collectionRef.doc().set({
        'message': message.trim(), //bonus
        'receiver': widget.loggedInUser.username,
        'sender': requesterUsername,
        'time_stamp': FieldValue.serverTimestamp(), //bonus
        'type': MessageType.text.index,
        'isRead': false,
        'deleted_by': "",
      });
      //bonus
    }
    Navigator.of(context).pop();

    setState(() {
      receivedRList.removeAt(index);
    });
  }

  getUser(String username) async {
    CustomDialogs.showLoadingAnimation(context);

    BuddyModel buddyProfile =
        await getUserProfile(username, widget.loggedInUser.username);
    List<InterestChipModel> myInterestList = [];
    List<ImageModel> imageList = [];
    if (buddyProfile.id.isNotEmpty) {
      imageList = await getImages(username);
      myInterestList = await getInterests(buddyProfile.selectedInterests!);
    }
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => UserProfileScreen(
                buddyData: buddyProfile,
                loggedInUser: widget.loggedInUser,
                viewAsBuddyProfile: true,
                imagesList: imageList,
                myInterestList: myInterestList,
              )),
    );
  }
}
