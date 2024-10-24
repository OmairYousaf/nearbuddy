import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nearby_buddy_app/helper/shared_preferences.dart';
import 'package:nearby_buddy_app/models/group_member_model.dart';
import 'package:nearby_buddy_app/models/image_model.dart';
import 'package:nearby_buddy_app/models/interest_chip_model.dart';
import 'package:nearby_buddy_app/models/chat_model.dart';

import '../constants/apis_urls.dart';
import '../helper/utils.dart';
import '../models/buddy_model.dart';
import '../models/group_model.dart';
import '../models/request_model.dart';
import '../models/schedule_model.dart';
import '../models/user_exists_model.dart';
import 'https_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum LoginType { manual, google, facebook, apple }

enum OS {
  web,
  android,
  iOS,
}

class ApiService {
  final _usedUsernames = <String>{};
  String generateUniqueUsername(String name) {
    // Split the name into words and remove any non-alphanumeric characters
    final words =
        name.split(RegExp(r'\W+')).map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')).toList();

    // Shuffle the words to create different username patterns
    words.shuffle();

    // Generate a username by combining the shuffled words with a random number until a username is found that has not been used before
    var username = '';
    while (username.isEmpty || _usedUsernames.contains(username)) {
      final baseUsername = words.join('').toLowerCase();
      final randomNumber = Random().nextInt(1000).toString().padLeft(3, '0');
      username = '$baseUsername$randomNumber';
    }

    // Add the new username to the set of used usernames
    _usedUsernames.add(username);

    return username;
  }

  Future<List<InterestChipModel>> getInterests() async {
    List<InterestChipModel> interestChipList = [];

    try {
      Http helper = Http();
      final response = await helper.get(
        ApiUrls.urlGetInterests,
      );

      if (response["error"]) {
        return interestChipList;
      } else {
        try {
          List<dynamic> data = List.from(response['records']);
          for (var i = 0; i < data.length; i++) {
            try {
              InterestChipModel chipData = InterestChipModel(
                label: data[i]['name'],
                catID: data[i]['id'],
                isSelected: false,
              );
              interestChipList.add(chipData);
            } on Exception {
              Log.log("Error");
            }
          }
          await SharedPrefs().saveInterestChips(interestChipList);
        } catch (_) {
          Log.log(_.toString());
          return interestChipList;
        }
        return interestChipList;
      }
    } catch (_) {
      Log.log(_.toString());
      return interestChipList;
    }
  }

  Future<int> loginUser({
    required String email,
    required String password,
    required LoginType loginType,
  }) async {
    Map<String, dynamic> data = <String, dynamic>{};

    data['email'] = email;
    data['password'] = password;
    data['password_type'] = loginType == LoginType.manual
        ? 'manual'
        : loginType == LoginType.apple
            ? 'apple'
            : loginType == LoginType.google
                ? 'google'
                : 'facebook';

    Log.log("SENDING A REQUEST FOR\n$data");
    Http http = Http();
    final response = await http.post(ApiUrls.urlLogin, data);
    // 100 means logged in 200 means error 99  means register
    // 300 means password
    try {
      if (response["error"]) {
        Log.log("${response["error_msg"]}");
        if (response["error_code"] == 99) {
          return 99;
        } else {
          return 300;
        }
      } else {
        bool saveUser = await SharedPrefs().saveToSharedPreferences(
            SharedPrefs().PREFS_LOGIN_USER_DATA, jsonEncode(response['user']));
        if (saveUser) {
          Log.log("saving user ");
          return 100;
        } else {
          Log.log("saving token error!");
          return 200;
        }
      }
    } on Exception {
      Log.log("Error");
      return 200;
    }
  }

  Future<bool> registerUser({
    required String email,
    required String password,
    required LoginType passwordType,
    required OS osType,
    required String name,
  }) async {
    Map<String, dynamic> data = <String, dynamic>{};

    data['email'] = email;
    data['name'] = name;
    data['password'] = password;
    data['os'] = OS.android == osType ? 'android' : 'none';
    data['username'] = generateUniqueUsername(name);
    data['password_type'] = passwordType == LoginType.manual
        ? 'manual'
        : passwordType == LoginType.apple
            ? 'apple'
            : passwordType == LoginType.google
                ? 'google'
                : 'facebook';

    Log.log("SENDING A REQUEST FOR\n$data");

    Http http = Http();
    final response = await http.post(ApiUrls.urlRegister, data);

    try {
      if (response["error"]) {
        Log.log("${response["error_msg"]}");
        if (response["error_msg"].toString().contains("User already existed")) {
          return true;
        } else {
          return false;
        }
      } else {
        bool saveUser = await SharedPrefs().saveToSharedPreferences(
            SharedPrefs().PREFS_LOGIN_USER_DATA, jsonEncode(response['user']));
        if (saveUser) {
          Log.log("saving TEMP user ");
          return true;
        } else {
          Log.log("saving TEMP error!");
          return false;
        }
      }
    } on Exception {
      Log.log("Error");
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String profilePath,
    required String birthday,
    required String location,
    bool isUpdate = false,
    required String bio,
    required String gender,
    required String username,
    required String selectedInterests,
    required List<dynamic> photos,
    required dynamic profileImageFile,
  }) async {
    Map<String, dynamic> data = {
      'image': profileImageFile != null ? getUniqueName(profileImageFile) : profilePath,
      'name': name,
      'phone': '5555555',
      'location': location,
      'birthday': birthday,
      'gender': gender,
      'selected_interests': selectedInterests,
      'username': username,
      'bio': bio,
    };

    Log.log("SENDING A REQUEST FOR\n$data");

    Http http = Http();

    final response = await http.post(ApiUrls.urlUpdateProfile, data);

    bool result = false;
    try {
      // Check if there's an error in the response
      if (response["error"]) {
        // If there's an error: Which indicates that the basic info was not changed in case a user tries to update
        result = false; // Set result to false indicating failure
        Log.log("${response["error_msg"]}"); // Log the error message

        // Handle image upload based on platform (web or mobile)
        if (kIsWeb) {
          // If platform is web:
          List<String> tList = await _uploadMultipleImagesToServer(photos); // Upload multiple images
          if (tList.isNotEmpty) {
            updateDBImages(tList, username); // Update database with uploaded images
            result = true; // Set result to true indicating success
          }
        } else {
          // If platform is not web (i.e., mobile):
          List<File?> toUpload = [];
          List<String> imageList = [];

          // Separate local images from network images
          for (ImageModel? photo in photos.whereType<ImageModel>()) {
            if (!(photo!.isNetworkImage)) {
              toUpload.add(photo.localImageFile); // Add local image to upload list
            } else {
              imageList.add(photo.image); // Add network image directly to imageList
            }
          }

          // Upload local images to server
          if (toUpload.isNotEmpty) {
            List<String> tList = await _uploadMultipleImagesToServer(toUpload);
            imageList.addAll(tList); // Add uploaded image names to imageList
          }

          // Update database with uploaded images
          if (imageList.isNotEmpty) {
            updateDBImages(imageList, username);
            result = true; // Set result to true indicating success
          }
        }
      } else {
        // If no error in response:
        if (profileImageFile != null) {
          await _uploadSingleImageToServer(profileImageFile, data['image']); // Upload profile image
        }

        // Handle image upload based on platform (web or mobile)
        if (kIsWeb) {
          // If platform is web:
          List<String> tList = await _uploadMultipleImagesToServer(photos); // Upload multiple images
          if (tList.isNotEmpty) {
            updateDBImages(tList, username); // Update database with uploaded images
            result = true; // Set result to true indicating success
          }
        } else {
          // If platform is not web (i.e., mobile):
          List<File?> toUpload = [];
          List<String> imageList = [];

          // Separate local images from network images
          for (ImageModel? photo in photos.whereType<ImageModel>()) {
            if (!(photo!.isNetworkImage)) {
              toUpload.add(photo.localImageFile); // Add local image to upload list
            } else {
              imageList.add(photo.image); // Add network image directly to imageList
            }
          }

          // Upload local images to server
          if (toUpload.isNotEmpty) {
            List<String> tList = await _uploadMultipleImagesToServer(toUpload);
            imageList.addAll(tList); // Add uploaded image names to imageList
          }

          // Update database with uploaded images
          if (imageList.isNotEmpty) {
            updateDBImages(imageList, username);
            result = true; // Set result to true indicating success
          }
        }

        // Save updated user data to SharedPreferences
        await _saveDataToSharedPreferences(response['user'], SharedPrefs().PREFS_LOGIN_USER_DATA);
        result = true; // Set result to true indicating success
      }

      return result; // Return result indicating success or failure
    } on Exception {
      Log.log("Error");
      return false;
    }
  }

  Future<bool> _saveDataToSharedPreferences(Map<String, dynamic> mapStringData, String key) async {
    return await SharedPrefs().saveToSharedPreferences(key, jsonEncode(mapStringData));
  }

  Future<void> _uploadSingleImageToServer(profileImageFile, String profileImageName) async {
    bool result = await uploadImageToServer(profileImageFile, profileImageName, "users");
    if (result) {
      Log.log("Profile image uploaded successfully.");
    } else {
      Log.log("Profile image upload failed.");
    }
  }

  Future<List<String>> _uploadMultipleImagesToServer(List<dynamic> photos) async {
    List<String> imageList = [];
    for (dynamic photo in photos) {
      if (photo != null) {
        String uniqueName = getUniqueName(photo);
        bool result = await uploadImageToServer(photo, uniqueName, "users");
        if (result) {
          imageList.add(uniqueName);
          Log.log("Image uploaded successfully: $uniqueName");
        } else {
          Log.log("Image upload failed: $uniqueName");
        }
      }
    }
    return imageList;
  }



  Future<bool> uploadImageToServer(image, String uniqueImageName, String dirName) async {
    String encodedFile = "";

    Map<String, dynamic> data = <String, dynamic>{};
    if (kIsWeb) {
      final Uint8List imageByte = await image.readAsBytes(); //

      encodedFile =
          base64Encode(imageByte); // Encoding the list of byte i.e imageBytes to base64 String
    } else {
      encodedFile = FileConverter.getBase64FormateFile(image.path);
    }

    data['imagesName'] = uniqueImageName;
    data['dirName'] = dirName;
    data['imagesData'] = encodedFile;

    try {
      final response = await Http().post(ApiUrls.urlUploadImage, data);

      return true;
    } on Exception {
      Log.log("Error");
      return false;
    }
  }

  Future<void> updateDBImages(List<String> imageList, String username) async {
    Http http = Http();
    String images = "";
    for (String image in imageList) {
      images += "$image,";
    }
//    Log.log(images);
// Remove the last comma
    images = images.substring(0, images.length - 1);
    Map<String, dynamic> data = <String, dynamic>{};

    data['username'] = username;
    data['images'] = images;

    Log.log(data.toString());
    try {
      final response = await http.post(ApiUrls.urlUpdateImageList, data);
      if (response["error"]) {
        Log.log("$response");
      } else {
        Log.log("$response");
      }
    } on Exception {
      Log.log("Error");
    }
  }

  Future<List<ImageModel>> getImages({required username}) async {
    List<ImageModel> imagesList = [];
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};

    data['username'] = username;

    try {
      final response = await http.post(ApiUrls.urlGetAddImages, data);
      if (!response["error"]) {
        // Extract the records list from the response
        List records = response['records'];

        // Convert the records into ImageModel objects
        imagesList = records.map((record) => ImageModel.fromJson(record)).toList();
      }
      return imagesList;
    } on Exception {
      Log.log("Error");
      return imagesList;
    }
  }
  Future<bool> verifyOTP({required String otp, required String email}) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['otp'] = otp;

    Log.log(data.toString());
    try {
      final response = await http.post(ApiUrls.urlVerifyOtp, data);
      if (response["error"]) {
        Log.log("${response["error_msg"]}");
        return false;
      } else {
        Log.log("${response["error_msg"]}");
        return true;
      }
    } on Exception {
      Log.log("Error");
      return false;
    }
  }

  Future<bool> sendOTP(String email) async {
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};

    data['email'] = email;
    data['type'] = "code";

    Log.log(data.toString());
    try {
      final response = await http.post(ApiUrls.urlSendOtp, data);
      if (response["error"]) {
        Log.log("${response["error_msg"]}");
        return false;
      } else {
        Log.log("${response["error_msg"]}");
        return true;
      }
    } on Exception {
      Log.log("Error");
      return false;
    }
  }
  Future<UserExistenceResult> checkIfUserExists({
    required String email,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;

    Log.log(data);

    try {
      final response = await http.post(ApiUrls.urlCheckEmail, data);
      Log.log(response);

      if (!response["error"]) {
        return UserExistenceResult(LoginType.manual, false); // User does not exist
      } else {
        LoginType loginMethod = LoginType.manual;

        if (response["login_method"] == 'google') {
          loginMethod = LoginType.google;
        } else if (response["login_method"] == 'facebook') {
          loginMethod = LoginType.facebook;
        } else if (response["login_method"] == 'apple') {
          loginMethod = LoginType.apple;
        }
        return UserExistenceResult(loginMethod, true); // User already exists
      }
    } catch (e) {
      Log.log(e);
      return UserExistenceResult(LoginType.manual, false); // Error occurred, treat as not exist
    }
  }

  String getUniqueName(image) {
    String fileName = "";
    String baseName = "";
    if (kIsWeb) {
      fileName = image!.name;
      baseName = fileName.split('.').first.trim().replaceAll(RegExp(r'\s+'), '_');
    } else {
      fileName = image.path.split('/').last;
      baseName = fileName.split('.').first;
    }

    String extension = fileName.split('.').last;
    String uniqueName = '${baseName}_${DateTime.now().microsecondsSinceEpoch}.$extension';
    return uniqueName;
  }

  Future<List<BuddyModel>> searchBuddies({
    required username,
    required searchString,
    required radius,
    required lat,
    required gender,
    required long,
    required category_id,
  }) async {
    List<BuddyModel> buddyList = [];
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};

    data['username'] = username;
    data['search_string'] = searchString;
    data['radius'] = radius;
    data['lat'] = lat;
    data['long'] = long;
    data['gender'] = gender;
    data['category_id'] = category_id;
    Log.log(data);
    try {
      final response = await http.post(ApiUrls.urlSearchNearUsers, data);
      Log.log(response);
      if (!response["error"]) {
        List records = response['records'];

        // Convert the records into ImageModel objects
        buddyList = records.map((record) => BuddyModel.fromJson(record)).toList();
        Log.log(buddyList.toString());
      } else {
        Log.log("Oh ho the search buddy list seems to empty or failed");
      }
    } catch (e) {
      Log.log(e.toString());
    }
    return buddyList;
  }

  Future<String> getChatID({required String loggedInUser, required String buddyUser}) async {
    String chatID = "";
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['user1'] = loggedInUser;
    data['user2'] = buddyUser;
    try {
      final response = await http.post(ApiUrls.urlGetChatId, data);
      Log.log(response.toString());
      if (!response["error"]) {
        return chatID = response['error_msg'];
      } else {
        return chatID;
      }
    } catch (e) {
      Log.log(e.toString());
      return chatID;
    }
  }

  Future<String> createNewChatList({
    required sender,
    required receiver,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['sender'] = sender;
    data['receiver'] = receiver;
    try {
      final response = await http.post(ApiUrls.urlCreateChatList, data);
      if (!response['error']) {
        return response['record']['last_id'].toString();
      } else {
        return "";
      }
    } catch (e) {
      Log.log(e.toString());
      return "";
    }
  }

  Future<bool> uploadChatAttachment(String image, String uniqueImageName) async {
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};

    data['attachment'] = uniqueImageName;
    data['file'] = image;
    data['type'] = 'image';

    Log.log(data.toString());
    try {
      await http.post(ApiUrls.urlUploadChatAttachment, data);
      return true;
    } on Exception {
      Log.log("Error");
      return false;
    }
  }

  Future<void> saveChatToServer(
      String message, String senderUsername, String receiverUsername,String chatID) async {
    Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['sender'] = senderUsername;
    data['receiver'] = receiverUsername;
    data['chat_id'] = chatID;
    try {
      final response = await Http().post(ApiUrls.urlAddMessage, data);
      Log.log('urlAddMessage');

    } on Exception catch (e) {
      Log.log(e.toString());
    }
  }

  Future<List<ChatModel>> getChatList({required String username}) async {
    List<ChatModel> chatLists = [];
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;

    try {
      final response = await http.post(ApiUrls.urlGetChatList, data);

      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {
          ChatModel chatList = ChatModel.fromJson(record[i]);
          if (chatList.deletedBy != username) {
            chatLists.add(chatList);
          }
        }
      } else {
        Log.log("Oh ho the search chat list seems to empty or failed");
      }

      // Sort the chatList based on timeStamp


      Log.log("The chatlist has almost records of ${chatLists.length}");
    } on Exception catch (e) {
      Log.log(e.toString());
    }
    return chatLists;
  }

  Future<List<ChatModel>> getFirebaseLastMsg(List<ChatModel> chatList, String username) async {
    List<ChatModel> chatLists = chatList;
    for (ChatModel chat in chatLists) {
      CollectionReference collectionReference = FirebaseFirestore.instance.collection(chat.id);
      QuerySnapshot querySnapshot =
          await collectionReference.orderBy('time_stamp', descending: true).limit(1).get();
      Log.log(chatList.toString());
      // Get data from docs and convert map to List
      if (querySnapshot.docs.isNotEmpty) {
        var document = querySnapshot.docs[0];
        if (document['type'] == 0) {
          chat.message = document['message'];
        } else if (document['type'] == 1) {
          chat.message = '📷 Shared an Image';
        } else if (document['type'] == 2) {
          chat.message = '📄 Shared a Document';
        } else if (document['type'] == 3) {
          chat.message = 'Shared a Post';
        }

        if (document['receiver'].toString() == username) {
          chat.isRead = document['isRead'];
        }
        chat.newTimeStamp = document['time_stamp'];
      }
      QuerySnapshot querySnapshot2 = await collectionReference
          .where('isRead', isEqualTo: false)
          .where('receiver', isEqualTo: username)
          .get();
      chat.count = querySnapshot2.docs.length;
    }
    return chatList;
  }

  Future<List<BuddyModel>> getUserByUsername({
    required String username,
    required String myUsername,
  }) async {
    List<BuddyModel> buddyList = [];
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['my_username'] = myUsername ?? "";

    try {
      final response = await http.post(ApiUrls.urlGetUserByUsername, data);

      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {
          BuddyModel buddyModel = BuddyModel.fromJson(record[i]);
          buddyList.add(buddyModel);
        }
        Log.log(response);
      } else {
        Log.log("Oh ho the search chat list seems to empty or failed");
      }
    } on Exception catch (e) {
      Log.log(e.toString());
    }
    return buddyList;
  }
  Future<BuddyModel> getUserProfile({
    required String username,
    required String myUsername,
  }) async {
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['my_username'] = myUsername ?? "";
    BuddyModel buddyModel=BuddyModel.empty();
    try {
      final response = await http.post(ApiUrls.urlgetUserProfile, data);

      if (!response["error"]) {
        // Assuming that the response contains only one user object
        // Convert the record into a BuddyModel object
       buddyModel = BuddyModel.fromJson(response['user']);
        Log.log(response);
        return buddyModel;
      } else {
        Log.log("Oh ho the search  seems to empty or failed");
        return buddyModel;
      }
    } on Exception catch (e) {
      Log.log(e.toString());
      return buddyModel;
    }
  }

  Future<GroupModel?> createGroupModel({
    required String groupAdmin,
    File? groupIcon,
    required String groupName,
    required String groupDescription,
    required List<BuddyModel> groupMembers,
    required String location,
    required String isPrivate,
  }) async {
    GroupModel? groupModel;
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    if (groupIcon != null) {
      String groupIconName = getUniqueName(groupIcon);
      data['group_icon'] = groupIconName;
    } else {
      data['group_icon'] = '';
    }

    data['group_admin'] = groupAdmin;

    data['group_name'] = groupName;
    data['group_description'] = groupDescription;
    data['is_private'] = isPrivate;
    data['location'] = location;

    data['group_members'] = groupMembers.map((buddy) => buddy.username).join(",");

    Log.log(data);
    try {
      final response = await http.post(ApiUrls.urlGetCreateAGroup, data);
      Log.log(response);
      if (!response["error"]) {
        groupModel = GroupModel.fromJson(response['record']);
        groupModel.groupMemberList = await ApiService().getGroupMembers(groupId: groupModel.id);
      } else {
        Log.log("No record found");
      }
    } on Exception catch (e) {
      Log.log(e.toString());
    }
    return groupModel;
  }

  Future<bool> updateGroup({
    required String groupId,
    required String groupAdmin,
    required String groupIcon,
    required String groupName,
    required String groupDescription,
    required String groupMembers,
    required String isPrivate,
    required String location,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};

    data['group_icon'] = groupIcon;

    data['group_admin'] = groupAdmin;
    data['group_id'] = groupId;

    data['group_name'] = groupName;
    data['group_description'] = groupDescription;
    data['location'] = location;
    data['group_members'] = groupMembers;
    data['is_private'] = isPrivate;

    Log.log(data);
    try {
      final response = await http.post(ApiUrls.urlUpdateGroup, data);
      Log.log(response);
      if (!response["error"]) {
        return true;
      } else {
        Log.log("Cannot update Group");
      }
    } on Exception catch (e) {
      Log.log(e.toString());
    }

    return false;
  }

  Future<List<GroupModel>> getGroupChatList({required String username}) async {
    List<GroupModel> groupChatList = [];
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;

    try {
      final response = await http.post(ApiUrls.urlGetGroupChats, data);

      Log.log(response);
      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {
          GroupModel groupModel = GroupModel.fromJson(record[i]);

          CollectionReference collectionReference =
              FirebaseFirestore.instance.collection("group${groupModel.id}");
          QuerySnapshot querySnapshot =
              await collectionReference.orderBy('time_stamp', descending: true).limit(1).get();

          // Get data from docs and convert map to List
          if (querySnapshot.docs.isNotEmpty) {
            var document = querySnapshot.docs[0];
            if (document['type'] == 0) {
              groupModel.lastMsg = document['message'];
            } else if (document['type'] == 1) {
              groupModel.lastMsg = '📷 Shared an Image';
            } else if (document['type'] == 2) {
              groupModel.lastMsg = '📄 Shared a Document';
            } else if (document['type'] == 3) {
              groupModel.lastMsg = 'Shared a Post';
            }

            groupModel.newTimeStamp = document['time_stamp'].toDate();
            // Check if the 'ReadBy' array contains the username and set 'isRead' accordingly
            List<dynamic> readBy = (document['read_by'] as List<dynamic>?) ?? [];
            groupModel.isRead = readBy.contains(username);

            await collectionReference
                .where('sender', isNotEqualTo: username)
                .get()
                .then((querySnapshot) {
              for (var doc in querySnapshot.docs) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                List<dynamic> readBy = (data['read_by'] as List<dynamic>?) ?? [];
                if (!readBy.contains(username)) {
                  // Handle the documents that meet the criteria here
                  groupModel.count++;
                }
              }
            });
          }

          groupModel.groupMemberList = await getGroupMembers(groupId: groupModel.id);
          groupChatList.add(groupModel);
          groupChatList.sort((a, b) => b.newTimeStamp.compareTo(a.newTimeStamp));
        }
      } else {
        Log.log("Oh ho thegroup  seems to empty or failed");
      }
    } catch (e) {
      Log.log(e.toString());
    }
    return groupChatList;
  }

  Future<List<GroupMemberModel>> getGroupMembers({required String groupId}) async {
    List<GroupMemberModel> groupMemberList = [];
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['group_id'] = groupId;

    try {
      final response = await http.post(ApiUrls.urlGetGroupMembers, data);

      if (!response["error"]) {
        // Convert the records into ImageModel objects
        // .............
        // .......................

        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {
          groupMemberList.add(GroupMemberModel.fromJson(record[i]));
        }
      } else {
        Log.log("Oh ho the search chat list seems to empty or failed");
      }
    } catch (e) {
      Log.log(e.toString());
    }
    return groupMemberList;
  }

  Future<bool> addGroupMember({
    required groupID,
    required groupMember,
  }) async {
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['group_id'] = groupID;
    data['group_members'] = groupMember;
    Log.log(data);
    try {
      final response = await http.post(ApiUrls.urlAddGroupMember, data);

      Log.log(response);
      if (!response["error"]) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Log.log(e.toString());
      return false;
    }
  }

  Future<List<GroupModel>> getPublicGroups({required String username,required String location,required radius}) async {
    List<GroupModel> groupList = [];
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['radius'] = radius;
    data['location'] = location;

    try {
      final response = await http.post(ApiUrls.urlgetPublicGroups, data);

      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {
          GroupModel groupModel = GroupModel.fromJson(record[i]);
          groupModel.groupMemberList = await getGroupMembers(groupId: groupModel.id);
          groupModel.isJoined =
              groupModel.groupMemberList.any((member) => member.username == username && member.isMember);

          groupList.add(groupModel);
        }
      } else {
        Log.log("Oh ho thegroup  seems to empty or failed");
      }
    } on Exception catch (e) {
      Log.log(e.toString());
    }
    return groupList;
  }

  Future<List<RequestModel>> getRecievedRequests({required String username}) async {
    List<RequestModel> requestList = [];
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;

    try {
      final response = await http.post(ApiUrls.urlgetRecievedRequests, data);

      Log.log(response);
      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {
          RequestModel requestModel = RequestModel.fromJson(record[i]);

          requestList.add(requestModel);
        }
      } else {
        Log.log("Oh ho thegroup  seems to empty or failed");
      }
    } on Exception catch (e) {
      Log.log(e.toString());
    }
    return requestList;
  }

  Future<List<RequestModel>> getSentRequests({required String username}) async {
    List<RequestModel> requestList = [];
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;

    try {
      final response = await http.post(ApiUrls.urlgetSentRequests, data);

      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {
          RequestModel requestModel = RequestModel.fromJson(record[i]);

          requestList.add(requestModel);
          Log.log(requestModel);
        }
      } else {
        Log.log("Oh ho thegroup  seems to empty or failed");
      }
    } on Exception catch (e) {
      Log.log(e.toString());
    }
    return requestList;
  }

  Future<bool> sendRequest({
    required String sender,
    required String receiver,
    required String msg,
  }) async {
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['msg'] = msg;

    try {
      final response = await http.post(ApiUrls.urlsendRequest, data);

      Log.log(response);
      if (!response["error"]) {
        return true;
      } else {
        Log.log("Oh ho failed to sendRequeest");
      }
    } catch (e) {
      Log.log(e.toString());
      return false;
    }
    return false;
  }

  Future<String> setRequestStatus({
    required groupID,
    required status,
  }) async {
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = groupID;
    data['status'] = status;
    Log.log(data);
    try {
      final response = await http.post(ApiUrls.urlSetRequestStatus, data);

      Log.log(response);
      if (!response["error"]) {
        return (response["chat_id"]).toString();
      } else {
        return '-1';
      }
    } catch (e) {
      Log.log(e.toString());
      return '-1';
    }
  }

  Future<List<ScheduleModel>> showSchedule({required String username}) async {
    List<ScheduleModel> scheduleList = [];
    Http http = Http();

    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;

    try {
      final response = await http.post(ApiUrls.urlShowScheduling, data);

      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {
          ScheduleModel scheduleModel = ScheduleModel.fromJson(record[i]);
          scheduleList.add(scheduleModel);
        }
        Log.log(response);
      } else {
        Log.log("Oh ho");
      }
    } catch (e) {
      Log.log(e.toString());
    }
    return scheduleList;
  }

  Future<void> updateScheduling({
    required String username,
    required String interestID,
    required String days,
    required String time,
    required String isActive,
    required String scheduleId,
    required bool isAll,
    required String usernames_list,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['interest_id'] = interestID;
    data['days'] = days;
    data['time'] = time;
    data['switch'] = isActive;
    data['id'] = scheduleId;
    data['scheduled_with'] = isAll ? 'all' : 'specific';
    data['usernames_list'] = usernames_list;
    Log.log(data.toString());
    try {
      final response = await http.post(ApiUrls.urlupdateScheduling, data);
      if (response["error"]) {
        Log.log("$response");
      } else {
        Log.log("$response");
      }
    } catch (e) {
      Log.log("Error");
    }
  }

  Future<void> schedulingSwitch({
    required String isActive,
    required String scheduleId,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['switch'] = isActive;
    data['id'] = scheduleId;

    Log.log(data.toString());
    try {
      final response = await http.post(ApiUrls.urlschedulingSwitch, data);
      if (response["error"]) {
        Log.log("$response");
      } else {
        Log.log("$response");
      }
    } catch (e) {
      Log.log("Error");
    }
  }

  Future<bool> addScheduling({
    required String username,
    required String interestID,
    required String days,
    required String time,
    required String isActive,
    required bool isAll,
    required String usernames_list,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['interest_id'] = interestID;
    data['days'] = days;
    data['time'] = time;
    data['switch'] = isActive;
    data['scheduled_with'] = isAll ? 'all' : 'specific';
    data['usernames_list'] = usernames_list;

    Log.log(data.toString());
    try {
      final response = await http.post(ApiUrls.urladdScheduling, data);
      Log.log("$response");
      if (!response["error"]) {
        Log.log("$response");
        return true;
      } else {
        Log.log("$response");
        return false;
      }
    } catch (e) {
      Log.log("Error");
      return false;
    }
  }

  Future<void> updateToken({
    required String username,
    required String token,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['token'] = token;

    Log.log(data.toString());
    try {
      final response = await http.post(ApiUrls.urlupdateToken, data);
      if (response["error"]) {
        Log.log("$response");
      } else {
        Log.log("$response");
      }
    } catch (e) {
      Log.log("Error");
    }
  }

  Future<void> updateOnlineStatus({
    required String username,
    required int status,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['status'] = status.toString();

    try {
      final response = await http.post(ApiUrls.urlchangeOnlineStatus, data);
      if (response["error"]) {
        Log.log("The response for updating online status :$response");
      } else {
        Log.log("The response for updating online status :$response");
      }
    } catch (e) {
      Log.log("Error");
    }
  }

  Future<UserStatus> getUserStatus({
    required String username,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;

    try {
      final response = await http.post(ApiUrls.urlgetUserStatus, data);
      if (response["error"]) {
        return UserStatus(isActive: false, onlineTime: '');
      } else {
        return UserStatus(
          isActive: response["status"] == '1'?true:false,
          onlineTime: response["online_time"],
        );
      }
    } catch (e) {
      Log.log("Error");
      return UserStatus(isActive: false, onlineTime: '');
    }
  }
  Future<bool> deleteChatList({
    required String username,
    required String chatID,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['id'] = chatID;
    try {
      final response = await http.post(ApiUrls.urldeleteChat, data);
      if (response['error']) {
        return false;
      } else {
        return true;
      }
    } catch (E) {
      Log.log(E.toString());
      return false;
    }
  }

  Future<bool> deleteChannel({
    required String username,
    required String channelID,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['channel_id'] = channelID;
    try {
      final response = await http.post(ApiUrls.urldeleteChannel, data);
      if (response['error']) {
        return false;
      } else {
        return true;
      }
    } catch (E) {
      Log.log(E.toString());
      return false;
    }
  }

  Future<bool> deleteGroupMember({
    required String groupId,
    required String groupMembers,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['group_id'] = groupId;
    data['group_members'] = groupMembers;
    try {
      final response = await http.post(ApiUrls.urlDeleteGroupMember, data);
      if (response['error']) {
        return false;
      } else {
        return true;
      }
    } catch (E) {
      Log.log(E.toString());
      return false;
    }
  }

  Future<bool> leaveChannel({
    required String username,
    required String channelID,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['channel_id'] = channelID;
    try {
      final response = await http.post(ApiUrls.urlleaveChannel, data);
      if (response['error']) {
        return false;
      } else {
        return true;
      }
    } catch (E) {
      Log.log(E.toString());
      return false;
    }
  }

  Future<bool> sendFeedback({
    required String email,
    required String name,
    required String message,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    data['message'] = message;
    try {
      final response = await http.post(ApiUrls.urlFeedback, data);
      if (response['error']) {
        return false;
      } else {
        return true;
      }
    } catch (E) {
      Log.log(E.toString());
      return false;
    }
  }

  Future<List<GroupModel>> showEvents({
    required String radius,
    required String location,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['radius']=radius;
    data['location']=location;
    List<GroupModel> eventList=[];
    try {
      final response = await http.post(ApiUrls.urlShowEvents, data);
      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {

          GroupModel eventModel = GroupModel.fromJson(record[i]);
          Log.log("record"+eventModel.toString());
          eventList.add(eventModel);
        }

        return eventList;
      } else {
        Log.log('No Events found for $radius, at Location $location');
        return eventList;
      }
    } catch (E) {
      Log.log(E.toString());
      return eventList;
    }
  }
  Future<List<BuddyModel>> showFriendList({
    required String username,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username']=username;
    List<BuddyModel> eventList=[];
    try {
      final response = await http.post(ApiUrls.urlShowFriendList, data);
      if (!response["error"]) {
        // Convert the records into ImageModel objects
        List<dynamic> record = List.from(response['records']);
        for (var i = 0; i < record.length; i++) {

          BuddyModel buddyModel = BuddyModel.fromJson(record[i]);
          Log.log("record$buddyModel");
          eventList.add(buddyModel);
        }

        return eventList;
      } else {
        Log.log('No Friends Found');
        return eventList;
      }
    } catch (E) {
      Log.log(E.toString());
      return eventList;
    }
  }

  Future<bool> blockUser({
    required String username,
    required String otherUsername,
  }) async {
    Http http = Http();
    Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['other_username'] = otherUsername;
    try {
      final response = await http.post(ApiUrls.urlBlockUser, data);
      if (response['error']) {
        return false;
      } else {
        return true;
      }
    } catch (E) {
      Log.log(E.toString());
      return false;
    }
  }
}
