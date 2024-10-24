// ignore_for_file: unnecessary_import

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:location/location.dart' as location_package;
import 'package:location/location.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

class MapSmallWidget extends StatefulWidget {
  final double lat;
  final double lng;
  final bool showSetLoc;

  const MapSmallWidget(this.lat, this.lng, this.showSetLoc, {super.key});

  @override
  State<MapSmallWidget> createState() => _MapSmallWidgetState();
}

class _MapSmallWidgetState extends State<MapSmallWidget> {
  late GoogleMapController _controller;
  final markers = <Marker>{};
  MarkerId markerId = const MarkerId("1");
  LatLng newLatLng = const LatLng(43.2994, 74.2179);

  @override
  void initState() {
    newLatLng = LatLng(widget.lat, widget.lng);
    markers.add(
      Marker(
        markerId: markerId,
        position: LatLng(widget.lat, widget.lng),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    markers.add(
      Marker(
        markerId: markerId,
        position: LatLng(widget.lat, widget.lng),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Set Location"),
        foregroundColor: kPrimaryColor,
      ),
      body: AbsorbPointer(
        absorbing: !widget.showSetLoc,
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.lat, widget.lng),
                  zoom: 20,
                ),
                markers: markers,
                zoomControlsEnabled: false,
                onCameraMove: ((position) => _updatePosition(position)),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
              Visibility(
                visible: widget.showSetLoc,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 70.0),
                    width: kIsWeb?null:double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(10.0),
                        backgroundColor: const Color(0xFF570D90),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, newLatLng);
                      },
                      child: const Text(
                        "Set Location",
                        style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: widget.showSetLoc,
                child: Align(
                  alignment: Alignment.topRight,
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your logic to handle button press
                        print('Locate Me button pressed!');
                        getLocation(); //get my location
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                        ),
                        backgroundColor:const Color(0xFF570D90), // Background color
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(width: 8.0),
                            Text('Locate Me'),
                          ],
                        ),
                      ),
                    ),
                  ) /*Container(
                    padding:kIsWeb?const EdgeInsets.fromLTRB(50, 20, 50, 20): const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 0.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF570D90),
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Color(0xFFE8E8E8),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    margin: kIsWeb?const EdgeInsets.fromLTRB(0, 0, 0, 0):const EdgeInsets.fromLTRB(0, 50, 10, 0),
                    child: TextButton.icon(
                      icon: const Icon(FontAwesomeIcons.locationArrow,
                          color: Color(0xFFFFFFFF)),
                      onPressed: () {
                        getLocation(); //get my location
                      },
                      label: const Text(
                        "Locate Me",
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),*/
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Future<void> getLocation() async {
    CustomDialogs.showLoadingAnimation(context);
    LatLng currentLocation = LatLng(newLatLng.latitude, newLatLng.longitude);
    String address = "";
    if (kIsWeb) {
      var position = await Geolocator.getCurrentPosition();
       currentLocation = LatLng(position.latitude, position.longitude);
    } else {
      location_package.Location location = location_package.Location();
      LocationData locationData = await location.getLocation();
      currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude);
      String address = placemarks.first.street!;
    }
    setState(() {
      Navigator.of(context).pop();
      markers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        position: currentLocation,
        infoWindow: InfoWindow(title: address),
      ));
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 20),
        ),
      );
    });
  }

  _updatePosition(CameraPosition cameraPosition) {
    setState(() {
      markers.add(Marker(markerId: markerId, position: cameraPosition.target));
      newLatLng = cameraPosition.target;
    });
  }
}
