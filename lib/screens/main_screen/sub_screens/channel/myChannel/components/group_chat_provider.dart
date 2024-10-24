import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:nearby_buddy_app/models/group_member_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../../../../helper/utils.dart';
import '../../../../../../models/group_message_model.dart';
import '../../../../../../models/group_model.dart';
import '../../../../../../models/user_model.dart';
import '../../../chat/components/chat_provider.dart';
import '../channel_chat_screen.dart';

class GroupChatProvider {
  final UserModel loggedInUser;
  List<GroupMemberModel> members;
  GroupModel groupModel;

  bool isNewGroupChatlist;

  GroupChatProvider(
      {required this.groupModel,
      required this.isNewGroupChatlist,
      required this.members,
      required this.loggedInUser,
   });

  getStream() {
    seeMsg();
    return (isNewGroupChatlist)
        ? FirebaseFirestore.instance.collection("group${groupModel.id}").snapshots()
        : FirebaseFirestore.instance
            .collection("group${groupModel.id}")
            .orderBy('time_stamp', descending: false)
            .snapshots();
  }

  addListener() {}

  void pushFirebase({required String message, required MessageType type}) {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("group${groupModel.id}");
    collectionRef.doc().set({
      'message': message, //bonus
      'sender': loggedInUser.username,
      'time_stamp': FieldValue.serverTimestamp(), //bonus
      'type': type.index,
      'read_by': [loggedInUser.username], // Initialize 'ReadBy' array with the sender's username
      'deleted_by': "",
    });
  }
  Future<void> seeMsg() async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection("group${groupModel.id}");
    collectionRef
        .where('sender', isNotEqualTo: loggedInUser.username)
        .get()
        .then((querySnapshot) {
      try {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          List<dynamic> readBy = (data['read_by'] as List<dynamic>?) ?? [];
          if (!readBy.contains(loggedInUser.username)) { // Check if readBy doesn't already contain the username
            readBy.add(loggedInUser.username);
            doc.reference.update({'read_by': readBy});
          }
        }
      } catch (e) {
        Log.log(e);
      }
    });
  }

  sendPushNotification({required String message}) async {
    /*  await ApiService().pushNotification(message, loggedInUser.username, members);*/
  }

  Future<bool> createChatList(
      {required String message, required MessageType type}) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("group${groupModel.id}");
    collectionRef.doc().set({
      'message': message.trim(), //bonus
      'sender': loggedInUser.username,
      'time_stamp': FieldValue.serverTimestamp(), //bonus
      'type': type.index,
      'read_by': [loggedInUser.username], // Initialize 'ReadBy' array with the sender's username

      'deleted_by': "",
    });
    return true; //bonus
  }

  Future<void> pushNotification({
    required String message,
  }) async {
    //SEND URL SEND CHAT NOTIFICATION;
  }

  Future<void> pickFile(String extension) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [extension],
    );

    if (result != null) {
    }
  }

  Future<bool> uploadFile(
    File file,
  ) async {
    String encodedFile = "";
    String nameOfAttachment = ApiService().getUniqueName(file);
    encodedFile = FileConverter.getBase64FormateFile(file.path);
     ApiService().uploadImageToServer(file, nameOfAttachment,'groups');

    try {
      if (isNewGroupChatlist) {
      } else {
        pushFirebase(message: nameOfAttachment, type: MessageType.image);

      }
      return true; //bonus
    } on Exception {
      return false;
    }
  }

/*  playSound(bool isReceived) async {
    *//*  final player = AudioCache();
    player.play('sounds/message.wav');*//*
    try {
      FlutterRingtonePlayer.play(
        fromAsset: (isReceived)
            ? 'assets/sounds/receive_tone.mp3'
            : 'assets/sounds/send_tone.mp3',

        ios: IosSounds.glass,
        looping: false, // Android only - API >= 28
        volume: 0.1, // Android only - API >= 28
        asAlarm: false, // Android only - all APIs
      );
    } catch (e) {
      Log.log(e.toString());
    }
  }*/

  getMessages(dynamic snapshot) {
    final messages = snapshot.data!.docs.reversed;
    Log.log(messages.toString());
    List<ChannelMessageBubble> messageBubbles = [];
    for (var doc in messages) {
      GroupMemberModel groupMemberModel =
          findGroupMemberByUsername(doc['sender']);
      GroupMessageModel groupMessage = GroupMessageModel(
          message: doc['message'],
          sender: doc['sender'],
          groupMemberModel: groupMemberModel,
          type: doc['type'],
          time_stamp: doc['time_stamp'],
          deleted_by: doc['deleted_by']);
      Log.log('Here is the info \n ${groupMessage.toString()}');
      if (doc['deleted_by'].toString() != loggedInUser.username) {
        final messageBubble = ChannelMessageBubble(
            groupMessage: groupMessage,
            username: loggedInUser.username,
            collectionReference:
            FirebaseFirestore.instance.collection("group${groupModel.id}"));

        messageBubbles.add(messageBubble);
      }
    }

    // playSound(true);
    return messageBubbles;
  }

  GroupMemberModel findGroupMemberByUsername(senderUsername) {
    Log.log(members.toString());
    for (int i = 0; i < members.length; i++) {
      if (members[i].username == senderUsername) {
        if (kDebugMode) {
          print("Found matching member for senderUsername: $senderUsername");
        }
        if (kDebugMode) {
          print("Returning member: ${members[i]}");
        }
        return members[i];
      }
    }

    if (kDebugMode) {
      print("No matching member found for senderUsername: $senderUsername");
    }
    return GroupMemberModel(); // If the username is not found in the list
  }
}
