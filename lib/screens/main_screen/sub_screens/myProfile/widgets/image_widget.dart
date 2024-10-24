import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/constants/image_paths.dart';

import '../../../../../constants/colors.dart';

class ImageWidget extends StatelessWidget {
  final bool isSmall;

  final bool isNetworkImage;
  final String imageUrl;
  final File? assetImage;
  final VoidCallback onChange;
  const ImageWidget(
      {Key? key,
      required this.isSmall,
      required this.imageUrl,
      required this.onChange,
      required this.isNetworkImage,
      this.assetImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(15),
        dashPattern: const [8, 4],
        strokeWidth: 2,
        color: const Color(0xffe3e3e3),
        child: InkWell(
          onTap: onChange,
          child: Container(
            width: isSmall ? null : 250,
            height: isSmall ? null : 250,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: Border.all(
                width: 2,
                color: kWhiteColor,
              ),
            ),
            child: (isNetworkImage)
                ? (imageUrl != '')
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              child: (isNetworkImage)
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      placeholder: (context, url) => Image.asset(
                                        ImagesPaths.placeholderImage,
                                        fit: BoxFit.cover,
                                      ),
                                      fit: BoxFit.cover,
                                      fadeInDuration: const Duration(milliseconds: 500),
                                      fadeInCurve: Curves.easeIn,
                                      errorWidget: (context, url, error) =>
                                          _buildPlaceHoldeWidget(isSmall),
                                    )
                                  : kIsWeb
                                      ? Image.network(
                                          assetImage!.path,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          assetImage!,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                          ),
                          const Center(
                              child: Icon(
                            FontAwesomeIcons.camera,
                            color: Colors.white,
                          ))
                        ],
                      )
                    : _buildPlaceHoldeWidget(isSmall)
                : (assetImage != null)
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              child: kIsWeb
                                  ? Image.network(
                                      assetImage!.path,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      assetImage!,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                          ),
                          const Center(
                              child: Icon(
                            FontAwesomeIcons.camera,
                            color: Colors.white,
                          ))
                        ],
                      )
                    : _buildPlaceHoldeWidget(isSmall),
          ),
        ));
  }
}

_buildPlaceHoldeWidget(isSmall) {
  return (isSmall)
      ? Center(
        child: Icon(
            Icons.add_a_photo,
            size: 25,
            color: kGreyDark,
          ),
      )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 25,
              color: kGreyDark,
            ),
            Text(
              "Tap to add a Picture",
              style: TextStyle(
                color: kGreyDark,
              ),
            ),
          ],
        );
}
