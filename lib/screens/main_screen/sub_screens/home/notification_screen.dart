import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/models/notification_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../../models/user_model.dart';

class NotificationScreen extends StatefulWidget {
  UserModel loggedInUser;

  NotificationScreen({
    Key? key,
    required this.loggedInUser,
  }) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel>? notificationsList;

  @override
  void initState() {
    getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: const Text("My Notifications"),
        foregroundColor: Colors.black54,
      ),
      body: RefreshIndicator(
          onRefresh: () => getNotifications(),
          child: notificationsList == null
              ? const Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : notificationsList!.isEmpty
                  ? const Center(
                      child: Text(
                        "You don't have any notification yet",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      cacheExtent: 900,
                      itemCount: notificationsList!.length,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        NotificationModel notificationModel =
                            notificationsList![index];
                        return NotificationItem(
                          //    Update Design if need... ()
                          title: 'New Notification',
                          message: notificationModel.name!,
                          timestamp: notificationModel.timeStamp!,
                        );
                      },
                    )),
    );
  }

  Future<List<NotificationModel>?> getNotifications() async {
    notificationsList = await ApiService()
        .getNotifications(username: widget.loggedInUser.username);
    setState(() {});
    return notificationsList;
  }

  String getDate(String date) {
    // String dateString = "2024-06-22 18:13:10";
    DateTime parsedDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
    String formattedDate = DateFormat("dd-MM-yyyy").format(parsedDate);

    return formattedDate;
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String timestamp;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(25.0)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade100,
                offset: const Offset(0, 2),
                blurRadius: 5)
          ]),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor,
          child: const Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(message),
        trailing: Text(
          _formatTimestamp(context, timestamp),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  String _formatTimestamp(BuildContext context, String timestamp) {
    DateTime parsedDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timestamp);
    String formattedDate = DateFormat("dd-MM-yyyy hh:mm a").format(parsedDate);
    // final time = TimeOfDay.fromDateTime(timestamp).format(context);
    // final date = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    return formattedDate;
  }
}
