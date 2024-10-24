import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/constants/apis_urls.dart';
import 'package:nearby_buddy_app/models/group_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/image_paths.dart';
import '../../../../../../models/user_model.dart';

class GroupListItem extends StatelessWidget {
  final GroupModel groupModel;
  final UserModel loggedInUser;
  final bool isGroupNewChatlist;
  final Function onLongPres;
  final int index;

  final VoidCallback onTap;
  const GroupListItem({
    Key? key,
    required this.groupModel,
    required this.loggedInUser,
    required this.index,
    required this.isGroupNewChatlist,
    required this.onLongPres,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: onTap,
      onLongPress: () {
        onLongPres();
      },
      child: Ink(
        padding: EdgeInsets.fromLTRB(5.0, index == 0 ? 0.0 : 10.0, 5.0, 10.0),
        decoration: BoxDecoration(
            color: kWhiteColor,
            border: const Border(
                bottom: BorderSide(
              color: Color(0xFFEAEAEA),
            ))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              imageUrl: "${ApiUrls.groupsImageUrl}/${groupModel.groupIcon!}",
              imageBuilder: (context, imageProvider) => CircleAvatar(
                backgroundColor: kGrey,
                radius: 30,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                backgroundColor: kGrey,
                radius: 30,
                backgroundImage: const AssetImage(ImagesPaths.placeholderImage),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupModel.groupName ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    (groupModel.lastMsg!.isNotEmpty)
                        ? groupModel.lastMsg!
                        : "Created by ${groupModel.groupAdmin}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('h:mm a').format(groupModel.newTimeStamp ?? DateTime.now()),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF999999)),
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: (groupModel.count > 0) ? kPrimaryColor : kWhiteColor,
                    shape: BoxShape.circle,
                  ),
                  child: (groupModel.count > 0)
                      ? Center(
                          child: Text(
                            '${groupModel.count}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox(),
                )
              ],
            )
          ],
        ),
      ),
    ));
  }
}
