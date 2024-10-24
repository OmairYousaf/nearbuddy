import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/colors.dart';

class BottomNavWidget extends StatelessWidget {
  int selectedIndex = 0;
  Function(int) onItemTapped;
  int totalUnreadChats = 0;
  int totalUnreadEvents = 0;

  BottomNavWidget(
      {Key? key,
      required this.selectedIndex,
      required this.onItemTapped,
      required this.totalUnreadChats,
      required this.totalUnreadEvents})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Color(0xFFC9C9C9),
            offset: Offset(0, 5),
          )
        ],
        borderRadius:
            const BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationItem(index: 0, iconData: FontAwesomeIcons.house, label: "Home"),
          _buildNavigationItem(index: 1, iconData: FontAwesomeIcons.heart, label: "Connect"),
          _buildNavigationItem(
            index: 2,
            iconData: FontAwesomeIcons.comments,
            label: "Chat",
            showBadge: totalUnreadChats != 0,
            showBadgeText: totalUnreadChats.toString(),
          ),
          _buildNavigationItem(
            index: 3,
            iconData: FontAwesomeIcons.hashtag,
            label: "Events",
            showBadge: totalUnreadEvents != 0,
            showBadgeText: totalUnreadEvents.toString(),
          ),
          _buildNavigationItem(index: 4, iconData: FontAwesomeIcons.user, label: "Profile"),
        ],
      ),
    );
  }

  _buildNavigationItem({
    required int index,
    required IconData iconData,
    required String label,
    bool showBadge = false,
    String showBadgeText = "",
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Stack(
            children: [
              ClipOval(
                child: Material(
                  color: selectedIndex == index ? kPrimaryColor : kWhiteColor,
                  child: InkWell(
                    splashColor: kPrimaryTransparent,
                    onTap: () {
                      onItemTapped(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(
                          iconData,
                          size: 16,
                          color: selectedIndex == index ? kWhiteColor : kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (showBadge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red, // Choose your desired badge color
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${showBadgeText}', // Or any number you want to display as a badge
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 4), // Adjust the spacing as needed
        Text(
          label,
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 12, // Adjust the font size as needed
          ),
        ),
      ],
    );
  }
}
