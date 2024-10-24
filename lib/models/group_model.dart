import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_buddy_app/helper/utils.dart';

import 'group_member_model.dart';

class GroupModel {
  String id = '-1';
  String? timeStamp;
  String? deletedBy;
  String? lastMsg;
  String? type;
  bool isJoined=false;
  String? groupName;
  String? groupIcon;
  bool isPrivate=false;
  bool _isRead = true;
  int count = 0;
  String? location="";
  List<GroupMemberModel> groupMemberList = [];
  dynamic get newTimeStamp => _newTimeStamp;
  DateTime _newTimeStamp=DateTime.now();

  String? groupAdmin;
  String? groupDescription;
  String? createdAt;
  double latitude=0;
  double longitude=0;


  GroupModel(
      {this.id = '-1',
      this.timeStamp,
      this.deletedBy,
      this.lastMsg,
      this.type,
      this.count = 0,
      this.groupName,
      this.groupIcon,
      this.groupAdmin,
        this.isPrivate=false,
      this.groupDescription,
        this.location,
        this.longitude=0,
        this.latitude=0,
      this.createdAt});
  set newTimeStamp(dynamic value) {
    _newTimeStamp = value;
  }

  bool get isRead => _isRead;

  set isRead(bool value) {
    _isRead = value;
  }
  GroupModel.fromJson(Map<String, dynamic> json) {
    Log.log(json['group_icon']);
    id = json['id'] ?? "";

    groupName = json['group_name'];
    groupIcon = json['group_icon'];
    groupAdmin = json['group_admin'];
    groupDescription = json['group_description'];
    createdAt = json['created_at'];
    isPrivate=json['is_private']=='0'?false:true;
    location=json['location']??"";
    LatLng latLng=_parseLocation(location!);
    latitude=latLng.latitude;
    longitude=latLng.longitude;
    timeStamp = json['time_stamp'] ?? "";
    deletedBy = json['deleted_by'] ?? "";
    lastMsg = json['last_msg'] ?? "";
    type = json['type'] ?? "";
    isJoined=false;


  }
  LatLng _parseLocation(String location){
    List<String> coordinates = location!.split(',');
    if (coordinates.length == 2) {
      latitude = double.parse(coordinates[0]);
      longitude = double.parse(coordinates[1]);
      LatLng latLng=LatLng(latitude, longitude);
      return latLng;

    } else {
      print('Invalid location format');
      return LatLng(0, 0);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['time_stamp'] = timeStamp;
    data['deleted_by'] = deletedBy;
    data['last_msg'] = lastMsg;
    data['type'] = type;

    data['group_name'] = groupName;
    data['group_icon'] = groupIcon;
    data['group_admin'] = groupAdmin;
    data['group_description'] = groupDescription;
    data['created_at'] = createdAt;
    return data;
  }

  @override
  String toString() {
    return 'GroupModel{id: $id, timeStamp: $timeStamp, deletedBy: $deletedBy, lastMsg: $lastMsg, type: $type, isJoined: $isJoined, groupName: $groupName, groupIcon: $groupIcon, isPrivate: $isPrivate, _isRead: $_isRead, count: $count, location: $location, groupMemberList: $groupMemberList, _newTimeStamp: $_newTimeStamp, groupAdmin: $groupAdmin, groupDescription: $groupDescription, createdAt: $createdAt, latitude: $latitude, longitude: $longitude}';
  }
}
