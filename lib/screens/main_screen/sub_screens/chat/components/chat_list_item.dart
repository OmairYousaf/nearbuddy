import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../components/shimmer_widget.dart';
import '../../../../../constants/apis_urls.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/image_paths.dart';
import '../../../../../helper/utils.dart';
import '../../../../../models/chat_model.dart';
import '../../../../../models/user_model.dart';
import '../chatScreen/chat_screen.dart';

class ChatListItem extends StatelessWidget {
  ChatModel chatList;
  UserModel loggedInUser;
  bool isNewChatList;
  int index;
  bool isLandMode;
  final Function onLongPress;
  final Function onTapPress;

  ChatListItem({
    Key? key,
    required this.index,
    required this.chatList,
    required this.isNewChatList,
    required this.loggedInUser,
    required this.onLongPress,
    required this.onTapPress,
    required this.isLandMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onLongPress: () => onLongPress(),
        onTap: () => onTapPress(),
        child: Ink(
          padding: EdgeInsets.fromLTRB(5.0, index == 0 ? 0 : 15.0, 5.0, 15.0),
          decoration: BoxDecoration(
              color: kWhiteColor,
              border: const Border(bottom: BorderSide(color: Color(0xFFEAEAEA)))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: '${ApiUrls.usersImageUrl}/${chatList.profileImage}',
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundColor: kGrey,
                        radius: 30,
                        backgroundImage: imageProvider,
                      ),
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
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: chatList.userStatus.isActive
                        ? Container(
                            width: 15.0, // Specify the size
                            height: 15.0, // Specify the size
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, // Create a round shape
                                color: kGreenColor
                                // Specify the color
                                ),
                          )
                        : /*chatList.userStatus.onlineTime.isEmpty
                            ?*/ Container(
                                width: 12.0, // Specify the size
                                height: 12.0, // Specify the size
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Create a round shape
                                    color: kGrey
                                    // Specify the color
                                    ),
                              )
                          /*  : Container(
                                decoration: BoxDecoration(
                                  color: kGreyDark,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                                child: Text(
                                  Utils().formatOnlineTime(chatList.userStatus.onlineTime),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: kBlackLight,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),*/
                  )
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: null,
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft),
                      child: Text(
                        chatList.fullName,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ),
                    (chatList.message.isEmpty)
                        ? const ShimmerWidget.rectangular(height: 16, width: double.infinity)
                        : Text(
                            chatList.message,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                          ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('h:mm a').format(
                      chatList.newTimeStamp ?? DateTime.now(),
                    ),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF999999)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: (chatList.count > 0) ? kPrimaryColor : kWhiteColor,
                      shape: BoxShape.circle,
                    ),
                    child: (chatList.count > 0)
                        ? Center(
                            child: Text(
                              '${chatList.count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
