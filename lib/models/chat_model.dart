class ChatModel {
  String id = "";
  String user1 = "";
  String user2 = "";
  String timeStamp = "";
  String deletedBy = "";
  String fullName = "";
  String _message = "";
  String profileImage = "";
  bool _isRead = true;
  int count = 0;
  DateTime _newTimeStamp=DateTime.now();
  UserStatus userStatus=UserStatus(isActive: false, onlineTime: '');


  dynamic get newTimeStamp => _newTimeStamp;

  set newTimeStamp(dynamic value) {
    _newTimeStamp = value;
  }

  String get message => _message;
  set message(String value) {
    _message = value;
  }

  bool get isRead => _isRead;

  set isRead(bool value) {
    _isRead = value;
  }
  ChatModel({
    this.id = "",
    this.user1 = "",
    this.user2 = "",
    this.count = 0,
    this.timeStamp = "",
    this.deletedBy = "",
    this.fullName = "",
    this.profileImage = "",
  });

  ChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user1 = json['user1'];
    user2 = json['user2'];
    timeStamp = json['time_stamp'];
    deletedBy = json['deleted_by'];
    fullName = json['name'];
    profileImage = json['image'];
    message = json['last_msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user1'] = user1;
    data['user2'] = user2;
    data['time_stamp'] = timeStamp;
    data['deleted_by'] = deletedBy;
    data['full_name'] = fullName;
    data['image'] = profileImage;
    data['last_msg'] = message;
    return data;
  }

  @override
  String toString() {
    return 'ChatList{id: $id, user1: $user1, user2: $user2, timeStamp: $timeStamp, _newTimeStamp: $_newTimeStamp, deletedBy: $deletedBy, fullName: $fullName, _message: $_message, profileImage: $profileImage, _isRead: $_isRead, count: $count}';
  }


  // Static method to sort list of ChatModel objects
  static void sortByTimeStamp(List<ChatModel> chatList) {
    chatList.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  }
  ChatModel copyWith({
    String? id,
    String? user1,
    String? user2,
    int? count,
    String? timeStamp,
    String? deletedBy,
    String? fullName,
    String? profileImage,
    bool? isRead,
    String? message,
  }) {
    return ChatModel(
      id: id ?? this.id,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
      count: count ?? this.count,
      timeStamp: timeStamp ?? this.timeStamp,
      deletedBy: deletedBy ?? this.deletedBy,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
    )
      ..isRead = isRead ?? this.isRead
      ..message = message ?? this.message;
  }
}
class UserStatus {
  final bool isActive;
  final String onlineTime;

  UserStatus({required this.isActive, required this.onlineTime});
}



