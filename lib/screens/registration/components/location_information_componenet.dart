import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_address_from_latlng/flutter_address_from_latlng.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../helper/device_location.dart';
import '../complete_profile_screen.dart';
import 'small_map_component.dart';

class LocationInformation extends StatefulWidget {
  final PersonalData personalData;
  final TextEditingController addressController;
  const LocationInformation({
    Key? key,
    required this.personalData,
    required this.addressController,
  }) : super(key: key);

  @override
  State<LocationInformation> createState() => _LocationInformationState();
}

class _LocationInformationState extends State<LocationInformation> {
  double newLat = 43.2994;
  double newLong = 74.2179;
  bool _permissionGranted = false;
  late GoogleMapController _controller; //to control the camera of the google map
  final markers = <Marker>{}; //a set of markers is needed to pin the location on map
  MarkerId markerId =
      const MarkerId("myLocationMarker"); //this marker is added to the previous markers set
  LatLng myLatLng = const LatLng(43.2994, 74.2179); //the init lat and lng
  String addressTxt = ""; //user's address
  DeviceLocation deviceLocation = DeviceLocation();
  PermissionStatus _status = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _getLocation();
    } else {
      setData();
    }
    //selecting categorize for edit
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      if (_status == PermissionStatus.denied || _status == PermissionStatus.permanentlyDenied) {
        _requestLocationPermission();
      }
    }
    return ((_status == PermissionStatus.denied || _status == PermissionStatus.permanentlyDenied) &&
            !kIsWeb)
        ? Container(
            child: ElevatedButton(
              onPressed: () => _showLocationPermissionDialog(),
              child: const Text("Enable Location"),
            ),
          )
        : (kIsWeb && !(_permissionGranted))
            ? Container(
                child: ElevatedButton(
                  onPressed: () => _getLocation(),
                  child: const Text("Please unblock location permissions and refresh"),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus(); //used to remove keyboard from the app
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Step 2",
                        style: TextStyle(
                            color: Color(0xFFEDEDED), fontWeight: FontWeight.w300, fontSize: 22),
                      ),
                      const Text(
                        "Please help us to locate you",
                        style: TextStyle(
                            color: Color(0xFFF3F2F2), fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      buildGoogleMap(),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kWhiteColor,
                          foregroundColor: kPrimaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.all(20.0),
                        ),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          LatLng result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapSmallWidget(newLat, newLong, true)));
                          newLat = double.parse(result.latitude.toStringAsFixed(6));
                          newLong = double.parse(result.longitude.toStringAsFixed(6));
                          getAddressFromLatLong(newLat, newLong);
                          setState(() {
                            _controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(target: LatLng(newLat, newLong), zoom: 20),
                              ),
                            );
                            widget.personalData.latitude = newLat.toString();
                            widget.personalData.longitude = newLong.toString();
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.locationDot,
                              color: Color(0xFFCCCCCC),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                addressTxt.isEmpty ? "Tap to Locate" : addressTxt,
                                style: TextStyle(
                                    color: const Color(0xFFCCCCCC),
                                    fontSize: addressTxt.isEmpty ? 18 : 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      /*             buildTextIconFormField(
                          context: context,
                          hint: 'Enter Your Address',
                          iconSize: 24,
                          radius: 10,
                          onChanged: (value) {},
                          textInputType: TextInputType.text,
                          textEditingController: widget.addressController,
                          icon: FontAwesomeIcons.house,
                          iconColor: widget.addressController.text.isNotEmpty
                              ? const Color(0xFF000000)
                              : const Color(0xFFCCCCCC),
                          fontSize: 18),
                      const SizedBox(
                        height: 5,
                      ),*/
                      const Text(
                        "Tap on the button above to locate yourself",
                        style: TextStyle(
                            color: Color(0xFFF3F2F2), fontWeight: FontWeight.w200, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
  }

  buildGoogleMap() {
    markers.add(
      Marker(
        markerId: markerId,
        position: LatLng(newLat, newLong),
      ),
    );
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
          width: 5,
          color: kWhiteColor,
        ),
      ),
      child: AbsorbPointer(
        absorbing: true,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(newLat, newLong),
            zoom: 20,
          ),
          markers: markers,
          zoomControlsEnabled: false,
          onCameraMove: ((position) => _updatePosition(position)),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
        ),
      ),
    );
  }

  _updatePosition(CameraPosition cameraPosition) {
    WidgetsFlutterBinding.ensureInitialized();
    if (!mounted) {
      setState(() {
        markers.add(Marker(markerId: markerId, position: cameraPosition.target));
        myLatLng = cameraPosition.target;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();

    setState(() {
      _status = status;
    });

    if (_status == PermissionStatus.denied) {
      await _showLocationPermissionDialog();
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    await CustomDialogs.showAppDialog(
      context: context,
      title: const Text('Location permission required'),
      message: 'Please enable location permission in the app settings to continue',
      callbackMethod2: () => openAppSettings(),
      buttonLabel2: 'TURN ON',
      callbackMethod1: () => Navigator.of(context).pop(),
      buttonLabel1: 'CLOSE',
    );
  }

  Future getAddressFromLatLong(latitude, longitude) async {
    try {
      if (kIsWeb) {
        String formattedAddress = await FlutterAddressFromLatLng().getFormattedAddress(
          latitude: latitude,
          longitude: longitude,
          googleApiKey: Utils().googleAPIKey,
        );
        addressTxt = formattedAddress ?? "";
      } else {
        List placemarks =
            await placemarkFromCoordinates(latitude, longitude, localeIdentifier: "en");

        Placemark place = placemarks[0];
        addressTxt =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
    } catch (E) {
      addressTxt = "";
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getLocation() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied || status == LocationPermission.deniedForever) {
      // Ask for permission
      status = await Geolocator.requestPermission();
      if (status == LocationPermission.denied || status == LocationPermission.deniedForever) {
        setState(() {
          _permissionGranted = false;
        });
      } else {
        _permissionGranted = true;

        var position = await Geolocator.getCurrentPosition();
        setState(() {
          newLat = position.latitude;
          newLong = position.longitude;
          Log.log(position.toString());
          Log.log(newLat);
        });
      }
    } else if (status == LocationPermission.whileInUse || status == LocationPermission.always) {
      _permissionGranted = true;

      var position = await Geolocator.getCurrentPosition();
      setState(() {
        newLong = position.latitude;
        newLong = position.longitude;
      });
    }
  }

  Future<void> setData() async {
// Check if the app has location permission
    bool hasLocationPermission = await deviceLocation.checkLocationPermission();
    if (!hasLocationPermission) {
      // Request location permission if not granted
      await deviceLocation.requestLocationPermission();
    }
    CustomDialogs.showLoadingAnimation(context);
// Get the device's location
    Map<String, dynamic> location = await deviceLocation.getFullLocation();
    newLat = location['latitude'];
    newLong = location['longitude'];
    addressTxt = location['address'];
    deviceLocation.stopLocationUpdates();
    setState(() {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(newLat, newLong), zoom: 20),
        ),
      );
      widget.personalData.latitude = newLat.toString();
      widget.personalData.longitude = newLong.toString();
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    deviceLocation.stopLocationUpdates();
  }

/* void getWebLocation() {
    js.context.callMethod("getCurrentPosition").then((position) {
      double lat = position["latitude"];
      double lng = position["longitude"];
      print("Latitude: $lat, Longitude: $lng");
      // Use the latitude and longitude as needed.
    }).catchError((error) {
      print("Error getting geolocation: $error");
    });
  }*/
}
