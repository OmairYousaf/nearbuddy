
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nearby_buddy_app/models/chat_message_model.dart';


import 'image_message_bubble.dart';
import 'simple_text_bubble.dart';
import '../../components/chat_provider.dart';

//Use to filter out different texts and easier approach
class MessageBubble extends StatelessWidget {
  ChatMessageModel chatMessage;
  CollectionReference collectionReference;
  Function(String,String) openOptionMenu;
  String username;

  MessageBubble(
      {super.key,
        required this.chatMessage,
        required this.openOptionMenu,
        required this.username,
        required this.collectionReference});

  @override
  Widget build(BuildContext context) {
    // iF OUR chatMessage has the
    return Padding(
      padding: (chatMessage.sender == username)
          ? const EdgeInsets.fromLTRB(50, 5, 5, 5)
          : const EdgeInsets.fromLTRB(5, 5, 50, 5),
      child: showTypeBasedBubble(chatMessage.type, context),
    );
  }

  Widget showTypeBasedBubble(int type, BuildContext context) {
    if (type == MessageType.image.index) {
      return ImageMessageBubble(
        chatMessage: chatMessage,
        username: username,
        onDelete: openOptionMenu,
      );
    }/* else if (type == MessageType.file.index) {
      return FileMessageBubble(
        chatMessage: chatMessage,
        username: username,
        context: context,
        onDelete: onLongPress,
      );
    }*/ else {
      return SimpleTextBubble(
        chatMessage: chatMessage,
        username: username,
        onDelete: openOptionMenu,
      );
    }
  }
/*
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
  }*/
}