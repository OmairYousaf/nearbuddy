import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/models/chat_message_model.dart';
import 'package:nearby_buddy_app/models/group_message_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../constants/apis_urls.dart';
import '../../../../../../constants/image_paths.dart';

import '../../../../../../components/image_full_screen.dart';

class ImageMessageBubble extends StatelessWidget {
  const ImageMessageBubble({
    super.key,
    this.chatMessage,
    required this.username,
    required this.onDelete,
    this.groupMessage,
  });

  final ChatMessageModel? chatMessage;
  final GroupMessageModel? groupMessage;
  final String username;
  final Function(String message,String sender) onDelete;

  @override
  Widget build(BuildContext context) {
    return (chatMessage == null)
        ? _buildGroupChatImageBubble(context)
        : _buildChatImageBubble(context);
  }

  Widget _buildChatImageBubble(context) {
    return Column(
      crossAxisAlignment: (chatMessage?.sender == username)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onLongPress: () {
            onDelete(chatMessage!.message,chatMessage!.sender);
          },
          child: Material(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0)),
            color:
                (chatMessage?.sender == username) ? kPrimaryColor : kWhiteColor,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageFullScreen(
                                imageUrlsList: const [],
                                imageUrl:
                                    '${ApiUrls.chatAttachments}/${chatMessage!.message}',
                                imageName: chatMessage!.message),
                          ),
                        );
                      },
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height / 5,
                          child: Hero(
                            tag: chatMessage!.message,
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${ApiUrls.chatAttachments}/${chatMessage!.message}',
                              placeholder: (context, url) =>
                                  Image.asset(ImagesPaths.placeholderAttach),
                              errorWidget: (context, url, error) =>
                                  Image.asset(ImagesPaths.placeholderAttach),
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      DateFormat('h:mm a').format(chatMessage!.time_stamp == null
                          ? DateTime.now()
                          : chatMessage!.time_stamp.toDate()),
                      style: TextStyle(
                        color: (chatMessage!.sender == username)
                            ? kWhiteColor
                            : kGrey,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupChatImageBubble(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: (groupMessage!.sender != username),
          child: CachedNetworkImage(
            imageUrl:
                "${ApiUrls.usersImageUrl}/${groupMessage?.groupMemberModel.image!}",
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 24,
              backgroundColor: kGreyDark,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: kGreyDark,
              ),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 24,
              backgroundColor: kGreyDark,
              child: Icon(
                Icons.person,
                color: kPrimaryColor,
              ),
            ),
          ),
        ),
        Visibility(
          visible: (groupMessage!.sender != username),
          child: const SizedBox(width: 10),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: (groupMessage?.sender == username)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                (groupMessage!.sender == username)
                    ? "You"
                    : "${groupMessage?.groupMemberModel.name}",
                style: TextStyle(
                  color: (groupMessage!.sender == username)
                      ? const Color(0xFF454545)
                      : const Color(0xff570D90),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Material(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    topRight: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0)),
                color: (groupMessage?.sender == username)
                    ? kPrimaryColor
                    : const Color(0xffF6F4F6),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImageFullScreen(
                                    imageUrlsList: const [],
                                    imageUrl:
                                        '${ApiUrls.groupsImageUrl}/${groupMessage!.message}',
                                    imageName: groupMessage!.message),
                              ),
                            );
                          },
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height / 5,
                              child: Hero(
                                tag: groupMessage!.message,
                                child: FadeInImage(
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.asset(
                                        ImagesPaths.placeholderAttach);
                                  },
                                  placeholder:
                                      const AssetImage(ImagesPaths.placeholderAttach),
                                  image: NetworkImage(
                                    '${ApiUrls.groupsImageUrl}/${groupMessage!.message}',
                                  ),
                                ),
                              )),
                        ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                DateFormat('h:mm a').format(groupMessage!.time_stamp == null
                    ? DateTime.now()
                    : groupMessage!.time_stamp.toDate()),
                style: TextStyle(
                  color: (groupMessage!.sender == username) ? kGrey : kGrey,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
