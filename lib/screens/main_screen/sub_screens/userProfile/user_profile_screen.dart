import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/constants/icon_paths.dart';
import 'package:nearby_buddy_app/models/request_model.dart';
import 'package:nearby_buddy_app/responsive.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import 'package:nearby_buddy_app/models/chat_model.dart';

import '../../../../components/custom_dialogs.dart';
import '../../../../components/custom_snack_bars.dart';
import '../../../../components/dot_indicator.dart';
import '../../../../components/image_full_screen.dart';
import '../../../../components/interest_chip_widget.dart';
import '../../../../constants/apis_urls.dart';
import '../../../../constants/image_paths.dart';
import '../../../../helper/utils.dart';
import '../../../../models/buddy_model.dart';
import '../../../../models/image_model.dart';
import '../../../../models/interest_chip_model.dart';
import '../../../../models/user_model.dart';
import '../chat/chatScreen/chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final BuddyModel buddyData;
  final UserModel loggedInUser;
  final List<ImageModel> imagesList;
  List<InterestChipModel> myInterestList;
  final bool viewAsBuddyProfile;
  final Function? onRequestSent;

  UserProfileScreen(
      {Key? key,
      this.viewAsBuddyProfile = false,
      required this.buddyData,
      required this.loggedInUser,
      this.onRequestSent,
      required this.imagesList,
      required this.myInterestList})
      : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String chatID = "-1";
  late ChatModel chatList;
  bool isNewChatList = true;
  bool _isLoaded = false;
  late Timer _timer;
  final TextEditingController _messgaeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _startTimer();

    getUserData();
  }

  @override
  void dispose() {
    super.dispose();
    _stopTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          if (widget.imagesList.length > 1) {
            _currentIndex = (_currentIndex + 1) % widget.imagesList.length + 1;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {});
              }
            });
            if (_currentIndex == 3) {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
              );
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
              );
            }
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Log.log(Responsive.isMobileWeb().toString());
    return Scaffold(
        extendBodyBehindAppBar: (kIsWeb) ? false : true,
        appBar: (widget.viewAsBuddyProfile)
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color:kIsWeb?kPrimaryColor:  kWhiteColor,
                      width: 2.0,
                    ),
                  ))),
                  icon: Icon(
                    CupertinoIcons.chevron_back,
                    color: kIsWeb?kPrimaryColor: kWhiteColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(color: kIsWeb?kPrimaryColor: kWhiteColor,),
                ),
              )
            : null,
        backgroundColor: kWhiteColor,
        body: (_isLoaded)
            ? (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb())
                ? _buildWebView()
                : _buildMobileView()
            : Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 1,
                ),
              ));
  }

  _buildMobileView() {
    return SingleChildScrollView(
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    children: [
                      InkWell(
                        onTap: _openImage,
                        child: CachedNetworkImage(
                          imageUrl: "${ApiUrls.usersImageUrl}/${widget.buddyData.image}",
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Image.asset(
                            ImagesPaths.placeholderImage,
                          ),
                        ),
                      ),
                      for (int i = 0; i < widget.imagesList.length; i++)
                        InkWell(
                          onTap: () => _openImage(index: i + 1),
                          child: CachedNetworkImage(
                            imageUrl: "${ApiUrls.usersImageUrl}/${widget.imagesList[i].image}",
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Expanded(child: SizedBox()),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < widget.imagesList.length + 1; index++)
                        DotIndicator(isSelected: index == _currentIndex),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding:
                          EdgeInsets.fromLTRB(30, (widget.viewAsBuddyProfile) ? 50 : 30, 30, 10),
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                offset: Offset(0, -83),
                                color: Color(0x409740F3),
                                blurRadius: 20,
                                spreadRadius: 26.8)
                          ],
                          color: kWhiteColor,
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(40), topLeft: Radius.circular(40))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Text(
                                  "${widget.buddyData.name}, ${Utils().calculateAge(widget.buddyData.birthday ?? "")}",
                                  style: const TextStyle(
                                      color: Color(0xFF000000),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 25),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  (widget.buddyData.gender == "Female")
                                      ? FontAwesomeIcons.venus
                                      : FontAwesomeIcons.marsStrokeUp,
                                  color: (widget.buddyData.gender == "Female")
                                      ? kPinkColor
                                      : kPrimaryLight,
                                  size: 24,
                                )
                              ],
                            ),
                          ),
                          SelectableText(
                            "@${widget.buddyData.username!}",
                            style: const TextStyle(
                                color: Color(0xFF898989),
                                fontWeight: FontWeight.w400,
                                fontSize: 15),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "About",
                            style: TextStyle(
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                          Text(
                            "${widget.buddyData.bio}",
                            style: const TextStyle(
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Interests",
                            style: TextStyle(
                                color: Color(0xFF6B6B6B),
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildInterestsChips(),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.viewAsBuddyProfile,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: (widget.buddyData.requestStatus ==
                                            RequestStatus.NotSent ||
                                        widget.buddyData.requestStatus == RequestStatus.Declined)
                                    ? kPrimaryColor
                                    : kGreyDark,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(25)))),
                            onPressed: () {
                              if (widget.buddyData.requestStatus == RequestStatus.NotSent ||
                                  widget.buddyData.requestStatus == RequestStatus.Declined) {
                                CustomDialogs.showTextDialog(
                                    context: context,
                                    message: "Send a Message",
                                    sendTextController: _messgaeController,
                                    buttonLabel1: "SEND",
                                    callbackMethod1: () => _sendRequest(
                                          "${widget.buddyData.username}",
                                        ),
                                    buttonLabel2: "CANCEL",
                                    callbackMethod2: () {
                                      Navigator.of(context).pop();
                                    });
                              } else if (widget.buddyData.requestStatus == RequestStatus.Accepted) {
                                _navigateToChatList();
                              }
                            },
                            icon: Icon(
                              FontAwesomeIcons.handshake,
                              color: kWhiteColor,
                            ),
                            label: Text(
                              (widget.buddyData.requestStatus == RequestStatus.NotSent ||
                                      widget.buddyData.requestStatus == RequestStatus.Declined)
                                  ? "Connect"
                                  : (widget.buddyData.requestStatus == RequestStatus.Pending)
                                      ? "Pending Request"
                                      : "Lets Chat",
                              style: TextStyle(color: kWhiteColor),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          /* Visibility(
            visible: widget.viewAsBuddyProfile,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: kWhiteColor,
                      width: 2.0,
                    ),
                  ))),
                  icon: Icon(
                    CupertinoIcons.chevron_back,
                    color: kWhiteColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(color: kWhiteColor),
                ),
              ),
            ),
          )*/
        ],
      ),
    );
  }

  _buildWebView() {
    return Stack(
      children: [
        Row(
          children:[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50), bottomLeft: Radius.circular(50))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "${widget.buddyData.name}, ${Utils().calculateAge(widget.buddyData.birthday ?? "")}",
                          style: const TextStyle(
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.w600,
                              fontSize: 23),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Icon(
                        (widget.buddyData.gender == "Female")
                            ? FontAwesomeIcons.venus
                            : FontAwesomeIcons.marsStrokeUp,
                        color: (widget.buddyData.gender == "Female") ? kPinkColor : kPrimaryLight,
                        size: 24,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "@${widget.buddyData.username!}",
                    style: const TextStyle(
                        color: Color(0xFF898989), fontWeight: FontWeight.w400, fontSize: 15),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "About",
                    style: TextStyle(
                        color: Color(0xFF000000), fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${widget.buddyData.bio}",
                    style: const TextStyle(
                        color: Color(0xFF000000), fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Interests",
                    style: TextStyle(
                        color: Color(0xFF6B6B6B), fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildInterestsChips(),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: widget.viewAsBuddyProfile,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.buddyData.requestStatus == RequestStatus.NotSent ||
                            widget.buddyData.requestStatus == RequestStatus.Declined) {
                          CustomDialogs.showTextDialog(
                              context: context,
                              message: "Send a Message",
                              sendTextController: _messgaeController,
                              buttonLabel1: "SEND",
                              callbackMethod1: () => _sendRequest(
                                "${widget.buddyData.username}",
                              ),
                              buttonLabel2: "CANCEL",
                              callbackMethod2: () {
                                Navigator.of(context).pop();
                              });
                        } else if (widget.buddyData.requestStatus ==
                            RequestStatus.Accepted) {
                          _navigateToChatList();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        backgroundColor: kPrimaryDark, // <-- Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0), // <-- Rounded corners
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (widget.buddyData.requestStatus == RequestStatus.NotSent ||
                                widget.buddyData.requestStatus == RequestStatus.Declined)
                                ? "Connect"
                                : (widget.buddyData.requestStatus == RequestStatus.Pending)
                                ? "Pending Request"
                                : "Lets Chat",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SvgPicture.asset(
                            IconPaths.helloIcon, // Replace with your SVG path
                            width: 15 * 1.5, // Adjust the multiplier as needed
                            height: 15 * 1.5, // Adjust the multiplier as needed
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
            Expanded(
              flex: 1,
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                children: [
                  InkWell(
                    onTap: _openImage,
                    child: CachedNetworkImage(
                      imageUrl: "${ApiUrls.usersImageUrl}/${widget.buddyData.image}",
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(
                        ImagesPaths.placeholderImage,
                      ),
                    ),
                  ),
                  for (int i = 0; i < widget.imagesList.length; i++)
                    InkWell(
                      onTap: () => _openImage(index: i + 1),
                      child: CachedNetworkImage(
                        imageUrl: "${ApiUrls.usersImageUrl}/${widget.imagesList[i].image}",
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),

          ],
        ),
      ],
    );
  }

  _openImage({int index = 0}) {
    List<String> imageUrlList = ["${ApiUrls.usersImageUrl}/${widget.buddyData.image}"];
    for (ImageModel image in widget.imagesList) {
      imageUrlList.add("${ApiUrls.usersImageUrl}/${image.image}");
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageFullScreen(
          imageUrlsList: imageUrlList,
          isCarousel: true,
          initialIndex: index,
          imageUrl: "",
          imageName: "${widget.buddyData.name}",
        ),
      ),
    );
  }

  _buildInterestsChips() {
    return Wrap(
      spacing: (kIsWeb) ? 5 : 2,
      runSpacing: (kIsWeb) ? 5 : 0,
      children: widget.myInterestList
          .map((interestChip) => InterestChipWidget(
              backgroundColor: const Color(0x0fdcdcdc),
              selectedColor: const Color(0x0fdcdcdc),
              textColor: kBlackLight,
              interestChipModel: interestChip,
              interestSelected: (String name, InterestChipModel interest, bool interestSelected) {
                setState(() {
                  widget.myInterestList = widget.myInterestList.map((chip) {
                    final newChip = chip.copy(false);
                    return interestChip == newChip ? newChip.copy(interestSelected) : newChip;
                  }).toList();
                });
              }))
          .toList(),
    );
  }

  void _sendRequest(String receiver) async {
    if (_messgaeController.text.isNotEmpty) {
      CustomDialogs.showLoadingAnimation(context);
      bool result = await ApiService().sendRequest(
        sender: widget.loggedInUser.username,
        receiver: receiver,
        msg: _messgaeController.text.trim(),
      );
      if (result) {
        _messgaeController.text = "";
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        widget.buddyData.requestStatus = RequestStatus.Pending;
        if (widget.onRequestSent != null) {
          widget.onRequestSent!();
        }
        setState(() {
          Log.log(widget.buddyData.requestStatus.name);
        });
      } else {
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, "Connection Error");
      }
    } else {
      CustomSnackBar.showErrorSnackBar(context, "No Message Added");
    }
  }

  getUserData() {
    _isLoaded = true;
  }

  void _navigateToChatList() async {
    ChatModel chat =ChatModel(
      id: widget.buddyData.chatId ?? "-1",
      user1: widget.buddyData.username ?? "",
      user2: widget.loggedInUser.username,
      profileImage: widget.buddyData.image ?? "",
      fullName: widget.buddyData.name ?? "",
    );
    chat.userStatus = await ApiService().getUserStatus(
        username: chat.user1 != widget.loggedInUser.username
            ? chat.user1
            : chat.user2);
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ChatScreen(
                chatList: chat,
                userLoggedIn: widget.loggedInUser,
                isNewChatlist: false,
              )),
    );
  }
}
