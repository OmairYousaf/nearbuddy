import '../../../../../models/group_model.dart';

class ChannelData {
  //Because we want the streamer to have some information we defined a data type for it
  //the streamer in bloc can use this list to store information and we can access it in our screen
  List<GroupModel> myChannelsList = [];
  List<GroupModel> findChannelList = [];

  List<String> lastMessageList = []; // new list to store latest message for each channel

  ChannelData(
      {required this.myChannelsList, required this.findChannelList, required this.lastMessageList});
}
