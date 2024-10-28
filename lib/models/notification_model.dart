class NotificationModel {
  String? id;
  String? title;
  String? type;
  String? dataId;
  String? timeStamp;
  String? username;
  String? usernameNotifier;
  String? isRead;
  String? name;
  String? image;

  NotificationModel(
      {this.id,
      this.title,
      this.type,
      this.dataId,
      this.timeStamp,
      this.username,
      this.usernameNotifier,
      this.isRead,
      this.name,
      this.image});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    dataId = json['data_id'];
    timeStamp = json['time_stamp'];
    username = json['username'];
    usernameNotifier = json['username_notifier'];
    isRead = json['is_read'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    data['data_id'] = this.dataId;
    data['time_stamp'] = this.timeStamp;
    data['username'] = this.username;
    data['username_notifier'] = this.usernameNotifier;
    data['is_read'] = this.isRead;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}
