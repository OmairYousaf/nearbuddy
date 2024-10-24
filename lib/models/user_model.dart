import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  String id = "";
  String name = "";
  String email = "";
  String username = "";
  String image = "";
  String phone = "";
  String location = "";
  String birthday = "";
  String bio = "";
  String gender = "";
  String selectedInterests = "";
  bool emailVerified = false;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
    required this.image,
    required this.phone,
    required this.location,
    required this.birthday,
    required this.gender,
    required this.selectedInterests,
    required this.emailVerified,

  });
  UserModel.copy(UserModel other) {
    id = other.id;
    name = other.name;
    email = other.email;
    username = other.username;
    image = other.image;
    phone = other.phone;
    location = other.location;
    birthday = other.birthday;
    bio = other.bio;
    gender = other.gender;
    selectedInterests = other.selectedInterests;
    emailVerified = other.emailVerified;

  }
  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    username = json['username'];
    image = json['image'];
    phone = json['phone'];
    location = json['location'];
    birthday = json['birthday'];
    gender = json['gender'];
    selectedInterests = json['selected_interests'];


    emailVerified = json['email_verified'] == 0 ? false : true;

    bio = json['bio'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['username'] = username;
    data['image'] = image;
    data['phone'] = phone;
    data['location'] = location;
    data['birthday'] = birthday;
    data['gender'] = gender;
    data['selected_interests'] = selectedInterests;

    data['email_verified'] = emailVerified ? 1 : 0;

    data['bio'] = bio;

    return data;
  }

  UserModel.empty();

  factory UserModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserModel.fromJson(json);
  }
  @override
  String toString() {
    return '{"id": "$id", "name": "$name", "email": "$email", "username": "$username", "image": "$image", "phone": "$phone", "location": "$location", "birthday": "$birthday", "bio": "$bio", "gender": "$gender", "selectedInterests": "$selectedInterests", "emailVerified": $emailVerified}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        username,
        image,
        phone,
        location,
        birthday,
        bio,
        gender,
        selectedInterests,
        emailVerified,

      ];
}
