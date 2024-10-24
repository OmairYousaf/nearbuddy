import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/constants/apis_urls.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/chat/chatScreen/components/chat_side_menu.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../components/custom_dialogs.dart';
import '../../../../../components/image_full_screen.dart';
import '../../../../../constants/colors.dart';
import '../../../../../helper/utils.dart';
import '../../../../../models/buddy_model.dart';
import '../../../../../models/image_model.dart';
import '../../../../../models/interest_chip_model.dart';
import '../../../../../models/user_model.dart';

import '../../../../../models/chat_model.dart';

import '../../../../../responsive.dart';
import '../../../../../routes/api_service.dart';
import '../../../../../routes/profile_script.dart';
import '../../userProfile/user_profile_screen.dart';
import 'components/chat_message_bubble.dart';
import '../components/chat_provider.dart';
import 'package:path/path.dart' as path;

class ChatScreen extends StatefulWidget {
  ChatModel chatList;
  UserModel userLoggedIn;
  bool isNewChatlist;

  ChatScreen(
      {super.key, required this.chatList, required this.userLoggedIn, required this.isNewChatlist});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var chatController = TextEditingController();
  late ChatProvider chatProvider;
  bool isLandMode = false;
  late Timer _everySecond;
  @override
  void initState() {
    super.initState();
    isLandMode = (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());
    chatProvider = ChatProvider(
        chatList: widget.chatList,
        isNewChatlist: widget.isNewChatlist,
        chatID: chat_id,
        buddyUser: (widget.userLoggedIn.username == widget.chatList.user1)
            ? widget.chatList.user2
            : widget.chatList.user2,
        loggedInUser: widget.userLoggedIn);

    _everySecond = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _updateStatus();
    });
  }

  _updateStatus() async {
    String otherUser = chatProvider.chatList.user1 != widget.userLoggedIn.username
        ? chatProvider.chatList.user1
        : chatProvider.chatList.user2;

    UserStatus userStatus = await ApiService().getUserStatus(username: otherUser);

    if (mounted) {
      if (chatProvider.chatList.userStatus.isActive != userStatus.isActive) {
        setState(() {
          chatProvider.chatList.userStatus = userStatus;
        });
      } else {
        // No need to update the status as it remains the same
      }
    }
  }

  @override
  void dispose() {
    _everySecond.cancel();
    super.dispose();
  }

  String chat_id = "-1";
  PlatformFile? file;
  String? fileSize;
  String? filePath;
  bool isFile = false;
  bool _showImage = false;
  bool _isEditAppBarOpen = false;
  File? _imageFile;
  String message = '';
  List<ImageModel> imageList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: buildAppBar(context),
      ),
      body: SafeArea(
        child: Container(
          color: kWhiteColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(
                collectionReference: (widget.isNewChatlist)
                    ? FirebaseFirestore.instance.collection(chat_id)
                    : FirebaseFirestore.instance.collection(widget.chatList.id),
                username: widget.userLoggedIn.username,
                chatProvider: chatProvider,
                showImage: _showImage,
                imageFile: _imageFile,
                onLongPressImage: () {
                  //delete
                  _showImage = false;
                  _imageFile = null;
                  setState(() {});
                },
                onOptionMenu: (message, username) {
                  setState(() {
                    _isEditAppBarOpen = true;
                    this.message = message;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8.0),
                child: _buildTextBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildTextBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: const [
            BoxShadow(color: Color(0x40CBCBCB), offset: Offset(0, -7), blurRadius: 24)
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: TextFormField(
              controller: chatController,
              keyboardType: TextInputType.multiline,
              maxLines: 20,
              textInputAction: TextInputAction.send,
              minLines: 1,
              cursorColor: kPrimaryColor,
              onFieldSubmitted: (submit) {
                if (isLandMode) {
                  sendTextMessage();
                }
              },
              decoration: InputDecoration(
                  suffixIcon: SpeedDial(
                      backgroundColor: const Color(0xffF5F5F5),
                      icon: FontAwesomeIcons.camera,
                      foregroundColor: Colors.grey,
                      elevation: 0,
                      children: [
                        SpeedDialChild(
                          child: const Icon(
                            Icons.image,
                          ),
                          label: 'Gallery',
                          onTap: () {
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                        SpeedDialChild(
                          child: const Icon(
                            FontAwesomeIcons.camera,
                          ),
                          label: 'Camera',
                          onTap: () {
                            _pickImage(ImageSource.camera);
                          },
                        ),
                      ]),
                  hintText: 'Message ${widget.chatList.fullName} ...',
                  hintStyle: const TextStyle(fontSize: 11),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: InputBorder.none),
            ),
          )),
          Visibility(
            visible: !isLandMode,
            child: ElevatedButton(
              onPressed: () {
                sendTextMessage();
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                backgroundColor: kPrimaryColor, // <-- Button color
                foregroundColor: Colors.red, // <-- Splash color
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  buildAppBar(BuildContext context) {
    return (_isEditAppBarOpen)
        ? AppBar(
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.xmark),
              onPressed: () {
                setState(() {
                  _isEditAppBarOpen = false;
                });
              },
            ),
            actions: [
              IconButton(onPressed: deleteMessage, icon: const Icon(FontAwesomeIcons.trash))
            ],
          )
        : AppBar(
            elevation: 0.5,
            titleSpacing: 0,
            backgroundColor: kWhiteColor,
            automaticallyImplyLeading: false,
            leading: (isLandMode)
                ? null
                : IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF575757),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageFullScreen(
                            imageUrlsList: const [],
                            imageUrl: "${ApiUrls.usersImageUrl}/${widget.chatList.profileImage}",
                            imageName: widget.chatList.fullName),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: "${ApiUrls.usersImageUrl}/${widget.chatList.profileImage}",
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                            backgroundColor: kGrey,
                            radius: 24,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: CircleAvatar(
                              radius: 24.0,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: widget.chatList.userStatus.isActive
                              ? Container(
                                  width: 15.0, // Specify the size
                                  height: 15.0, // Specify the size
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, // Create a round shape
                                      color: kGreenColor
                                      // Specify the color
                                      ),
                                )
                              : Container(
                                  width: 15.0, // Specify the size
                                  height: 15.0, // Specify the size
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, // Create a round shape
                                      color: kGrey
                                      // Specify the color
                                      ),
                                ))
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        CustomDialogs.showLoadingAnimation(context);
                        String username = widget.chatList.user1 == widget.userLoggedIn.username
                            ? widget.chatList.user2
                            : widget.chatList.user1;
                        BuddyModel buddyProfile =
                            await getUserProfile(username, widget.userLoggedIn.username);
                        List<InterestChipModel> myInterestList = [];
                        if (buddyProfile.id.isNotEmpty) {
                          imageList = await getImages(username);
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
                      },
                      child: Text(
                        widget.chatList.fullName,
                        style: TextStyle(fontSize: 16, color: kBlack),
                      ),
                    ),
                    Text(
                      (widget.userLoggedIn.username == widget.chatList.user1)
                          ? "@${widget.chatList.user2}"
                          : "@${widget.chatList.user1}",
                      style: const TextStyle(fontSize: 9, color: Color(0xFF696969)),
                    ),
                    Text(
                      (widget.chatList.userStatus.isActive)
                          ? "Online"
                          : "Last Seen " +
                              Utils().formatOnlineTime(widget.chatList.userStatus.onlineTime),
                      style: TextStyle(
                        fontSize: 10,
                        color: kGreyDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Color(0xFF6D6D6D),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (c) => ChatSideMenu(
                          chatModel: chatProvider.chatList,
                          userLoggedIn: widget.userLoggedIn,
                          updateChatDetails: (ChatModel chatModel) {})));
                },
              ),
            ],
          );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      _imageFile = await Utils().getImageFromCamera(allowCrop: false);
    } else {
      _imageFile = await Utils().getImageFromGallery(allowCrop: false);
    }

    if (_imageFile != null) {
      setState(() {
        _showImage = true;
      });
    }
  }

  void sendTextMessage() async {
    if (_showImage) {
      await sendFileMessage();
      _showImage = false;
      _imageFile = null;
      //  Navigator.of(context).pop();
    }
    Log.log("MY CHATLIST ID NOW IS ${widget.chatList.id}");
    if (chatController.text.isNotEmpty) {
      if (widget.isNewChatlist) {
        if (chatController.text.isNotEmpty) {
          String result = await chatProvider.createChatList(
              message: chatController.text.toString(), type: MessageType.text); //automatically pushes the data
          chatProvider.sendPushNotification(message: chatController.text.trim()); //send Push Notification
          if (result != widget.chatList.id) {
            setState(() {
              chatController.clear();
              widget.chatList.id = result;
              Log.log(widget.chatList.id);
            });
          }
        }
      } else {
        chatProvider.pushFirebase(message: chatController.text.trim(), type: MessageType.text);
        chatProvider.sendPushNotification(message: chatController.text.trim());
      }
      setState(() {
        chatController.clear();
      });
    } else {
      setState(() {});
    }
  }

  void deleteMessage() {
    CustomDialogs.showLoadingAnimation(context);
    try {
      Log.log(
          "Delteing $message in ${widget.chatList.id} for ${widget.userLoggedIn.username} but if ${widget.isNewChatlist} then $chat_id");
      (widget.isNewChatlist)
          ? FirebaseFirestore.instance.collection(chat_id)
          : FirebaseFirestore.instance
              .collection(widget.chatList.id)
              .where('message', isEqualTo: message)
              .get()
              .then((querySnapshot) {
              Log.log(querySnapshot.toString());
              for (var doc in querySnapshot.docs) {
                if (doc['deleted_by'].toString().isEmpty) {
                  Log.log(doc.toString());
                  doc.reference.update({'deleted_by': widget.userLoggedIn.username});
                } else {
                  doc.reference.delete();
                }
              }
            });
    } catch (e) {
      _isEditAppBarOpen = false;
      CustomSnackBar.showErrorSnackBar(context, "try again");
      Log.log(e.toString());
    }
    setState(() {
      Navigator.of(context).pop();

      _isEditAppBarOpen = false;
    });
  }

  Future<bool> sendFileMessage() async {
    //  CustomDialogs.showLoadingDialog(context: context, text: 'Please wait while we send file');
    await chatProvider.uploadFile(_imageFile!);

    Log.log('This is the name of the imageFile ${_imageFile}');

    String fileName = path.basename(_imageFile!.path);

    chatProvider.sendPushNotification(message: fileName);

    return true;
  }
}

class MessagesStream extends StatelessWidget {
  final CollectionReference collectionReference;
  final String username;
  final ChatProvider chatProvider;
  final bool showImage;
  final File? imageFile;
  final Function() onLongPressImage;
  final Function(String, String) onOptionMenu;

  MessagesStream({
    Key? key,
    required this.collectionReference,
    required this.username,
    required this.onLongPressImage,
    required this.onOptionMenu,
    required this.chatProvider,
    required this.showImage,
    required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: chatProvider.getStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        List<MessageBubble> messageBubbles =
            chatProvider.getMessages(snapshot: snapshot, onOptionMenu: onOptionMenu);

        // Group messages by date
        Map<DateTime, List<MessageBubble>> groupedMessages = groupMessagesByDate(messageBubbles);

        return Expanded(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: [
                ListView.builder(
                  reverse: true,
                  itemCount: groupedMessages.length,
                  itemBuilder: (context, index) {
                    final groupDate = groupedMessages.keys.toList()[index];
                    final messagesForDate = groupedMessages[groupDate]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isToday(groupDate))
                          Center(
                              child: Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF1F1F1),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: const Text("Today",
                                style: TextStyle(
                                    color: Color(0xFFBDBDBD),
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold)),
                          )),
                        if (isYesterday(groupDate))
                          Center(
                              child: Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF1F1F1),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Text("Yesterday",
                                style: TextStyle(
                                    color: kGreyDark, fontSize: 12.0, fontWeight: FontWeight.bold)),
                          )),
                        if (!isToday(groupDate) && !isYesterday(groupDate))
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF1F1F1),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Text(DateFormat('dd MMMM yyyy').format(groupDate),
                                  style: TextStyle(
                                      color: kGreyDark,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ...messagesForDate,
                      ],
                    );
                  },
                ),
                if (showImage)
                  Positioned.fill(
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: InkWell(
                        onTap: () {
                          CustomSnackBar.showWarnSnackBar(context, "Press Longer to delete");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          margin: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(
                                    imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                IconButton(
                                    onPressed: onLongPressImage,
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Group messages by date
  Map<DateTime, List<MessageBubble>> groupMessagesByDate(List<MessageBubble> messages) {
    Map<DateTime, List<MessageBubble>> groupedMessages = {};

    for (var message in messages) {
      DateTime? messageDate = message.chatMessage.time_stamp?.toDate(); // Add null check here
      if (messageDate != null) {
        DateTime dayStart = DateTime(messageDate.year, messageDate.month, messageDate.day);

        if (groupedMessages.containsKey(dayStart)) {
          groupedMessages[dayStart]!.add(message);
        } else {
          groupedMessages[dayStart] = [message];
        }
      }
    }

    // Reverse the order of messages within each group
    groupedMessages.forEach((key, value) {
      groupedMessages[key] = value.reversed.toList();
    });
    return groupedMessages;
  }

  // Check if the given date is today
  bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }

  // Check if the given date is yesterday
  bool isYesterday(DateTime date) {
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    return yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day;
  }
}
