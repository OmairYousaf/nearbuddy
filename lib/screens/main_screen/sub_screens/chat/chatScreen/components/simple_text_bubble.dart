import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/group_message_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../constants/apis_urls.dart';
import '../../../../../../constants/colors.dart';
import '../../../../../../constants/image_paths.dart';
import '../../../../../../models/chat_message_model.dart';

class SimpleTextBubble extends StatelessWidget {
  const SimpleTextBubble({
    super.key,
    this.chatMessage,
    this.groupMessage,
    required this.username,
    required this.onDelete,
  });

  final ChatMessageModel? chatMessage;
  final GroupMessageModel? groupMessage;
  final String username;
  final Function(String message, String sender) onDelete;

  @override
  Widget build(BuildContext context) {
    return (chatMessage == null) ? _buildGroupChatList() : _buildChatList();
  }

  Widget _buildChatList() {
    return Column(
      crossAxisAlignment: (chatMessage!.sender == username)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            onDelete(chatMessage!.message, chatMessage!.sender);
          },
          child: Material(
            borderRadius: (chatMessage!.sender == username)
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(0.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            color: (chatMessage!.sender == username)
                ? kPrimaryColor
                : const Color(0xffF6F4F6),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: (chatMessage!.sender == username)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      (chatMessage!.message),
                      textAlign: (chatMessage!.sender == username)
                          ? TextAlign.end
                          : TextAlign.start,
                      style: TextStyle(
                        color: (chatMessage!.sender == username)
                            ? kWhiteColor
                            : kBlack,
                        fontSize: isMessageEmoji(chatMessage!.message) ? 30.0 : 15.0, // Adjust font ,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    DateFormat('h:mm a').format(chatMessage!.time_stamp == null
                        ? DateTime.now()
                        : chatMessage!.time_stamp.toDate()),
                    style: TextStyle(
                        color: (chatMessage!.sender == username)
                            ? kWhiteColor
                            : kGreyDark,
                        fontSize: 9.0,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupChatList() {
   // Log.log(groupMessage.toString());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: (groupMessage!.sender != username),
          child: ClipOval(
              child: CachedNetworkImage(
                imageUrl:
                "${ApiUrls.usersImageUrl}/${groupMessage?.groupMemberModel.image!}",
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
                      borderRadius: BorderRadius.circular(200),
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: kGrey,
                  radius: 24,
                  backgroundImage:
                  const AssetImage(ImagesPaths.placeholderImage),
                ),
              )),
        ),
        Visibility(
          visible: (groupMessage!.sender != username),
          child: const SizedBox(width: 10),
        ),
        Expanded(
          child: Container(
            margin: (groupMessage!.sender != username)
                ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
                : const EdgeInsets.fromLTRB(100, 0, 0, 0),
            child: Column(
              crossAxisAlignment: (groupMessage?.sender == username)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                (groupMessage!.sender == username)
                    ? const SizedBox()
                    : Text(
                        "${groupMessage?.groupMemberModel.name!}",
                        style: TextStyle(
                          color: (groupMessage!.sender == username)
                              ? const Color(0xFF454545)
                              : const Color(0xff570D90),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                (groupMessage!.sender == username)
                    ? const SizedBox()
                    : const SizedBox(
                        height: 5,
                      ),
                GestureDetector(
                  onLongPress: () {},
                  child: Material(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        (groupMessage!.sender == username) ? 20.0 : 0.0,
                      ),
                      topRight: Radius.circular(
                        (groupMessage!.sender != username) ? 20.0 : 0.0,
                      ),
                      bottomLeft: const Radius.circular(20.0),
                      bottomRight: const Radius.circular(20.0),
                    ),
                    color: (groupMessage!.sender == username)
                        ? kPrimaryColor
                        : const Color(0xffF6F4F6),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        crossAxisAlignment: (groupMessage?.sender == username)
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            (groupMessage!.message),
                            textAlign: (groupMessage!.sender == username)
                                ? TextAlign.end
                                : TextAlign.start,
                            style: TextStyle(
                              color: (groupMessage!.sender == username)
                                  ? kWhiteColor
                                  : kBlack,
                              fontSize:  isMessageEmoji(groupMessage!.message) ? 30.0 : 15.0,
    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                (false)
                    ? Text(
                        DateFormat('kk:mm').format(
                          groupMessage!.time_stamp == null
                              ? DateTime.now()
                              : groupMessage!.time_stamp.toDate(),
                        ),
                        textAlign: (groupMessage!.sender == username)
                            ? TextAlign.end
                            : TextAlign.start,
                        style: TextStyle(
                          color: (groupMessage!.sender == username)
                              ? kGreyDark
                              : kGreyDark,
                          fontSize: 10.0,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  bool isMessageEmoji(String text) {
    Log.log(text);
    var emojiParser = EmojiParser();
    // Use EmojiParser to parse the message
    var parsed = emojiParser.hasEmoji(text);

    // If the parsed message is the same as the original message, it means it's an emoji
    return parsed;
  }

}
