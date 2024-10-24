import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/models/chat_message_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';

import '../../../../../../components/image_full_screen.dart';
import '../../../../../../constants/apis_urls.dart';
import '../../../../../../constants/image_paths.dart';

import '../../../../../../models/chat_model.dart';
import '../../../../../../models/image_model.dart';

class ChatSideMenu extends StatefulWidget {
  ChatModel chatModel;
  final UserModel userLoggedIn;
  Function(ChatModel) updateChatDetails;
  //WE NEED A REF TO THAT CHAT HERE;

  ChatSideMenu(
      {Key? key,
      required this.chatModel,
      required this.userLoggedIn,
      required this.updateChatDetails})
      : super(key: key);

  @override
  State<ChatSideMenu> createState() => _ChatSideMenuState();
}

class _ChatSideMenuState extends State<ChatSideMenu> {
  bool _isOptionAppbar = false;
  List<ChatMessageModel> msgPhotoList = [];
  @override
  void initState() {
    super.initState();
    getAllPhotosViaFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        foregroundColor: kPrimaryColor,
        elevation: 0.2,
        title: Text("${widget.chatModel.fullName}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            // Group icon and change button
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: kGreyDark,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageFullScreen(
                                imageUrlsList: const [],
                                imageUrl:
                                    "${ApiUrls.usersImageUrl}/${widget.chatModel.profileImage}",
                                imageName: widget.chatModel.fullName),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: kGreyDark,
                            width: 1,
                          ),
                        ),
                        child: Hero(
                          tag: "${ApiUrls.usersImageUrl}/${widget.chatModel.profileImage}",
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: "${ApiUrls.usersImageUrl}/${widget.chatModel.profileImage}",
                              width: 150,
                              height: 150,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                              ),
                              errorWidget: (context, url, error) =>
                                  Image.asset(ImagesPaths.placeholderImage),
                              fadeInDuration: const Duration(milliseconds: 500),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //

            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.chatModel.fullName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18.0, color: Color(0xff3A3D43)),
                      textAlign: TextAlign.center,
                    ),
                    SelectableText(
                      (widget.chatModel.user1 == widget.userLoggedIn.username)
                          ? "@${widget.chatModel.user2}"
                          : "@${widget.chatModel.user1}",
                      style: TextStyle(
                          color: Colors.grey.shade600, fontWeight: FontWeight.w400, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Actions",
                style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
              ),
              focusColor: kPrimaryColor,
            ),
            ListTile(
              title: Text(
                "Block ${widget.chatModel.fullName}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              leading: Icon(
                FontAwesomeIcons.ban,
                color: Colors.grey.shade600,
              ),
              focusColor: kPrimaryColor,
              onTap: () {},
            ),
            ListTile(
              title: Text(
                "Report ${widget.chatModel.fullName}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              leading: Icon(
                FontAwesomeIcons.thumbsDown,
                color: Colors.grey.shade600,
              ),
              focusColor: kPrimaryColor,
              onTap: () {},
            ),
            // Media grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: msgPhotoList.isNotEmpty,
                    child: ListTile(
                      title: Text(
                        "Media in this chat",
                        style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
                      ),
                      focusColor: kPrimaryColor,
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                    ),
                    itemCount: msgPhotoList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          _openImage(index: index);
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageFullScreen(
                                  imageUrlsList: const [],
                                  imageUrl:
                                  '${ApiUrls.chatAttachments}/${msgPhotoList[index].message}',
                                  imageName: widget.chatModel.fullName),
                            ),
                          );*/
                        },
                        child: CachedNetworkImage(
                          imageUrl: '${ApiUrls.chatAttachments}/${msgPhotoList[index].message}',
                          placeholder: (context, url) => Image.asset(ImagesPaths.placeholderAttach),
                          errorWidget: (context, url, error) =>
                              Image.asset(ImagesPaths.placeholderAttach),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getAllPhotosViaFirebase() async {
    //get firebase collection using the widget.chatModel.id
    //Since all the chatModel is based
    msgPhotoList = await ChatService.getAllPhotosViaFirebase(widget.chatModel.id,widget.userLoggedIn.username);

    if (mounted) {
      setState(() {});
    }
  }

  _openImage({int index = 0}) {
    List<String> imageUrlList = [];
    for (ChatMessageModel chat in msgPhotoList) {
      imageUrlList.add("${ApiUrls.chatAttachments}/${chat.message}");
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageFullScreen(
          imageUrlsList: imageUrlList,
          isCarousel: true,
          initialIndex: index,
          imageUrl: "",
          imageName: "${widget.chatModel.fullName}",
        ),
      ),
    );
  }
}
