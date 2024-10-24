import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../components/controls.dart';
import '../../../../../../constants/image_paths.dart';

class EditGroupDetailsScreen extends StatelessWidget {
  bool filled;
  bool filled2;
  bool filled3;
  TextEditingController fullnameController;
  TextEditingController groupDetailsTxtCntrl;
  String addressTxt;
  Set<Marker> markers;
  double myLatitude;
  double myLongitude;
  bool isPrivate;
  Function(String) onChangedTitle;
  Function(String) onChangeDesp;
  Function(bool) onSwitchChanged;
  Function(GoogleMapController controller) onMapCreated;
  Function(CameraPosition position) updatePosition;
  Future<void> Function() onLocationPicked;
  File? imageFile;
  String urlImage;
  VoidCallback onComplete;
  VoidCallback onImageChange;

  EditGroupDetailsScreen(
      {required this.filled,
      required this.filled2,
      required this.filled3,
      required this.fullnameController,
      required this.groupDetailsTxtCntrl,
      required this.addressTxt,
      required this.onMapCreated,
      required this.updatePosition,
      required this.isPrivate,
      required this.onSwitchChanged,
      required this.myLongitude,
      required this.myLatitude,
      required this.markers,
      required this.onChangedTitle,
      required this.onChangeDesp,
      required this.onLocationPicked,
      required this.imageFile,
      required this.urlImage,
      required this.onComplete,
      required this.onImageChange,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 5, color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFADADAD).withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      (imageFile == null)
                          ? CachedNetworkImage(
                              imageUrl:
                                  (urlImage.isNotEmpty) ? urlImage : ImagesPaths.placeholderImage,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: const CircleAvatar(
                                  radius: 130,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 130,
                                backgroundImage: imageProvider,
                              ),
                              errorWidget: (context, url, error) => const CircleAvatar(
                                radius: 130,
                                backgroundImage: AssetImage(ImagesPaths.placeholderImage),
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: FileImage(imageFile!),
                              radius: 130,
                            ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: onImageChange,
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.camera_alt,
                              size: 22,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            buildTextIconFormField(
                context: context,
                fillColor: const Color(0xffF7F7F7),
                hint: 'Enter Your Event title',
                onChanged: onChangedTitle,
                textInputType: TextInputType.text,
                textEditingController: fullnameController,
                icon: FontAwesomeIcons.smile,
                iconColor: filled ? const Color(0xFF000000) : const Color(0xFFCCCCCC),
                fontSize: 18),
            const SizedBox(
              height: 10,
            ),
            buildTextAreaIconButton(
                context: context,
                fillColor: const Color(0xffF7F7F7),
                hint: "About Event...",
                onChanged: onChangeDesp,
                icon: FontAwesomeIcons.notesMedical,
                iconColor: filled ? const Color(0xFF000000) : const Color(0xFFCCCCCC),
                textEditingController: groupDetailsTxtCntrl),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xffF7F7F7),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border.all(
                  width: 1,
                  color: const Color(0xFFD4DBE7),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.private_connectivity),
                  const SizedBox(
                    width: 10,
                  ),
                  const Expanded(
                    child: Text("Set this event as Private?",
                        style: TextStyle(
                          color: Color(0xFF000000),
                        )),
                  ),
                  Switch(
                    value: isPrivate,
                    onChanged: (onChanged) => onSwitchChanged(onChanged),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            buildGoogleMap(),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF7F7F7),
                foregroundColor: filled3 ? const Color(0xFF000000) : const Color(0xFFCCCCCC),
                elevation: 0,
                padding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Set the border radius here
                  side: const BorderSide(
                    color: Color(0xFFD4DBE7), // Set the border color here
                    width: 1.0, // Set the border width here
                  ),
                ),
              ),
              onPressed: () async {
                onLocationPicked();
              },
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.locationDot,
                    color: filled3 ? const Color(0xFF000000) : const Color(0xFFCCCCCC),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      addressTxt.isEmpty ? "Tap to Locate" : addressTxt,
                      style: TextStyle(
                          color: filled3 ? const Color(0xFF000000) : const Color(0xFFCCCCCC),
                          fontSize: addressTxt.isEmpty ? 18 : 13,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12.0)),
              child:
                  (urlImage.isNotEmpty) ? const Text("Update Details") : const Text("Create Event"),
            ),
          ],
        ),
      ),
    );
  }

  buildGoogleMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1F1F1),
            Color(0xFFD9D9D9),
          ],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(
          width: 1,
          color: const Color(0xFFD4DBE7),
        ),
      ),
      child: AbsorbPointer(
        absorbing: true,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(myLatitude, myLongitude),
            zoom: 20,
          ),
          markers: markers,
          zoomControlsEnabled: false,
          onCameraMove: ((position) => updatePosition(position)),
          onMapCreated: (GoogleMapController controller) {
            onMapCreated(controller);
          },
        ),
      ),
    );
  }
}
