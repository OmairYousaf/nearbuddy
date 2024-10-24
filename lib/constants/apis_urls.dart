const String baseUrl = "https://nearby.enscyd.com/";
const String apiUrl = "${baseUrl}api/";

class ApiUrls {
  static const String usersImageUrl = "${apiUrl}getImages/users";
  static const String groupsImageUrl = "${apiUrl}getImages/groups";
  static const String chatAttachments = "${apiUrl}getImages/chat";
  static const String urlLogin = "${apiUrl}login.php";
  static const String urlRegister = "${apiUrl}register.php";
  static const String urlUpdateProfile = "${apiUrl}updateProfile.php";
  static const String urlShowEvents = "${apiUrl}showEvents.php";
  static const String urlGetInterests = "${apiUrl}getIntrests.php";
  static const String urlUploadImage = "${apiUrl}uploadImage.php";
  static const String urlVerifyOtp = "${apiUrl}verifyOTP.php";
  static const String urlSendOtp = "${apiUrl}sendOTP.php";
  static const String urlUpdateImageList = "${apiUrl}updateImagesList.php";
  static const String urlGetAddImages = "${apiUrl}getAdditionalImages.php";
  static const String urlCheckEmail = "${apiUrl}checkEmail.php";
  static const String urlSearchNearUsers = "${apiUrl}searchNearByUsers.php";
  static const String urlGetChatId = "${apiUrl}isChatListCreated.php";
  static const String urlCreateChatList = "${apiUrl}createChatList.php";
  static const String urlShowFriendList = "${apiUrl}showFriendList.php";
  static const String urlBlockUser = "${apiUrl}blockUser.php";
  static const String urlUploadChatAttachment =
      "${apiUrl}uploadChatAttachment.php";
  static const String urlSendChatNotification =
      "${apiUrl}sendChatNotification.php";
  static const String urlGetChatList = "${apiUrl}getChatList.php";
  static const String urlAddMessage = "${apiUrl}addMessage.php";
  static const String urlGetUserByUsername = "${apiUrl}getUserbyUsername.php";
  static const String urlGetCreateAGroup = "${apiUrl}createAGroup.php";
  static const String urlUpdateGroup = "${apiUrl}updateGroup.php";
  static const String urlGetGroupMembers = "${apiUrl}getGroupMembers.php";
  static const String urlGetGroupChats = "${apiUrl}getGroupChats.php";
  static const String urlAddGroupMember = "${apiUrl}addGroupMember.php";
  static const String urlDeleteGroupMember = "${apiUrl}deleteGroupMember.php";
  static const String urlSetRequestStatus = "${apiUrl}setRequestStatus.php";
  static const String urlgetPublicGroups = "${apiUrl}getPublicGroups.php";
  static const String urlgetRecievedRequests =
      "${apiUrl}getRecievedRequests.php";
  static const String urlgetSentRequests = "${apiUrl}getSentRequests.php";
  static const String urlsendRequest = "${apiUrl}sendRequest.php";
  static const String urlShowScheduling = "${apiUrl}showScheduling.php";
  static const String urlupdateScheduling = "${apiUrl}updateScheduling.php";
  static const String urlschedulingSwitch = "${apiUrl}schedulingSwitch.php";
  static const String urladdScheduling = "${apiUrl}addScheduling.php";
  static const String urlupdateToken = "${apiUrl}updateToken.php";
  static const String urlchangeOnlineStatus = "${apiUrl}changeOnlineStatus.php";
  static const String urlgetUserStatus = "${apiUrl}getUserStatus.php";
  static const String urlgetUserProfile= "${apiUrl}getUserProfile.php";

  static const String urldeleteChannel = "${apiUrl}deleteChannel.php";
  static const String urlleaveChannel = "${apiUrl}leaveChannel.php";
  static const String urldeleteChat = "${apiUrl}deleteChatList.php";
  static const String urlFeedback = "${apiUrl}feedback.php";

  static const String urlTermsCondition =
      "https://nearby.enscyd.com/termsandconditions.html";
  static const String urlPrivacyPolicy =
      "https://nearby.enscyd.com/privacyPolicy.html";
}
