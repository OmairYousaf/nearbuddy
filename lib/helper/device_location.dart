import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

import 'package:location/location.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:location/location.dart' as location_package;


class DeviceLocation {
  location_package.Location location = location_package.Location();
  double latitude = 0.0;
  double longitude = 0.0;
  final StreamController<LocationData> _locationController =
      StreamController<LocationData>();
  StreamSubscription<LocationData>? _locationSubscription;

  double getLat() {
    return latitude;
  }

  double getLong() {
    return longitude;
  }

  Future<bool> checkLocationPermission() async {
    PermissionStatus permission = await location.hasPermission();
    return permission == PermissionStatus.granted;
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus permission = await location.requestPermission();
    if (permission != PermissionStatus.granted) {
      throw Exception('Location permission not granted');
    }
  }

  Future<Map<String, dynamic>> getFullLocation() async {
    LocationData locationData = await location.getLocation();
    try {
      longitude = locationData.longitude!;
      latitude = locationData.latitude!;
      String address = "";
      if (!kIsWeb) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            locationData.latitude!, locationData.longitude!);
        Placemark place = placemarks[0];
        address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
      return {
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'address': address
      };
    } catch (e) {
      Log.log(e.toString());
      return {'latitude': 0, 'longitude': 0, 'address': ""};
    }
  }

  Future<String> getAddress(latitude, longitude) async {
    List placemarks = await placemarkFromCoordinates(latitude, longitude,
        localeIdentifier: "en");

    Placemark place = placemarks[0];
    String address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    return address;
  }

  Stream<LocationData> getLocation() {
    var location = location_package.Location();

    location.requestPermission().then((permissionStatus) {
      location.changeSettings(interval: 5000);
      if (permissionStatus == PermissionStatus.granted) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        location.serviceEnabled().then((value) => {
              if (value)
                {
                  location.requestService().then((value) => {
                        _locationSubscription =
                            location.onLocationChanged.listen((locationData) {
                          longitude = locationData.longitude!;
                          latitude = locationData.latitude!;
                          _locationController.add(locationData);
                        })
                      })
                }
            });
      }
    });

    return _locationController.stream;
  }

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
  }
}

/*

class DeviceLocation {
  double latitude = 0.0;
  double longitude = 0.0;
  final StreamController<Position> _locationController =
  StreamController<Position>();
  StreamSubscription<Position>? _locationSubscription;

  double getLat() {
    return latitude;
  }

  double getLong() {
    return longitude;
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw Exception('Location permission not granted');
    }
  }

  Future<Map<String, dynamic>> getFullLocation() async {
    String address = "";
    await for (Position position in getLocation()) {
      // Update the latitude and longitude properties with the current position

      try {
        latitude = position.latitude;
        longitude = position.longitude;

        if (!kIsWeb) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              latitude, longitude);
          Placemark place = placemarks[0];
          address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
        }
        return {
          'latitude': latitude,
          'longitude': longitude,
          'address': address
        };
      } catch (e) {
        Log.log(e.toString());
        return {'latitude': 0, 'longitude': 0, 'address': ""};
      }

    }
    return {
      'latitude': latitude??0,
      'longitude': longitude??0,
      'address': address
    };
  }

  Stream<LocationData> getLocation() {
    final LocationSettings locationSettings = LocationSettings(

    accuracy: geolocator.LocationAccuracy.best,
      distanceFilter: 100,
    );

    if (_locationSubscription == null || _locationSubscription!.isPaused) {
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
            (position) {
          // Emit the position over our controller
          _locationController.add(position);
        },
      );
    }

    return _locationController.stream;
  }

  Future<String> getAddress(latitude, longitude) async {
    List placemarks = await placemarkFromCoordinates(latitude, longitude,
        localeIdentifier: "en");

    Placemark place = placemarks[0];
    String address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    return address;
  }

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
  }
}
*/
