import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  String message = "";
  dynamic time_stamp;
  String reciever = "";
  String sender = "";
  bool isRead = false;
  String deleted_by = "";
  int type = 0;

  ChatMessageModel(
      {required this.message,
      required this.time_stamp,
      required this.reciever,
      required this.sender,
      required this.isRead,
      required this.deleted_by,
      required this.type});

  @override
  String toString() {
    return 'ChatMessage{message: $message, time_stamp: $time_stamp, reciever: $reciever, sender: $sender, isRead: $isRead, deleted_by: $deleted_by, type: $type}';
  }
}
class ChatService {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<List<ChatMessageModel>> getAllPhotosViaFirebase(String chatId,String loggedInUser) async {
    List<ChatMessageModel> photoList = [];

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection(chatId)
          .where('type', isEqualTo: 1) // Filter documents with type equal to 1 (image)

          .get();

      querySnapshot.docs.forEach((doc) {

        if(doc['deleted_by']!=loggedInUser){
          ChatMessageModel message = ChatMessageModel(
            message: doc['message'],
            time_stamp: doc['time_stamp'],
            reciever: doc['receiver'],
            sender: doc['sender'],
            isRead: doc['isRead'],
            deleted_by: doc['deleted_by'],
            type: doc['type'],
          );
          photoList.add(message);
        }
      });

      // Sort the photoList by time_stamp
      photoList.sort((a, b) => b.time_stamp.compareTo(a.time_stamp));
    } catch (e) {
      print("Error getting photos: $e");
    }

    return photoList;
  }
}