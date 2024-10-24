import '../helper/shared_preferences.dart';
import '../helper/utils.dart';
import '../models/buddy_model.dart';
import '../models/image_model.dart';
import '../models/interest_chip_model.dart';
import 'api_service.dart';

Future<BuddyModel> getUserProfile(String username, String loggedInUsername) async {
  List<BuddyModel> buddiesProfile =
      await ApiService().getUserByUsername(username: username, myUsername: loggedInUsername);

  return (buddiesProfile.isNotEmpty) ? buddiesProfile.first : BuddyModel();
}

Future<List<ImageModel>> getImages(String username) async {
  List<ImageModel> imageList = [];
  imageList = await ApiService().getImages(username: username);
  return imageList;
}

Future<List<InterestChipModel>> getInterests(String userSelectedInterests) async {
  List<InterestChipModel> fullInterestList = await SharedPrefs().loadInterestChips();
  Log.log(fullInterestList.length);
  List<InterestChipModel> userInterestList = [];
  try {
    List<String> idList = userSelectedInterests.split(",").map((id) => id).toList();

    fullInterestList = await ApiService().getInterests();

    for (String id in idList) {
      for (InterestChipModel interest in fullInterestList) {
        if (interest.catID == id) {
          userInterestList.add(interest);
          break; // Exit the inner loop once a match is found
        }
      }
    }
  } catch (E) {
    Log.log("Errror: $E");
  }
  return userInterestList;
}
