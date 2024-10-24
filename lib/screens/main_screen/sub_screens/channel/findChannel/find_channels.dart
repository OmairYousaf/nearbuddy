import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/models/group_member_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import '../../../../../components/custom_dialogs.dart';
import '../../../../../helper/utils.dart';
import '../../../../../models/group_model.dart';
import '../../../../../responsive.dart';
import 'find_channel_list_item.dart';
import '../myChannel/channel_chat_screen.dart';
import '../components/channel_bloc.dart';
import '../components/channel_data.dart';

class FindChannelsScreen extends StatefulWidget {
  final UserModel loggedInUser;
  Function(GroupModel) onChannelItemClick;
  String radius;
  String location;
  FindChannelsScreen(
      {Key? key,
      required this.loggedInUser,
      required this.onChannelItemClick,
      required this.location,
      required this.radius})
      : super(key: key);
  @override
  _FindChannelsScreenState createState() => _FindChannelsScreenState();
}

class _FindChannelsScreenState extends State<FindChannelsScreen> {
  late ChannelBloc _channelBloc;
  bool isLandMode = false;
  @override
  void initState() {
    super.initState();
    _channelBloc = ChannelBloc();
    _channelBloc.getFindChannels(widget.loggedInUser.username, widget.radius, widget.location);
  }

  @override
  void dispose() {
    _channelBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isLandMode = (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());
    return StreamBuilder<ChannelData>(
      stream: _channelBloc.channelStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final myChannelsList = snapshot.data!.findChannelList;

          if (myChannelsList.isNotEmpty) {
            if (isLandMode) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // You can adjust the number of columns as needed
                  crossAxisSpacing: 10.0, // Adjust the spacing between columns
                  mainAxisSpacing: 8.0, // Adjust the spacing between rows
                ),
                itemCount: myChannelsList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int ind) {
                  return _buildFindChannelItem(ind, myChannelsList);
                },
              );
            } else {
              return ListView.builder(
                cacheExtent: 900,
                itemCount: myChannelsList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int ind) {
                  return _buildFindChannelItem(ind, myChannelsList);
                },
              );
            }
          } else {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: const Text(
                  "Oops Look like there are no channels currently available to join. Please come back in a few minutes, and we will provide you with some channels to join",
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        }
      },
    );
  }

  _buildFindChannelItem(int ind, List<GroupModel> myChannelsList) {
    return FindChannelListItem(
      index: ind,
      loggedInUser: widget.loggedInUser,
      groupModel: myChannelsList[ind],
      onTap: () async {
        //when the user click view or join
        Log.log(myChannelsList[ind].isJoined);
        if (myChannelsList[ind].isJoined) {
          GroupMemberModel? groupMemberModel = await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChannelChatScreen(
                      groupChatList: myChannelsList[ind],
                      userLoggedIn: widget.loggedInUser,
                      isGroupNewChatlist: false,
                  updateChatDetails: (GroupModel groupModel) {},
                    )),
          );
          if (groupMemberModel != null) {
            CustomDialogs.showLoadingAnimation(context);
            myChannelsList[ind]
                .groupMemberList
                .removeWhere((element) => element.username == groupMemberModel.username);
            myChannelsList[ind].isJoined = false;
            Navigator.of(context).pop();
            setState(() {
              // Navigator.of(context).pop();
            });
          }
          CustomDialogs.showLoadingAnimation(context);
          await _channelBloc.getFindChannels(
              widget.loggedInUser.username, widget.radius, widget.location);
          Navigator.of(context).pop();
        } else {
          var groupID = myChannelsList[ind].id;

          bool result = await _joinGroup(groupID, widget.loggedInUser.username);
          if (result) {
            //add the member to the group
            myChannelsList[ind].groupMemberList.add(GroupMemberModel(
                id: '',
                username: widget.loggedInUser.username,
                groupId: groupID,
                name: widget.loggedInUser.username,
                image: widget.loggedInUser.image,
                isMember: true));
          }

          myChannelsList[ind].isJoined = result;
          Navigator.of(context).pop();
          setState(() {
            Log.log(myChannelsList[ind]);
          });
        }
      },
    );
  }

  Future<bool> _joinGroup(
    groupID,
    groupMember,
  ) async {
    CustomDialogs.showLoadingAnimation(context);
    bool result = await ApiService().addGroupMember(
      groupID: groupID,
      groupMember: groupMember,
    );

    return result;
  }
}
