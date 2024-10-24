import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/apis_urls.dart';
import 'package:nearby_buddy_app/models/group_model.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../models/user_model.dart';

class FindChannelListItem extends StatelessWidget {
  final GroupModel groupModel;
  final UserModel loggedInUser;

  final int index;

  final VoidCallback onTap;
  const FindChannelListItem({
    Key? key,
    required this.groupModel,
    required this.loggedInUser,
    required this.index,
    required this.onTap,
  }) : super(key: key);
  Color getRandomColor() {
    final random = Random();
    final red = 128 + random.nextInt(150); // values between 128 and 255
    const green = 0;
    final blue = 128 + random.nextInt(128); // values between 128 and 255
    return Color.fromRGBO(red, green, blue, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: getRandomColor(),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            '${ApiUrls.groupsImageUrl}/${groupModel.groupIcon}',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${groupModel.groupName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '${groupModel.groupDescription}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 12.0,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(
                  Icons.group,
                  color: Colors.white,
                ),
                const SizedBox(width: 4.0),
                Text(
                  '${groupModel.groupMemberList.where((member) => member.isMember).length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (groupModel.isJoined) ? kPrimaryLight : kPrimaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                  onPressed: onTap,
                  child: Text(
                    groupModel.isJoined ? "View" : 'Join',
                    style: const TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
