import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/models/request_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../../../components/custom_dialogs.dart';
import '../../../../../constants/apis_urls.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/image_paths.dart';
import '../../../../../models/user_model.dart';

class RequestListItem extends StatelessWidget {
  UserModel loggedInUser;
  RequestModel requestModel;
  int index;
  bool isSentRequests;
  Function({required int index, required String chatID}) onSetRequestStatus;
  Function() getProfileUser;

  RequestListItem(
      {Key? key,
      required this.index,
      this.isSentRequests = false,
      required this.requestModel,
      required this.loggedInUser,
      required this.onSetRequestStatus,
      required this.getProfileUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // handle container click here
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: isSentRequests
            ? const EdgeInsets.all(10.0)
            : const EdgeInsets.fromLTRB(0, 0, 0, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFF2F2F2),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 4), color: Color(0x49CDCDCD), blurRadius: 8)
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => getProfileUser(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl:
                          "${ApiUrls.usersImageUrl}/${requestModel.image}",
                      width: 60,
                      height: 60,
                      placeholder: (context, url) =>
                          Image.asset(ImagesPaths.placeholderImage),
                      errorWidget: (context, url, error) =>
                          Image.asset(ImagesPaths.placeholderImage),
                      fadeInDuration: const Duration(milliseconds: 500),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "${requestModel.name}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${requestModel.username}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Icon(
                  (requestModel.gender == "Female")
                      ? FontAwesomeIcons.venus
                      : FontAwesomeIcons.marsStrokeUp,
                  color: (requestModel.gender == "Female")
                      ? kPrimaryLight
                      : kPrimaryColor,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '"${requestModel.msg}"',
                style: TextStyle(color: kBlack, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: isSentRequests,
              child: RichText(
                text: TextSpan(
                  text: 'Status: ',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(
                      text: requestModel.status.name,
                      style: TextStyle(
                        color: requestModel.status == RequestStatus.Pending
                            ? Colors.grey
                            : requestModel.status == RequestStatus.Accepted
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
                visible: isSentRequests,
                child: _buildBtn(
                    onPressed: () {
                      _setRequestStatus(RequestStatus.Cancel, context);
                    },
                    color: kWhiteColor,
                    bgColor: kGreyDark,
                    overLayColor: kGrey,
                    text: 'Cancel Request')),
            Visibility(
              visible: !isSentRequests,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 18.0),
                child: Row(
                  children: [
                    Expanded(
                        child: _buildBtn(
                            onPressed: () {
                              _setRequestStatus(
                                  RequestStatus.Declined, context);
                            },
                            color: const Color(0XffBF5678),
                            overLayColor: const Color(0xFFFDCEDA),
                            bgColor: const Color(0xFFFFEBF0),
                            text: 'Decline')),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: _buildBtn(
                            onPressed: () {
                              _setRequestStatus(
                                  RequestStatus.Accepted, context);
                            },
                            color: const Color(0Xff76AB4D),
                            bgColor: const Color(0xFFFDFFFB),
                            overLayColor: const Color(0xFFE3FFC8),
                            text: 'Accept')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBtn(
      {required VoidCallback onPressed,
      required Color color,
      required Color bgColor,
      required Color overLayColor,
      required String text}) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade100;
            }
            return bgColor;
          }),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed)) {
              return overLayColor;
            }
            return Colors.transparent;
          }),
          side: MaterialStateProperty.resolveWith((states) {
            Color borderColor;

            if (states.contains(MaterialState.disabled)) {
              borderColor = Colors.greenAccent;
            } else if (states.contains(MaterialState.pressed)) {
              borderColor = Colors.yellow;
            } else {
              borderColor = Colors.pinkAccent;
            }

            return BorderSide(color: color, width: 2);
          }),
          shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
            return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16));
          }),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ) /*ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        elevation: 0,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        side: BorderSide(
          color: color,
          width: 2.0,
        ),
      ),*/
        );
  }

  _setRequestStatus(RequestStatus status, context) async {
    CustomDialogs.showLoadingAnimation(context);
    String result = await ApiService().setRequestStatus(
        groupID: requestModel.requestId,
        status: status == RequestStatus.Accepted
            ? '1'
            : status == RequestStatus.Cancel
                ? '3'
                : '0');
    Navigator.of(context).pop();
    if (result != '-1') {
      onSetRequestStatus(index: index, chatID: result);
    } else {
      if (status == RequestStatus.Cancel) {
        onSetRequestStatus(index: index, chatID: result);
      } else {
        CustomSnackBar.showErrorSnackBar(context, "Connection Error");
      }
    }
  }
}
