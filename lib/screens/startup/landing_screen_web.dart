import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/constants/image_paths.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../responsive.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      !kIsWeb ? displaySheet() : () {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Responsive(
        // Let's work on our mobile part
        mobile: _buildTabletView(),
        tablet: _buildTabletView(),
        desktop: _buildDesktopView(),
      ),
    );
  }

  Widget _buildTabletView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kPurple,
              kPrimaryColor,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildToolbar(isDesktop: false),
            _buildTextContent(isDesktop: false),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kPurple,
              kPrimaryColor,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: _buildToolbar(isDesktop: true),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
              child: _buildContent(isDesktop: true),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar({required bool isDesktop}) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            ImagesPaths.lightLogo,
            width: (isDesktop) ? 150 : 100,
            height: (isDesktop) ? 150 : 100,
          ),
          const Expanded(child: SizedBox()),
          (isDesktop)
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // <-- Radius
                    ),
                  ),
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Download Mobile App",
                      style: TextStyle(
                        color: kWhiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  _buildContent({required bool isDesktop}) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTextContent(isDesktop: isDesktop)),
          Expanded(child: _buildStackedImage()),
        ],
      ),
    );
  }

  _buildTextContent({required bool isDesktop}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 100,
        ),
        Text(
          "Discover Your Tribe: Find Like-Minded People Nearby",
          style: TextStyle(
            color: kWhiteColor,
            fontWeight: FontWeight.w600,
            fontSize: 40,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Connect with individuals who share your passions and interests with just a few taps",
          style: TextStyle(
            color: kPrimaryDark,
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Flexible(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurpleDeep,
                padding: isDesktop
                    ? const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 100.0)
                    : const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // <-- Radius
                ),
              ),
              onPressed: () => _toLoginScreen(),
              child: const Text("Join Now")),
        ),
      ],
    );
  }

  _buildStackedImage() {
    return FittedBox(
      fit: BoxFit.fitWidth,
      alignment: Alignment.centerRight,
      child: Stack(
        children: [
          ConstrainedBox(
            constraints:
                const BoxConstraints(minWidth: 1, minHeight: 1), // here
            child: Image.asset(
              ImagesPaths.desktop,
            ),
          ),
        ],
      ),
    );
  }

  void displaySheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: ListTile(
              title: const Text('Would you like to download our app?'),
              trailing: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.download,
                  ),
                  label: const Text("Download Now")),
            ),
          );
        });
  }

  _toLoginScreen() {
    //TODO: REMOVE WEB
    //  Navigator.of(context).push(   MaterialPageRoute(builder: (context) => CompleteProfileScreen(email: "Aqsa@fmail.com", name: "Aqsa", password: "123456", loginType: LoginType.manual)),);
    //  Navigator.of(context).push(   MaterialPageRoute(builder: (context) => LoginScreen()),);
    Navigator.pushNamed(
      context,
      '/login',
    );
  }
}
