import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/group_model.dart';

import 'package:nearby_buddy_app/routes/api_service.dart';

import 'channel_data.dart';

// To connect streams, we have a ChannelBloc
class ChannelBloc {
  final StreamController<ChannelData> _channelController = StreamController<ChannelData>();
  Stream<ChannelData> get channelStream => _channelController.stream;

  // Fetch user's channels along with the latest message for each channel
  Future<void> getMyChannels(String username) async {
    try {
      final myChannelsList = await ApiService().getGroupChatList(username: username);
      //this contains all the group ids for the user
      if (myChannelsList.isNotEmpty) {
        // Create a new list to store the latest message for each channel
        List<String> lastMessageList = List.filled(myChannelsList.length, '');



        // Create a ChannelData object with updated data and add it to the stream
        final channelData = ChannelData(
            myChannelsList: myChannelsList,
            findChannelList: _channelData.findChannelList,
            lastMessageList: lastMessageList);
        _channelController.add(channelData);
      } else {
        // If there are no channels, add an empty ChannelData object to the stream
        _channelController
            .add(ChannelData(myChannelsList: [], findChannelList: [], lastMessageList: []));
      }
    } catch (e) {
      if (_channelController.isClosed) return;
      _channelController.addError(e);
    }
  }

  // Fetch user's channels along with the latest message for each channel
  Future<void> getRefreshChannelList( List<GroupModel> myChannelsList,String username) async {
    try {

      //this contains all the group ids for the user
      if (myChannelsList.isNotEmpty) {
        // Create a new list to store the latest message for each channel
        List<String> lastMessageList = List.filled(myChannelsList.length, '');

        // Fetch the latest message for each channel from Firebase
        for (int i = 0; i < myChannelsList.length; i++) {
          Log.log("Refresh Meoin${myChannelsList[i].id}");
          CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('group${myChannelsList[i].id}');

          QuerySnapshot querySnapshot =
          await collectionReference.orderBy('time_stamp', descending: true).limit(1).get();

          if (querySnapshot.docs.isNotEmpty) {
            var a = querySnapshot.docs[0];
            Log.log(a.toString());
            if (a['type'] == 0) {
              lastMessageList[i] = a['message'];
            } else if (a['type'] == 1) {
              lastMessageList[i] = '📷 Shared an Image';
            } else if (a['type'] == 2) {
              lastMessageList[i] = '📄 Shared a Document...';
            }
            myChannelsList[i].newTimeStamp = a['time_stamp'].toDate();
            List<dynamic> readBy = (a['read_by'] as List<dynamic>?) ?? [];
            myChannelsList[i].isRead = readBy.contains(username);
            myChannelsList[i].lastMsg=lastMessageList[i];


            int count=0;
            await collectionReference
                .where('sender', isNotEqualTo: username)
                .get()
                .then((querySnapshot) {
              for (var doc in querySnapshot.docs) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                List<dynamic> readBy = (data['read_by'] as List<dynamic>?) ?? [];
                if (!readBy.contains(username)) {
                  // Handle the documents that meet the criteria here
                 count++;
                }
              }
            });
            myChannelsList[i].count=count;
          }
        }
        myChannelsList.sort((a, b) => b.newTimeStamp.compareTo(a.newTimeStamp));

        // Create a ChannelData object with updated data and add it to the stream
        final channelData = ChannelData(
            myChannelsList: myChannelsList,
            findChannelList: _channelData.findChannelList,
            lastMessageList: lastMessageList);
        _channelController.add(channelData);
      } else {
        // If there are no channels, add an empty ChannelData object to the stream
        _channelController
            .add(ChannelData(myChannelsList: [], findChannelList: [], lastMessageList: []));
      }
    } catch (e) {
      if (_channelController.isClosed) return;
      _channelController.addError(e);
    }
  }
  // Fetch public channels available for discovery
  Future<void> getFindChannels(String username,String radius,String location,) async {
    final findChannelList = await ApiService().getPublicGroups(username: username,location:location ,radius:radius );
    if (findChannelList.isNotEmpty) {
      // Create a ChannelData object with updated data and add it to the stream
      final channelData = ChannelData(
          myChannelsList: _channelData.myChannelsList,
          findChannelList: findChannelList,
          lastMessageList: _channelData.lastMessageList);

      _channelController.add(channelData);
    } else {
      // If there are no discovery channels, add an empty ChannelData object to the stream
      _channelController
          .add(ChannelData(myChannelsList: [], findChannelList: [], lastMessageList: []));
    }
  }

  // Initial data containing empty lists
  final ChannelData _channelData =
      ChannelData(myChannelsList: [], findChannelList: [], lastMessageList: []);

  // Close the stream controller when the Bloc is disposed
  void dispose() {
    _channelController.close();
  }
}
