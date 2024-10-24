import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/image_paths.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String appVersion = 'Loading...'; // Default text while fetching the version.

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        leading:(kIsWeb)?null: IconButton(
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
          "About us",
          style: TextStyle(color: kBlack, fontSize: 18),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Replace 'company_logo.png' with your actual logo image asset.
                Center(child: Image.asset(ImagesPaths.darkLogo, width: 150, height: 150)),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Nearby Buddy - About Us',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Our app connects nearby people based on interests and lets them join in fun activities together.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'App Version: $appVersion',
                    style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
