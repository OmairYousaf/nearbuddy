import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:nearby_buddy_app/screens/registration/verify_otp_screen.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void main() {
  runApp(MailboxApp());
}

class MailboxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mailbox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VerifyOTPScreen(email: 'xx',user: UserModel.empty(),),
    );
  }
}

class MailboxScreen extends StatefulWidget {
  @override
  _MailboxScreenState createState() => _MailboxScreenState();
}

class _MailboxScreenState extends State<MailboxScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
