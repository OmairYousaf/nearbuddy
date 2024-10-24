import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

import '../../../../models/user_model.dart';

class NotificationScreen extends StatefulWidget {
  UserModel loggedInUser;

  NotificationScreen(
      {Key? key,
        required this.loggedInUser,
})
      : super(key: key);


  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: const Text("My Notifications"),
        foregroundColor: Colors.black54,

      ),

      body: NotificationItem(
        title: 'New Notification',
        message: 'You have a new message',
        timestamp: DateTime.now(),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final DateTime timestamp;

  const NotificationItem({super.key, 
    required this.title,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(0,2),
            blurRadius: 5
          )
        ]
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor,
          child: const Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(message),
        trailing: Text(
          _formatTimestamp(context,timestamp),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final time = TimeOfDay.fromDateTime(timestamp).format(context);
    final date = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    return time;
  }

}
