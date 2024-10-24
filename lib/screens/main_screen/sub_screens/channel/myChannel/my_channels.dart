import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/group_member_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../../../components/custom_dialogs.dart';
import '../../../../../models/group_model.dart';
import '../../../../../responsive.dart';
import 'channel_chat_screen.dart';
import 'components/group_list_item.dart';
import '../components/channel_bloc.dart';
import '../components/channel_data.dart';

class MyChannelsScreen extends StatefulWidget {
  UserModel loggedInUser;
  Function(GroupModel) onChannelItemClick;
  MyChannelsScreen({super.key, required this.loggedInUser, required this.onChannelItemClick
      /*  required this.onChangeToolbar,*/
      });
  @override
  _MyChannelsScreenState createState() => _MyChannelsScreenState();
}

class _MyChannelsScreenState extends State<MyChannelsScreen> {
  late ChannelBloc _channelBloc;
  late Timer _everySecond;
  bool _isDisposed = false;
  List<GroupModel> myChannelsList = [];
  bool isLandMode = false;
  @override
  void initState() {
    super.initState();
    _channelBloc = ChannelBloc();
    _channelBloc.getMyChannels(widget.loggedInUser.username);
    _everySecond = Timer.periodic(const Duration(seconds: 5), (timer) {
      updateMyChannelsList();
    });
  }

  @override
  void dispose() {
    _channelBloc.dispose();
    _isDisposed = true;
    _everySecond.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isLandMode = (Responsive.isWeb() && !Responsive.isMobile() && !Responsive.isMobileWeb());
    return RefreshIndicator(
      onRefresh: _refreshRequestList,
      child: StreamBuilder<ChannelData>(
        stream: _channelBloc.channelStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            myChannelsList = snapshot.data!.myChannelsList;
            if (myChannelsList.isNotEmpty) {
              return ListView.builder(
                itemCount: myChannelsList.length,
                itemBuilder: (context, index) {
                  return GroupListItem(
                    groupModel: myChannelsList[index],
                    loggedInUser: widget.loggedInUser,
                    isGroupNewChatlist: false,
                    index: index,
                    onLongPres: () async {
                      if (widget.loggedInUser.username == myChannelsList[index].groupAdmin) {
                        await CustomDialogs.showAppDialog(
                          context: context,
                          message:
                              'Are you sure you want to delete ${myChannelsList[index].groupName}?',
                          callbackMethod2: () => _deleteChannel(
                              myChannelsList[index].groupAdmin ?? "", myChannelsList[index].id),
                          buttonLabel2: 'Yes',
                          callbackMethod1: () async {
                            Navigator.of(context).pop();
                          },
                          buttonLabel1: 'No',
                        );
                      }
                    },
                    onTap: () async {
                      try {
                        // When returning from ChannelChatScreen, update the stream data
                        //When we remove we receive a groupMember to remove
                        GroupMemberModel? groupMemberModel = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChannelChatScreen(
                              groupChatList: myChannelsList[index],
                              userLoggedIn: widget.loggedInUser,
                              isGroupNewChatlist: false,
                              updateChatDetails:(GroupModel groupModel){
                                myChannelsList[index]=groupModel;
                                if(mounted){
                                  setState(() {

                                  });
                                }
                              },
                            ),
                          ),
                        );
                        if (groupMemberModel != null) {
                          myChannelsList[index].groupMemberList.removeWhere(
                              (element) => element.username == widget.loggedInUser.username);
                          myChannelsList
                              .removeWhere((element) => element.id == myChannelsList[index].id);
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      } catch (e) {
                        await _channelBloc.getMyChannels(widget.loggedInUser.username);
                        Log.log(e);
                      }
                      await updateMyChannelsList();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: const Text(
                    "Swipe left and discover new Events. When you create or Join an event you will recieve the latest messages here",
                    style: TextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            );
          }
        },
      ),
    );
  }

  // Function to update myChannelsList and stream
  Future<void> updateMyChannelsList() async {
    // Fetch the latest last messages and update myChannelsList accordingly
    await _channelBloc.getRefreshChannelList(myChannelsList, widget.loggedInUser.username);
  }

  Future<void> _deleteChannel(String groupAdmin, String groupId) async {
    CustomDialogs.showLoadingAnimation(context);
    bool result = await ApiService().deleteChannel(username: groupAdmin, channelID: groupId);
    if (result) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      CustomSnackBar.showSuccessSnackBar(context, "Event has been deleted");
      setState(() {
        myChannelsList.removeWhere((channel) => channel.id == groupId);
      });
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      CustomSnackBar.showErrorSnackBar(context, "Event couldnt be deleted");
    }
  }

  Future<void> _refreshRequestList() async {
    // Fetch the latest channel data
    await _channelBloc.getMyChannels(widget.loggedInUser.username);

    // After fetching the latest data, update the state to trigger a UI refresh
    setState(() {});
  }
}
