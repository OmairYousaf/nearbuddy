import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:nearby_buddy_app/helper/device_location.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/group_model.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/channel/channel_screen.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/chat/chat_main_screen.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/chat/my_requests_screen.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/connect/connect_screen.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/home/home_screen_mobile.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/myProfile/profile_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../components/custom_dialogs.dart';
import '../../constants/lottie_paths.dart';
import '../../helper/shared_preferences.dart';
import '../../main.dart';
import '../../models/chat_model.dart';
import '../../models/interest_chip_model.dart';
import '../../models/user_model.dart';
import '../../routes/api_service.dart';
import 'components/bottom_nav_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  UserModel userModel;
  MainScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  List<InterestChipModel> userInterestList = [];
  List<InterestChipModel> fullInterestList = [];
  bool appReady = false;
  double latitude = 0.0;
  double longitude = 0.0;
  double distance = 10;
  var bearing;
  int totalUnreadChats = 0;
  int totalUnreadEvents = 0;
  PermissionStatus _status = PermissionStatus.denied;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  ScreenType screenType = ScreenType.none;

  Future<void> getNotificationPermision() async {
    Log.log('GetNotification Permission');
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission();
    }
    if (Platform.isIOS) {
      // Request permission for iOS
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      // Request permission for Android
      await _firebaseMessaging.requestPermission(
        sound: true,
        alert: true,
        badge: true,
      );
    }
  }

  Future<void> setupFlutterNotifications() async {
    Log.log('SETUP FLUTTER NOTIFICATIONS');
    try {
      if (isFlutterLocalNotificationsInitialized) {
        return;
      }
      channel = const AndroidNotificationChannel(
        'my_channel_01', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      isFlutterLocalNotificationsInitialized = true;
    } catch (e) {
      Log.log('SETUP NOTIFICATION ${e}');
    }
  }

  Future<void> initialize() async {
    //first we get all the permissions
    Log.log("Initializing app");
    try {
      await getNotificationPermision();
      if (!kIsWeb) {
        Log.log('SETUP FLUTTER NOTIFICATIONS IN INTIT');
        await setupFlutterNotifications();
      }

      // Initialize local notifications plugin
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('notification_icon');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      // Now, define the background notification handler as a static method

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );
    } catch (e) {
      Log.log('[ERROR OCCURRED IN FCM SERVICES ] : $e');
    }
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    //WHEN CLICKED
    Log.log('OnDidReceiveNotificationResponse $screenType');
    showScreen(screenType);
  }

  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse notificationResponse) {
    // ignore: avoid_print
    Log.log('notification(${notificationResponse.id}) action tapped onDidReceiveBgNotification: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      Log.log(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  Future<bool> checkNotificationPermission() async {
    Log.log('checkNotificationPermission');
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Permission is granted
      return true;
    } else {
      // Permission is not granted
      return false;
    }
  }

  Future<String?> registerDeviceToken() async {
    Log.log('registerDeviceToken');
    try {
      String? token = await _firebaseMessaging.getToken();
      Log.log('FCM Token: $token');
      return token;
    } catch (e) {
      Log.log('Failed to get device token: $e');
      return null;
    }
  }

  ScreenType parseNotification(
    RemoteMessage message,
  ) {
    Log.log('parseNotification');
    RemoteNotification? notification = message.notification;
    final data = message.data;

    if (notification != null) {
      final title = notification.title;
      final body = notification.body;
      final channel = notification.android?.channelId ?? "";
      Log.log(
          'Parse Notification - Title: $title, Body: $body channelID:$channel');
      Log.log('Parse Notification - Notification data: ${notification}');
    }

    final customData = data;
    Log.log('Custom Data: $customData');
    // Extract the 'screen' parameter from custom data
    final screen = customData['screen'];
    if (screen != null) {
      // Check the value of 'screen' and navigate to the desired screen
      if (screen == 'splash') {
        // Navigate to the splash screen
        // You may need to replace 'SplashScreen' with the actual screen or route name
        screenType = ScreenType.splash;
      } else if (screen == 'chat') {
        // Navigate to the chat screen
        // You may need to replace 'ChatScreen' with the actual screen or route name
        screenType = ScreenType.chat;
      } else if (screen == 'request') {
        screenType = ScreenType.request;
      } else if (screen == 'member_added') {
        screenType = ScreenType.memberAdded;
      } else if (screen == 'add_schedule') {
        screenType = ScreenType.addSchedule;
      } else if (screen == 'create_event') {
        screenType = ScreenType.createEvent;
      }

      // Add more conditions for other screen values as needed
    }
    return ScreenType.none;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void showFlutterNotification(RemoteMessage message) {
    Log.log('showFlutterNotification');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'my_channel_01', // id
            'High Importance Notifications', // title
            channelDescription:
                'This channel is used for important notifications.', // d

            icon: 'notification_icon',
          ),
        ),
      );
    }
  }

  // Future<void> showNotification(
  //   Map<String, dynamic> notification,
  // ) async {
  //   Log.log("Show Notification Called");
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'my_channel_01',
  //     'com.google.firebase.messaging.default_notification_channel_id',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
  //
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //
  //   await _flutterLocalNotificationsPlugin.show(
  //     Random(500).nextInt(1000),
  //     notification['title'],
  //     notification['body'],
  //     platformChannelSpecifics,
  //     payload: '/notificationScreen',
  //   );
  // }

  @override
  void initState() {
    Log.log("Initializing app");
    // Register your State class as a binding observer
    WidgetsBinding.instance.addObserver(this);
    getInterests();
    _setOnlineStatus();
    _getRequests();
    _getUnreadChats();
    _getEvents();
    _initializeFCM();
    _setupNotificationListeners();


    super.initState();
  }


  // Override the didChangeAppLifecycleState method and
  // listen to the app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        _onDetached();
        break;
      case AppLifecycleState.resumed:
        _onResumed();
        break;

      case AppLifecycleState.inactive:
        _onInactive();
        break;

      case AppLifecycleState.paused:
        _onPaused();
        break;
      case AppLifecycleState.hidden:
        _onHidden();
        break;
    }
  }

  //The application is no longer running. This typically happens when the application is terminated by the operating system or by the user.
  void _onDetached() => _setOnlineStatus(status: 0);
  //The application is in the foreground and receiving user input.
  void _onResumed() => _setOnlineStatus(status: 1);

  /*
  The application is in an inactive state and
   cannot respond to user input. This usually occurs when the application
   is transitioning between different states,
   such as when a phone call is received or the user switches to another app.
   */
  void _onInactive() => _setOnlineStatus(status: 0);
/* The application's UI is not visible.
This can happen when the application is running in the background or when another app is displayed on top of it.*/
  void _onHidden() => _setOnlineStatus(status: 0);
/*The application is not visible and cannot interact with the user. This can occur
 when the user switches to another app or when the application is running in the background.*/
  void _onPaused() => _setOnlineStatus(status: 0);

  Future<void> _initializeFCM() async {
    Log.log('_initializeFCM');

    try {
      await initialize();
      //permission and the functions that should be called
      //when notification is clicked is registered
      String? token = await registerDeviceToken();
      //device ka token save it in the database
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      Log.log('Error while getting token $e');
    }
    //we check all notificationPermission
    await _checkNotificationPermission();
  }

  _checkNotificationPermission() async {
    bool isNotificationsOn = await checkNotificationPermission();
    if (!isNotificationsOn) {
      _showNotificationPermissionDialog();
    }
  }

  Future<void> _showNotificationPermissionDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Permission Required'),
          content: const Text(
              'Please enable notifications for this app in your device settings to receive updates.'),
          actions: <Widget>[
            TextButton(
              child: const Text('I Understand'),
              onPressed: () {
                Navigator.of(context).pop();
                _openSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSettings() async {
    await AppSettings.openAppSettings(callback: () {
      Log.log("sample callback function called");
    });
    // Check permission again after returning from settings
    await _checkNotificationPermission();
  }

  void _setupNotificationListeners() {
    Log.log('__setupNotificationListeners');
    //listener
    FirebaseMessaging.onMessage.listen(_handleNotifications);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);
  }

  void _handleNotifications(RemoteMessage message) async {
    // Handle the received notification message when in app
    Log.log('_handleNotifcation inside');
    parseNotification(message);
    showFlutterNotification(message);
  }

  void _handleNotificationOpened(RemoteMessage message) {
    // Handle the notification opened by the user
    Log.log('_handleNotifcaOpened');
    parseNotification(
      message,
    );
    showScreen(screenType);
  }

  void showScreen(ScreenType screenType) {
    Log.log('showScreen');
    if (screenType == ScreenType.splash) {
      _selectedIndex = 1;
      setState(() {});
    } else if (screenType == ScreenType.request) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (c) => MyRequestScreen(loggedInUser: widget.userModel)));
    } else if (screenType == ScreenType.chat) {
      _selectedIndex = 2;
      setState(() {});
    } else if (screenType == ScreenType.createEvent) {
      _selectedIndex = 3;
      setState(() {});
    } else if (screenType == ScreenType.addSchedule) {
      _selectedIndex = 2;
      setState(() {});
    } else if (screenType == ScreenType.memberAdded) {
      _selectedIndex = 3;
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Clean up resources
    // ...
    // Unregister your State class as a binding observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        totalUnreadChats: totalUnreadChats,
        totalUnreadEvents: totalUnreadEvents,
      ),
      body: (appReady)
          ? (_status == PermissionStatus.denied ||
                  _status == PermissionStatus.permanentlyDenied)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Location Services Disabled",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          "This application requires user's location to locate buddies. Please click the button below to reconnect",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(10.0)),
                            onPressed: () {
                              getLocation();
                            },
                            child: const Text("Retry")),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    getScreen(),
                  ],
                )
          : Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(LottieFiles.animationLoading,
                    repeat: true, reverse: true),
              ),
            ),
    );
  }

  getScreen() {

    if (_selectedIndex == 2) {
      totalUnreadChats = 0;
    }
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          interestList: userInterestList,
          loggedInUser: widget.userModel,
          fullInterestList: fullInterestList,
          distance: distance,
          updateDistance: (double distance) {
            this.distance = distance;
            setState(() {
              Log.log("Change in  distance $distance");
            });
          },
        );
      case 1:
        return ConnectScreen(
          userModel: widget.userModel,
          longitude: longitude,
          latitude: latitude,
          distance: distance,
          updateDistance: (double distance) {
            this.distance = distance;
            setState(() {
              Log.log("Change in  distance $distance");
            });
          },
          fullInterestList: fullInterestList,
        );
      case 2:
        return ChatMainScreen(
          loggedInUser: widget.userModel,
          myInterestList: userInterestList,
        );
      case 3:
        return ChannelScreen(
          loggedInUser: widget.userModel,
          radius: distance.toString(),
          location: "${latitude},${longitude}",
        );
      case 4:
        return MyProfileScreen(
          userModel: widget.userModel,
          myInterestList: userInterestList,
          onDataChanged: () async {
            widget.userModel = UserModel.fromJson(
                await SharedPrefs.loadFromSharedPreferences(
                    SharedPrefs().PREFS_LOGIN_USER_DATA));
            setState(() {});
          },
        );
    }
  }

  getInterests() async {
    List<String> idList =
        widget.userModel.selectedInterests.split(",").map((id) => id).toList();

    fullInterestList = await ApiService().getInterests();
    if (mounted) {
      for (String id in idList) {
        for (InterestChipModel interest in fullInterestList) {
          if (interest.catID == id) {
            userInterestList.add(interest);
            break; // Exit the inner loop once a match is found
          }
        }
      }

      if (userInterestList.isNotEmpty && mounted) {
        setState(() {
          appReady = true;
          getLocation();
        });
      } else {
        getInterests();
      }
    }
  }

  void getLocation() async {
    final status = await Permission.locationWhenInUse.request();

    setState(() {
      _status = status;
    });
    if (_status == PermissionStatus.denied ||
        _status == PermissionStatus.permanentlyDenied) {
      await _showLocationPermissionDialog();
    } else {
      Map<String, dynamic> location = await DeviceLocation().getFullLocation();

      longitude = location['longitude'];
      latitude = location['latitude'];
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    Log.log('_showLocationPermissionDialog');
    await CustomDialogs.showAppDialog(
      context: context,
      title: const Text('Location permission required'),
      message:
          'Please enable location permission in the app settings to continue',
      callbackMethod2: () => openAppSettings(),
      buttonLabel2: 'TURN ON',
      callbackMethod1: () async {
        Navigator.of(context).pop();
      },
      buttonLabel1: 'CLOSE',
    );
  }

  _saveToken(String token) async {
    await ApiService()
        .updateToken(username: widget.userModel.username, token: token);
  }

  void _setOnlineStatus({int status = 1}) async {
    await ApiService().updateOnlineStatus(
        username: widget.userModel.username, status: status);
  }

  void _getRequests() async {
    var list = await ApiService()
        .getRecievedRequests(username: widget.userModel.username);

    if (mounted) {
      setState(() {});
    }
  }

  void _getUnreadChats() async {
    try {
      // Get the chat list for the current user
      List<ChatModel> chatList =
          await ApiService().getChatList(username: widget.userModel.username);

      // Initialize a variable to count unread chats

      // Loop through each chat in the chat list
      for (ChatModel chat in chatList) {
        // Construct the Firestore collection reference based on the chat ID
        CollectionReference collectionReference =
            FirebaseFirestore.instance.collection(chat.id);

        // Query the collection to get the latest message
        QuerySnapshot querySnapshot = await collectionReference
            .orderBy('time_stamp', descending: true)
            .limit(1)
            .get();

        // Check if there are any documents in the query result
        if (querySnapshot.docs.isNotEmpty) {
          // Extract the latest message document
          var latestMessage = querySnapshot.docs[0];
          Log.log(
              "Chat ${latestMessage['isRead']} and ${latestMessage['sender']}");
          // Check if the message is unread and sent by another person
          if (!latestMessage['isRead'] &&
              latestMessage['sender'] != widget.userModel.username) {
            // Increment the total unread chats count
            totalUnreadChats++;
          }
        }
      }

      // Print or use the total unread chats count as needed
      print('Total unread chats: $totalUnreadChats');
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error retrieving unread chats: $e');
    }
  }

  Future<void> _getEvents() async {
    try {
      // Fetch the list of channels for the current user
      List<GroupModel> myChannelsList = await ApiService()
          .getGroupChatList(username: widget.userModel.username);

      // Initialize a variable to count unread events
      int totalUnreadEvents = 0;

      // Loop through each channel in the list
      for (int i = 0; i < myChannelsList.length; i++) {
        // Construct the Firestore collection reference based on the channel ID
        CollectionReference collectionReference =
            FirebaseFirestore.instance.collection(myChannelsList[i].id);

        // Query the collection to get the latest message
        QuerySnapshot querySnapshot = await collectionReference
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        // Check if there are any documents in the query result
        if (querySnapshot.docs.isNotEmpty) {
          // Extract the latest message document
          var latestMessage = querySnapshot.docs[0];

          // Check if the message has been read by the current user
          List<dynamic> readBy = latestMessage['read_by'] ?? [];
          if (!readBy.contains(widget.userModel.username)) {
            // Increment the total unread events count
            totalUnreadEvents++;
          }
        }
      }

      // Print or use the total unread events count as needed
      print('Total unread events: $totalUnreadEvents');

      // Update the state if necessary
      setState(() {
        // Update state variables here if needed
      });
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error retrieving unread events: $e');
    }
  }
}
