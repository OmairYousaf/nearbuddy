import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/responsive.dart';
import 'package:nearby_buddy_app/screens/main_screen/web/main_screen_web.dart';
import 'package:nearby_buddy_app/screens/registration/complete_profile_screen.dart';
import 'package:nearby_buddy_app/screens/registration/login_screen.dart';
import 'package:nearby_buddy_app/screens/startup/landing_screen_web.dart';
import 'package:nearby_buddy_app/screens/startup/splash_screen_mobile.dart';

import 'firebase_options.dart';
import 'helper/utils.dart';

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class MyFirebaseMessaging {
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // // Add your custom background handling logic here
    // // Handle the received notification message
    //
    // Future onDidReceiveLocalNotification(
    //     int? id, String? title, String? body, String? payload) async {
    //   print('onDidReceiveLocalNotification');
    // }
    //
    // final channel = AndroidNotificationChannel(
    //   'my_channel_01', // id
    //   'High Importance Notifications', // title
    //   description: 'This channel is used for important notifications.', // des
    //   importance: Importance.high,
    // );
    //
    // var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    //
    // final initializationSettingsAndroid =
    //     AndroidInitializationSettings('notification_icon');
    //
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channel);
    // final initializationSettings = InitializationSettings(
    //   android: initializationSettingsAndroid,
    // );
    // await flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    // );
    //
    // ///Not able to stop default notification
    // ///there fore when custom notification is called
    // ///result is 2 notifications displayed.
    //
    // flutterLocalNotificationsPlugin.show(
    //   message.notification.hashCode,
    //   message.notification!.title,
    //   message.notification!.body,
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'my_channel_01', // id
    //       'High Importance Notifications', // title
    //       channelDescription:
    //           'This channel is used for important notifications.', // d
    //
    //       icon: 'notification_icon',
    //     ),
    //   ),
    // );
    Log.log("Handling a background message: ${message.messageId}");

    // Extract notification data
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      final title = notification.title;
      final body = notification.body;
      Log.log('Notification Title: $title');
      Log.log('Notification Body: $body');
      Log.log('Notification Body: ${data['screen']}');
    }
    final screen = data['screen'];

    if (screen != null) {
      // Check the value of 'screen' and navigate to the desired screen
      if (screen == 'splash') {
        // Navigate to the splash screen
      } else if (screen == 'chat') {
        // Navigate to the chat screen
      } else if (screen == 'request') {}

      // Add more conditions for other screen values as needed
    }
    // Handle the notification data as needed
  }
}

void main() async {
  await Hive.initFlutter();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
      MyFirebaseMessaging.firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      debugShowCheckedModeBanner: false,
      title: 'Nearby buddy',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white))),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: kPrimaryDark, primary: kPrimaryColor),
      ),
      // home: getStartingScreen(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => getStartingScreen(),
        '/login': (context) => const LoginScreen(),
        '/registerProfile': (context) => CompleteProfileScreen(),
        '/mainpage': (context) => _getMainScreen(),
        //  '/register':(context) =>CompleteProfileScreen(email: email, name: name, password: password, loginType: loginType)
      },
    );
  }

  getStartingScreen() {
    if (Responsive.isMobile()) {
      //opened as mobile app
      return const SplashScreen();
    } else {
      return const LandingScreen();
    }
  }

  _getMainScreen() {
    return const MainScreenWeb();
  }
}
