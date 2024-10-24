import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/models/group_message_model.dart';


import '../../../../../../constants/colors.dart';
import '../../../../../../models/chat_message_model.dart';

class FileMessageBubble extends StatefulWidget {
  const FileMessageBubble({super.key,
    this.chatMessage,
    this.groupMessage,
    required this.username,
    required this.onDelete,
    required this.context,
  });

  final ChatMessageModel? chatMessage;
  final GroupMessageModel? groupMessage;
  final String username;
  final BuildContext context;
  final Function(String message) onDelete;

  @override
  State<FileMessageBubble> createState() => _FileMessageBubbleState();
}

class _FileMessageBubbleState extends State<FileMessageBubble> {
  final double _percentage = 0.0;
  final _isDownloading = false;
  final _OpenFile = false;

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: (widget.chatMessage!.sender == widget.username)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onLongPress: () {

          },
          child: Material(
            borderRadius:  const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0)),
            color: (widget.chatMessage!.sender == widget.username)
                ? kPrimaryColor
                : kWhiteColor,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (widget.chatMessage!.message),
                        style: TextStyle(
                            color:
                                (widget.chatMessage!.sender == widget.username)
                                    ? kWhiteColor
                                    : kBlack,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {

                        },
                        child: Visibility(
                          visible: !_OpenFile,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: !_isDownloading,
                                child: Icon(
                                  Icons.download_rounded,
                                  color: (widget.chatMessage!.sender ==
                                          widget.username)
                                      ? kWhiteColor
                                      : kBlack,
                                ),
                              ),
                              Visibility(
                                visible: _isDownloading,
                                child: SizedBox(
                                  child: CircularProgressIndicator(
                                    valueColor: (widget.chatMessage!.sender ==
                                            widget.username)
                                        ?  const AlwaysStoppedAnimation<Color>(
                                            Colors.white)
                                        :  AlwaysStoppedAnimation<Color>(
                                            kPrimaryColor),
                                    value: _percentage,
                                    backgroundColor: const Color(0xffD6D6D6),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Download File",
                                style: TextStyle(
                                    color: (widget.chatMessage!.sender ==
                                            widget.username)
                                        ? kWhiteColor
                                        : kBlack,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {

                        },
                        child: Visibility(
                          visible: _OpenFile,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: !_isDownloading,
                                child: Icon(
                                  Icons.folder_open_sharp,
                                  color: (widget.chatMessage!.sender ==
                                          widget.username)
                                      ? kWhiteColor
                                      : kBlack,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Open File",
                                style: TextStyle(
                                    color: (widget.chatMessage!.sender ==
                                            widget.username)
                                        ? kWhiteColor
                                        : kBlack,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('h:mm a').format(
                        widget.chatMessage!.time_stamp == null
                            ? DateTime.now()
                            : widget.chatMessage!.time_stamp.toDate()),
                    style: TextStyle(
                      color: (widget.chatMessage!.sender == widget.username)
                          ? kWhiteColor
                          : kGrey,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


}
