import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import '../../../../../helper/utils.dart';

import '../../../../../models/chat_message_model.dart';
import '../../../../../models/user_model.dart';
import '../../../../../models/chat_model.dart';
import '../chatScreen/components/chat_message_bubble.dart';

class ChatProvider {
  final UserModel loggedInUser;
  final String buddyUser;
  ChatModel chatList;
  String chatID;
  bool isNewChatlist;

  ChatProvider(
      {required this.chatList,
      required this.isNewChatlist,
      required this.buddyUser,
      required this.loggedInUser,
      required this.chatID});

  getStream() {
    seeMsg();
    return FirebaseFirestore.instance
        .collection(chatList.id)
        .orderBy('time_stamp', descending: false).snapshots();
  }

  addListener() {}
  Future<void> seeMsg() async {
    (isNewChatlist)
        ? FirebaseFirestore.instance.collection(chatID)
        : FirebaseFirestore.instance
            .collection(chatList.id)
            .where('receiver', isEqualTo: loggedInUser.username)
            .where('isRead', isEqualTo: false)
            .get()
            .then((querySnapshot) {
            for (var doc in querySnapshot.docs) {
              doc.reference.update({'isRead': true});
            }
          });
  }

  bool pushFirebase({required String message, required MessageType type}) {
try{
  CollectionReference collectionRef =
  FirebaseFirestore.instance.collection(chatList.id);
  collectionRef.doc().set({
    'message': message, //bonus
    'receiver': (chatList.user1 == loggedInUser.username)
        ? chatList.user2
        : chatList.user1,
    'sender': loggedInUser.username,
    'time_stamp': FieldValue.serverTimestamp(), //bonus
    'type': type.index,
    'isRead': false,
    'deleted_by': "",
  });
/*  Log.log("Pushed ${{
    'message': message, //bonus
    'receiver': (chatList.user1 == loggedInUser.username)
        ? chatList.user2
        : chatList.user1,
    'sender': loggedInUser.username,
    'time_stamp': FieldValue.serverTimestamp(), //bonus
    'type': type.index,
    'isRead': false,
    'deleted_by': "",
  }}");*/
  return true;
}catch(E){
  Log.log('error');
  return false;
}
  }

  sendPushNotification({required String message}) async {
    await ApiService()
        .saveChatToServer(message, loggedInUser.username, buddyUser,this.chatList.id);
  }

  Future<String> createChatList(
      {required String message, required MessageType type}) async {
    try {
      String chatID = await ApiService().createNewChatList(
          sender: loggedInUser.username, receiver: buddyUser);
      if (chatID.isNotEmpty) {
        CollectionReference collectionRef =
            FirebaseFirestore.instance.collection(chatID);
        collectionRef.doc().set({
          'message': message.trim(), //bonus
          'receiver': (chatList.user1 == loggedInUser.username)
              ? chatList.user2
              : chatList.user1,
          'sender': loggedInUser.username,
          'time_stamp': FieldValue.serverTimestamp(), //bonus
          'type': type.index,
          'isRead': false,
          'deleted_by': "",
        });
        return chatID; //bonus
      } else {
        return chatList.id;
      }
    } catch (e) {
      Log.log("SER$e");
      return chatList.id;
    }
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
      PlatformFile? file = result.files.first;
      String? filePath = file.path!;
    }
  }

  Future<bool> uploadFile(
    File file,
  ) async {
    String encodedFile = "";
    String nameOfAttachment = ApiService().getUniqueName(file);
   // encodedFile = FileConverter.getBase64FormateFile(file.path);
     ApiService().uploadImageToServer(file, nameOfAttachment,'chat');

    try {


        pushFirebase(message: nameOfAttachment, type: MessageType.image);

      return true; //bonus
    } on Exception {
      return false;
    }
  }


  getMessages(
      {dynamic snapshot, required Function(String, String) onOptionMenu}) {
    final messages = snapshot.data!.docs.reversed;
    List<ChatMessageModel> chatMessageList = [];
    List<MessageBubble> messageBubbles = [];
    for (var doc in messages) {
      ChatMessageModel chatMessage = ChatMessageModel(
          message: doc['message'],
          reciever: doc['receiver'],
          sender: doc['sender'],
          isRead: doc['isRead'],
          type: doc['type'],
          time_stamp: doc['time_stamp'],
          deleted_by: doc['deleted_by']);
      if (doc['deleted_by'].toString() != loggedInUser.username) {
        final messageBubble = MessageBubble(
          chatMessage: chatMessage,
          openOptionMenu: onOptionMenu,
          username: loggedInUser.username,
          collectionReference: (isNewChatlist)
              ? FirebaseFirestore.instance.collection(chatID)
              : FirebaseFirestore.instance.collection(chatList.id),
        );

        messageBubbles.add(messageBubble);
      }
    }
    // playSound(true);
    return messageBubbles;
  }
}

enum MessageType { text, image, file }
