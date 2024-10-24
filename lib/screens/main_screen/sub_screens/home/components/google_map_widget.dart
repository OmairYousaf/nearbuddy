import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_buddy_app/helper/utils.dart';

import '../../../../../models/buddy_model.dart';

class GoogleMapWidget extends StatefulWidget {
  double
      userLat; //this never changes once set to the google map its for making sure non null values are passed
  double userLong;
  double bearing;
  int profileIndex;
  List<BuddyModel> buddyProfileList;
  double radius;
  double zoomlevel;
  BitmapDescriptor customIcon;
  Completer<GoogleMapController> controller;

  // Set<Circle> circles;
  List<Marker> markersList = [];
  Set<Polyline>? polylines = {};

  GoogleMapWidget({
    super.key,
    required this.userLat,
    required this.userLong,
    required this.bearing,
    required this.profileIndex,
    required this.buddyProfileList,
    required this.radius,
    required this.customIcon,
    required this.zoomlevel,
    required this.controller,
    // required this.circles,
    required this.markersList,
     this.polylines,
  });

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final _mapMarkerSC = StreamController<List<Marker>>();
  late String _mapStyle = "";

  Stream<List<Marker>> mapMarkerStream() => addmarkertoMap();
  String myMarkerID = "usermarker";
  String myCircleID = "usercircle";
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/strings/mapStyles.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void generateWorker() {}

  void addWorkerMarkers() {}

  @override
  Widget build(BuildContext context) {
    Log.log('${widget.userLat}');
    // TODO: implement build
    return StreamBuilder<List<Marker>>(
        stream: mapMarkerStream(),
        builder: (context, snapshot) {
          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.userLat, widget.userLong),
              zoom: widget.zoomlevel,
            ),
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            // polylines: widget.polylines,
            // circles: widget.circles,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) async {
              mapController = controller;
              mapController.setMapStyle(_mapStyle);
              widget.controller.complete(mapController);
              Marker newMarker = Marker(
                markerId: MarkerId(myMarkerID),
                position: LatLng(widget.userLat, widget.userLong),
                anchor: const Offset(0.5, 0.5),
                rotation: widget.bearing,
                icon: widget.customIcon,
                infoWindow: const InfoWindow(title: 'You are here!'),
              );

              widget.markersList.add(newMarker);
              _mapMarkerSC.add(widget.markersList);
              final controllers = await widget.controller.future;

              controllers.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(widget.userLat, widget.userLong),
                      zoom: widget.zoomlevel),
                ),
              );

              setState(() {});
            },
            markers: Set<Marker>.of(snapshot.data ?? []),
            padding: const EdgeInsets.all(8),
          );
        });
  }

  addmarkertoMap() {
    _mapMarkerSC.add(widget.markersList);

    return _mapMarkerSC.stream;
  }

  getDirections(LatLng startLocation, LatLng endLocation) async {
/*    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);*/
  }
}
