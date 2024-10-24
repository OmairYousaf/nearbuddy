import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../constants/colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  Function onTap;
  String title;
  IconData icon;
  bool showIcon;
  Color? titleColor;
  Color? iconColor;
  Widget? customIcon;
  PreferredSizeWidget? bottom;
  AppBarWidget(
      {Key? key,
      required this.onTap,
      required this.title,
      required this.icon,
      this.titleColor,
      this.iconColor,
      this.customIcon,
      this.bottom,
      this.showIcon = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Material(
              color: kWhiteColor,
              child: InkWell(
                splashColor: kPrimaryTransparent, // Splash color
                onTap: () => onTap(),
                child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      FontAwesomeIcons.plus,
                      size: 24,
                      color: Color(0xFF949AB9),
                    )),
              ),
            ),
          ),
        )
      ],
      title: Text(
        "Events",
        style: TextStyle(fontSize: 18, color: kPrimaryColor, fontWeight: FontWeight.bold),
      ),
      automaticallyImplyLeading: false,
      bottom: bottom,
    );
/*    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
            child: Text(
              "$title",
              style: TextStyle(
                  fontSize: 18,
                  color: titleColor ?? kPrimaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(child: SizedBox()),
          (showIcon)
              ? customIcon ??
                  ClipOval(
                    child: Material(
                      color: kWhiteColor,
                      child: InkWell(
                        splashColor: kPrimaryTransparent, // Splash color
                        onTap: () {
                          onTap();
                        },
                        child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(
                              icon,
                              size: 24,
                              color: const Color(0xFF949AB9),
                            )),
                      ),
                    ),
                  )
              : SizedBox()
        ],
      ),
    );*/
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
