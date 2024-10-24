enum RequestStatus {
  Pending, //-1
  Accepted, //1
  Declined, //0
  NotSent,//2
  Cancel,//3
}

class RequestModel {
  String? requestId;
  bool isAccepted = false;
  RequestStatus status = RequestStatus.Pending;
  String? msg;
  String? name;
  String? username;
  String? image;
  String? gender;
  String? bio;
  String? selectedInterests;

  RequestModel(
      {this.requestId,
      this.isAccepted = false,
      this.msg,
      this.name,
      this.username,
      this.image,
      this.gender,
      this.bio,
      this.selectedInterests});

  RequestModel.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id'];
    isAccepted = json['is_accepted'] == '1' ? true : false;
    msg = json['msg'];
    name = json['name'];
    username = json['username'];
    image = json['image'];
    gender = json['gender'];
    bio = json['bio'];
    status = json['is_accepted'] == '-1'
        ? RequestStatus.Pending
        : json['is_accepted'] == '0'
            ? RequestStatus.Declined
            : RequestStatus.Accepted;
    selectedInterests = json['selected_interests'];
    print(status);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_id'] = requestId;
    data['is_accepted'] = isAccepted;
    data['msg'] = msg;
    data['name'] = name;
    data['username'] = username;
    data['image'] = image;
    data['gender'] = gender;
    data['bio'] = bio;
    data['selected_interests'] = selectedInterests;
    return data;
  }
}
