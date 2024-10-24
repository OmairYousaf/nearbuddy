import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../constants/apis_urls.dart';
import '../../../../../constants/colors.dart';
import '../../../../../helper/utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationEnabled = true; // Set the default value of the notification switch.

  // Function to handle notification switch state change.
  void _handleNotificationSwitch(bool newValue) {
    setState(() {
      isNotificationEnabled = newValue;
    });
  }

  // Function to open a webpage using the URL launcher.


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        leading: (kIsWeb)?null:IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            FontAwesomeIcons.chevronLeft,
            color: kBlack,
            size: 20,
          ),
        ),
        backgroundColor: kWhiteColor,
        title: Text(
          "Settings",
          style: TextStyle(color: kBlack, fontSize: 18),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10,),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Turn on notification'),
                trailing: Switch(
                  value: isNotificationEnabled,
                  onChanged: _handleNotificationSwitch,
                ),
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 10,),
              const Text(
                'Learn about our',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10,),
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('Terms and Conditions'),
                onTap: () async {
                  await Utils().openUrl(ApiUrls.urlTermsCondition);
                },
              ),
              const SizedBox(height: 10,),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy and Policy'),
                onTap: () async {
                  await Utils().openUrl(ApiUrls.urlPrivacyPolicy);
                },
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 10,),
              const Text(
                'Manage Account Info',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10,),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                // Implement change password functionality here.
                onTap: () {
                  // TODO: Implement change password functionality.
                },
              ),
/*              SizedBox(height: 10,),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Blocked Accounts'),
                // Implement blocked accounts functionality here.
                onTap: () {
                  // TODO: Implement blocked accounts functionality.
                },
              ),*/
              const SizedBox(height: 10,),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete My Account'),
                // Implement delete account functionality here.
                onTap: () {
                  // TODO: Implement delete account functionality.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
