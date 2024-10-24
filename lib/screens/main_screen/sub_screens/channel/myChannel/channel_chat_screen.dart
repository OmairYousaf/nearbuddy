import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:nearby_buddy_app/constants/image_paths.dart';
import 'package:nearby_buddy_app/models/group_message_model.dart';
import 'package:nearby_buddy_app/models/group_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../components/custom_dialogs.dart';
import '../../../../../constants/apis_urls.dart';
import '../../../../../constants/colors.dart';
import '../../../../../helper/utils.dart';
import '../../../../../models/user_model.dart';

import '../../../../../responsive.dart';
import '../../chat/chatScreen/components/file_message_bubble.dart';

import '../../chat/chatScreen/components/image_message_bubble.dart';

import '../../chat/chatScreen/components/simple_text_bubble.dart';
import '../../chat/components/chat_provider.dart';
import 'components/group_chat_provider.dart';
import 'components/group_side_menu.dart';

class ChannelChatScreen extends StatefulWidget {
  GroupModel groupChatList; //contains groupchat information
  UserModel userLoggedIn; //the user that has logged in
  bool isGroupNewChatlist; //its new group chatList false when user has joined!
  Function(GroupModel) updateChatDetails;
  ChannelChatScreen(
      {super.key,
      required this.groupChatList,
      required this.userLoggedIn,
      required this.updateChatDetails,
      required this.isGroupNewChatlist});

  @override
  _ChannelChatScreenState createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {
  var chatController = TextEditingController();
  late GroupChatProvider groupChatProvider; //contains all the information
  bool isLandMode = false;
  @override
  void initState() {
    super.initState();
    groupChatProvider = GroupChatProvider(
        groupModel: widget.groupChatList,
        isNewGroupChatlist: widget.isGroupNewChatlist, //false
        members: widget.groupChatList.groupMemberList,
        loggedInUser: widget.userLoggedIn);
  }

  String group_id = "-1";
  PlatformFile? file;
  String? fileSize;
  String? filePath;
  bool isFile = false;
  bool _showImage = false;
  File? _imageFile;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    isLandMode = (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: buildAppBar(context),
      body: SafeArea(
        child: Container(
          color: kWhiteColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ChannelMessageStream(
                  collectionReference:
                      FirebaseFirestore.instance.collection("group${widget.groupChatList.id}"),
                  username: widget.userLoggedIn.username,
                  groupChatProvider: groupChatProvider,
                  showImage: _showImage,
                  imageFile: _imageFile,

                  onLongPress: () {
                    //delete
                    _showImage = false;
                    _imageFile = null;
                    setState(() {});
                  }),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: TextFormField(
                controller: chatController,
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                textInputAction: TextInputAction.send,
                minLines: 1,
                cursorColor: kPrimaryColor,
                onFieldSubmitted: (submit) {
                  sendTextMessage();
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
                    hintText: 'Enter Message ...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: InputBorder.none),
              ),
            ),
          )),
          ElevatedButton(
            onPressed: () {
              sendTextMessage();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              backgroundColor: kPrimaryColor, // <-- Button color
              foregroundColor: Colors.red, // <-- Splash color
            ),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: kIsWeb ? 22 : null,
            ),
          )
        ],
      ),
    );
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0.5,
      backgroundColor: kWhiteColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Color(0xFF575757),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: kGreyDark,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: kPrimaryColor,
              child: CachedNetworkImage(
                imageUrl: "${ApiUrls.groupsImageUrl}/${widget.groupChatList.groupIcon!}",
                errorWidget: (context, url, error) => const CircleAvatar(
                  radius: 24,
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
                  radius: 22,
                  backgroundImage: imageProvider,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.groupChatList.groupName}',
                style: TextStyle(fontSize: 16, color: kBlack),
              ),
              Text(
                'Created by ${widget.groupChatList.groupAdmin}',
                style: const TextStyle(fontSize: 9, color: Color(0xFF696969)),
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
          onPressed: () async {
            FocusScope.of(context).unfocus();
            try {
              GroupModel groupModel = GroupModel();
              groupModel = await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      GroupSideMenu(
                        groupModel: widget.groupChatList,
                        userLoggedIn: widget.userLoggedIn,
                          updateChatDetails:(GroupModel groupModel){
                          widget.updateChatDetails(groupModel);
                          }
                      ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
              if (groupModel.id != '-1') {
                setState(() {
                  widget.groupChatList = groupModel;
                });
              }
            }catch(e){
              Log.log(e);
            }
          },
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      _imageFile = await Utils().getImageFromCamera(allowCrop: true);
    } else {
      _imageFile = await Utils().getImageFromGallery(allowCrop: true);
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
      Navigator.of(context).pop();
    }

    if (chatController.text.isNotEmpty) {
      if (widget.isGroupNewChatlist) {
        if (chatController.text.isNotEmpty) {
          bool result = await groupChatProvider.createChatList(
              message: chatController.text.toString(), type: MessageType.text);
          groupChatProvider.sendPushNotification(message: chatController.text.trim());
          if (result) {
            setState(() {
              chatController.clear();
            });
          }
        }
      } else {
        groupChatProvider.pushFirebase(message: chatController.text.trim(), type: MessageType.text);
        groupChatProvider.sendPushNotification(message: chatController.text.trim());
      }
      setState(() {
        chatController.clear();
      });
    } else {
      setState(() {});
    }
  }

  Future<bool> sendFileMessage() async {
    CustomDialogs.showLoadingDialog(context: context, text: 'Please wait while we send file');
    await groupChatProvider.uploadFile(_imageFile!);

    groupChatProvider.sendPushNotification(message: chatController.text.trim());

    return true;
  }
}

class ChannelMessageStream extends StatelessWidget {
  CollectionReference collectionReference;
  String username;
  GroupChatProvider groupChatProvider;
  bool showImage;
  File? imageFile;
  Function() onLongPress;
  ChannelMessageStream(
      {super.key,
      required this.collectionReference,
      required this.username,
      required this.onLongPress,
      required this.groupChatProvider,
      required this.showImage,
      required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: groupChatProvider.getStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } //NO DATA!

        List<ChannelMessageBubble> messageBubbles = groupChatProvider.getMessages(snapshot);

        // Group messages by date
        Map<DateTime, List<ChannelMessageBubble>> groupedMessages = groupMessagesByDate(messageBubbles);
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
                showImage
                    ? Align(
                        alignment: Alignment.bottomLeft,
                        child: InkWell(
                          onLongPress: onLongPress,
                          onTap: () {
                            CustomSnackBar.showWarnSnackBar(context, "Press Longer to delete");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                image: DecorationImage(
                                  image: FileImage(imageFile!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<DateTime, List<ChannelMessageBubble>> groupMessagesByDate(List<ChannelMessageBubble> messages) {
    Map<DateTime, List<ChannelMessageBubble>> groupedMessages = {};

    for (var message in messages) {
      DateTime? messageDate = message.groupMessage.time_stamp?.toDate(); // Add null check here
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
//g

class ChannelMessageBubble extends StatelessWidget {
  GroupMessageModel groupMessage;
  CollectionReference collectionReference;

  String username;

  ChannelMessageBubble(
      {super.key,
      required this.groupMessage,
      required this.username,
      required this.collectionReference});

  @override
  Widget build(BuildContext context) {
    // iF OUR chatMessage has the
    return Container(
      margin: (groupMessage.sender == username)
          ? const EdgeInsets.fromLTRB(5, 5, 5, 5)
          : const EdgeInsets.fromLTRB(5, 5, 10, 5),
      child: showTypeBasedBubble(groupMessage.type, context),
    );
  }

  Widget showTypeBasedBubble(int type, BuildContext context) {
    Log.log(groupMessage.toString()+"inside showTYPE");
    if (type == MessageType.image.index) {
      return ImageMessageBubble(
        groupMessage: groupMessage,
        username: username,
        onDelete: (message, m) {
          deleteMessage(message, context);
        },
        chatMessage: null,
      );
    } else if (type == MessageType.file.index) {
      return FileMessageBubble(
        groupMessage: groupMessage,
        username: username,
        context: context,
        onDelete: (message) {
          deleteMessage(message, context);
        },
        chatMessage: null,
      );
    } else {
      return SimpleTextBubble(
        groupMessage: groupMessage,
        username: username,
        onDelete: (message, m) {
          deleteMessage(message, context);
        },
      );
    }
  }

  void deleteMessage(String message, BuildContext context) {
    collectionReference
        .where('sender', isEqualTo: username)
        .where('message', isEqualTo: message)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['deleted_by'].toString().isEmpty) {
          doc.reference.update({'deleted_by': username});
        } else {
          doc.reference.delete();
        }

        Navigator.of(context).pop();
      }
    });
  }
}
