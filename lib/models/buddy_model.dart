import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/request_model.dart';

class BuddyModel {
  String id = "";
  String? name;
  String? email;
  String? username;
  String? image;
  String? phone;
  String? latitude;
  String? longitude;
  String? birthday;
  String? gender;
  String? bio;
  String? selectedInterests;
  String? chatId;
  String? distance;

  RequestStatus requestStatus = RequestStatus.NotSent;

  BuddyModel.empty();

  BuddyModel({
    this.id = "",
    this.name,
    this.email,
    this.username,
    this.image,
    this.phone,
    this.longitude,
    this.latitude,
    this.birthday,
    this.gender,
    this.bio,
    this.selectedInterests,
    this.distance,
    this.chatId,
  });

  BuddyModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      email = "";
      username = json['username'];
      image = json['image'];
      phone = "";
      String location = json['location'];
      if (location.isNotEmpty) {
        List<String> locationSplit = location.split(',');
        latitude = locationSplit[0];
        longitude = locationSplit[1];
      }
      distance = json['distance']??"";
      birthday = json['birthday'];
      gender = json['gender'];
      bio = json['bio'];
      requestStatus = getStatus(json['is_accepted'].toString());
      selectedInterests = json['selected_interests'];

      chatId = json['chat_id']??"";
    } catch (e) {
      Log.log("BuddyModel" + e.toString());
    }
  }
  RequestStatus getStatus(String? isAccepted) {
    if (isAccepted == null) {
      return RequestStatus.NotSent;
    } else if (isAccepted == '-1') {
      return RequestStatus.Pending;
    } else if (isAccepted == '0') {
      return RequestStatus.Declined;
    } else if (isAccepted == '3') {
      return RequestStatus.Cancel;
    } else if (isAccepted == '1') {
      return RequestStatus.Accepted;
    }

    return RequestStatus.NotSent;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['username'] = username;
    data['image'] = image;
    data['phone'] = phone;
    data['location'] = "${latitude!},${longitude!}";
    data['birthday'] = birthday;
    data['gender'] = gender;
    data['bio'] = bio;
    data['selected_interests'] = selectedInterests;
    data['chat_id'] = chatId;
    data['distance'] = distance;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BuddyModel &&
        other.name == name &&
        other.image == image &&
        other.birthday == birthday &&
        other.gender == gender;
  }

  @override
  int get hashCode {
    return name.hashCode ^ image.hashCode ^ birthday.hashCode ^ gender.hashCode;
  }

  @override
  String toString() {
    return 'BuddyModel{id: $id, name: $name, email: $email, username: $username, requestStatus: ${requestStatus.name} }';
  }
}
