import 'package:cloud_firestore/cloud_firestore.dart';

import 'group_member_model.dart';

class GroupMessageModel {
  String message = "";
  dynamic time_stamp;
  String sender = "";
  bool isRead = false;
  String deleted_by = "";
  int type = 0;
  int count=0;
  GroupMemberModel groupMemberModel;

  GroupMessageModel(
      {required this.message,
      required this.time_stamp,
      required this.sender,
      required this.groupMemberModel,
      this.isRead = false,
        this.count=0,
      required this.deleted_by,
      required this.type});

  @override
  String toString() {
    return 'GroupMessageModel{message: $message, time_stamp: $time_stamp, sender: $sender, isRead: $isRead, deleted_by: $deleted_by, type: $type, groupMemberModel: $groupMemberModel}';
  }
}
class GroupService {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<List<GroupMessageModel>> getAllPhotosViaFirebase(String groupId,String loggedInUser) async {
    List<GroupMessageModel> photoList = [];

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection("group$groupId")
          .where('type', isEqualTo: 1) // Filter documents with type equal to 1 (image)
          .get();

      querySnapshot.docs.forEach((doc) {
        if(doc['deleted_by'].toString() != loggedInUser){

          GroupMessageModel groupMessage = GroupMessageModel(
              message: doc['message'],
              sender: doc['sender'],
              groupMemberModel: GroupMemberModel(username: doc['sender']),
              type: doc['type'],
              time_stamp: doc['time_stamp'],
              deleted_by: doc['deleted_by']);

          photoList.add(groupMessage);
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