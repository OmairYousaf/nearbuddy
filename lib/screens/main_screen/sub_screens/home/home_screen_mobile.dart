// ignore_for_file: unnecessary_import

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/constants/apis_urls.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/constants/image_paths.dart';

import 'package:nearby_buddy_app/models/interest_chip_model.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/channel/channel_view_screen.dart';

import '../../../../helper/device_location.dart';
import '../../../../components/custom_snack_bars.dart';
import '../../../../components/interest_chip_widget.dart';
import '../../../../constants/icon_paths.dart';
import '../../../../helper/utils.dart';
import '../../../../models/buddy_model.dart';
import '../../../../models/group_model.dart';
import '../../../../models/image_model.dart';
import '../../../../models/user_model.dart';
import '../../../../routes/api_service.dart';
import '../userProfile/user_profile_screen.dart';
import 'components/google_map_widget.dart';

import 'components/map_functions.dart';
import 'components/slider_widget.dart';
import 'components/small_profile_card_widget.dart';
import 'package:custom_marker/marker_icon.dart';

class HomeScreen extends StatefulWidget {
  List<InterestChipModel> interestList;
  List<InterestChipModel> fullInterestList;
  UserModel loggedInUser;
  double distance;
  Function(double radius) updateDistance;
  HomeScreen({
    super.key,
    required this.interestList,
    required this.fullInterestList,
    required this.updateDistance,
    required this.distance,
    required this.loggedInUser,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late BitmapDescriptor customIcon;
  late BitmapDescriptor eventIcon;
  var bearing = 0.0; //init bear
  var latitude = 33.6414895; //init lat
  var longitude = 73.0477357; //init long
  bool isAppReady = false; //check whether the app is ready
  bool _swipeFlag = true; //we allow swipe
  bool _onRadiusChanged = false; //we allow swipe

  String selectedCatID = "";
  double radius = 1;
  double zoomLevel = 15;
  String searchBoxTxt = "";
  String searchedQuery = "";
  int profileIndex = -1;

  List<BuddyModel> buddiesProfiles = [];
  late Set<Circle> circles;
  var disable = false;
  bool radiusChanged = false;

  String myMarkerID = "usermarker";
  String myCircleID = "usercircle";
  final Set<Polyline> _polylines = {};
  List<Marker> markersList = [];
  List<Marker> eventMarkersList =
      []; //it is loaded once and is updated whenever the showEvent is called

  final Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();
  DeviceLocation deviceLocation = DeviceLocation();
  List<GroupModel> eventList = [];
  @override
  void initState() {
    super.initState();

    // Add the observer.

    initializeApp();
  }

  Future<void> initializeApp() async {
    circles = {
      Circle(
        circleId: CircleId(myCircleID),
        center: LatLng(latitude, longitude),
        radius: radius * 1000,
      )
    };
    customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)), ImagesPaths.locationPin);
    eventIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)), ImagesPaths.eventLogo);
    //updateUser();

    deviceLocation.getLocation().listen((value) {
      if (mounted) {
        latitude = deviceLocation.getLat();
        longitude = deviceLocation.getLong();
        bearing = value.heading!;
        isAppReady = true;
        circles = {
          Circle(
            circleId: CircleId(myCircleID),
            center: LatLng(latitude, longitude),
            radius: radius * 1000,
          )
        };
        if (eventList.isEmpty) {
          _showEvents();
        }

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    deviceLocation.stopLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: (isAppReady)
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Stack(
                children: [
                  buildMapWidget(),
                  SafeArea(
                    child: Column(
                      children: [
                        //Builds upper Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: buildAppBar(),
                        ),

                        //Search bar
                        Visibility(
                          visible: _onRadiusChanged,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                              child: buildSlider(),
                            ),
                          ),
                        ),
                        //Categories
                        buildInterestsChips(),
                        //subcategories
                      ],
                    ),
                  ),
                  Visibility(
                    visible: buddiesProfiles.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: kIsWeb ? null : 250,
                          child: Swiper(
                            onIndexChanged: (index) {
                              //animate the camera to its location
                              setState(() {
                                profileIndex = index;
                                addWorkersMarker();
                              });
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return ProfileCardWidgetSmall(
                                  loggedInUser: widget.loggedInUser,
                                  interestList: getInterestList(buddiesProfiles[index]),
                                  buddyProfile: buddiesProfiles[index]);
                            },
                            control: const SwiperControl(
                                color: Colors.transparent, disableColor: Colors.transparent),
                            indicatorLayout:
                                _swipeFlag ? PageIndicatorLayout.SCALE : PageIndicatorLayout.NONE,
                            autoplay: true,
                            loop: _swipeFlag,
                            duration: 10,
                            itemCount: buddiesProfiles.length,
                            pagination: SwiperPagination(
                              margin: const EdgeInsets.all(0.0),
                              alignment: Alignment.bottomCenter,
                              builder: DotSwiperPaginationBuilder(
                                  color: Colors.grey, activeColor: kPrimaryColor),
                            ),
                            fade: 1.0,
                            viewportFraction: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
                strokeWidth: 1,
              ),
            ),
      onWillPop: () async {
        return true;
      },
    );
  }

  List<InterestChipModel> getInterestList(BuddyModel buddyProfile) {
    List<InterestChipModel> interestList = [];
    List<String> selectedInterestsList =
        buddyProfile.selectedInterests!.split(",").map((id) => id).toList();
    for (String id in selectedInterestsList) {
      for (InterestChipModel interest in widget.fullInterestList) {
        if (interest.catID == id) {
          if (interestList.isEmpty) {
            interest.isSelected = true;
          }
          interestList.add(interest);
          break; // Exit the inner loop once a match is found
        }
      }
    }
    return interestList;
  }

  buildInterestsChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 6,
          children: widget.interestList
              .map((interestChip) => InterestChipWidget(
                  backgroundColor: kWhiteColor,
                  selectedColor: kWhiteColor,
                  textColor: kBlackLight,
                  interestChipModel: interestChip,
                  interestSelected:
                      (String name, InterestChipModel interest, bool interestSelected) {
                    Log.log(interestSelected);

                    widget.interestList = widget.interestList.map((chip) {
                      final newChip = chip.copy(false);
                      return interestChip == newChip ? newChip.copy(interestSelected) : newChip;
                      /*    return interestChip == chip
                            ? chip.copy(interestSelected)
                            : chip;*/
                    }).toList();
                    if (interestSelected) {
                      Log.log(interest.catID);
                      markersList.clear();
                      searchBuddies(interest.catID);
                    } else {
                      onClear();
                    }
                  }))
              .toList(),
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "NEARBY BUDDY",
            style: TextStyle(fontSize: 18, color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          const Expanded(child: SizedBox()),
          ClipOval(
            child: Material(
              color: kWhiteColor,
              child: InkWell(
                splashColor: kPrimaryTransparent, // Splash color
                onTap: () {
                  setState(() {
                    _onRadiusChanged = !_onRadiusChanged;
                  });
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      IconPaths.radiusInfoIcon, // Replace with your SVG file path
                      width: 15,
                      height: 15,
                      color: const Color(0xFF949AB9),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  buildSlider() {
    return SliderWidget(
        radius: widget.distance,
        onChanged: (double value) async {
          radius = value;
          radiusChanged = true;

          zoomLevel = MapFunctions.zoomOut(radius, zoomLevel) ?? 16.0;

          //circle is blue circle around our current lat and long

          // addCircleToMap();
          bool result = _controller.isCompleted;
          if (result) {
            final controllers = await _controller.future;

            controllers.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(latitude, longitude), zoom: zoomLevel),
              ),
            );
          }
          setState(() {
            widget.updateDistance(radius);
          });
        },
        onClosed: () {
          setState(() {
            radiusChanged = false;
            searchBuddies("");
          });
        });
  }

  buildMapWidget() {
    return GoogleMapWidget(
      userLat: latitude,
      userLong: longitude,
      profileIndex: profileIndex,
      //swipe index workerprofile card index =0
      radius: radius,
      //slider
      zoomlevel: zoomLevel,
      bearing: bearing,
      //
      buddyProfileList: buddiesProfiles,
      //empty hoti api call-> fill up
      customIcon: customIcon,
      //APNI location ka hai
      controller: _controller,
      //Map ka controller
      // circles: addCircleToMap(),
      //
      markersList: markersList,
      polylines: _polylines,
    );
  }

  addCircleToMap() {
    //circle is blue circle around our current lat and long

    circles.clear(); //clear the set before adding to avoid repeated values
    circles.add(Circle(
      circleId: CircleId(myCircleID),
      center: LatLng(latitude, longitude),
      fillColor: kPrimaryTransparent,
      strokeWidth: 2,
      strokeColor: kPrimaryLight,
      radius: radius.toDouble() * 100,
    ));

    return circles;
  }

  _showEvents() async {
    eventList = await ApiService().showEvents(
        radius: widget.distance.toString(), location: '${this.latitude},${this.longitude}');
    //add markers realted to each event and then we save the events in a OG list
    // the list saves the data show that wehn all the markers are removed , we can easily add them back
    for (GroupModel event in eventList) {
      LatLng eventLatLng = LatLng(event.latitude ?? 0.0, event.longitude ?? 0.0);
      Marker eventMarker = Marker(
        position: eventLatLng,
        onTap: () async {

          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChannelViewScreen(
                      loggedInUser: widget.loggedInUser,groupModel: event,
                    )),
          );
        },
        markerId: MarkerId(event.groupName ?? ""),
        anchor: const Offset(0.5, 0.5),
        icon: eventIcon,
        infoWindow: InfoWindow(title: event.groupName),
      );
      eventMarkersList.add(eventMarker);
    }
    Log.log('eventMarkerList: ${eventMarkersList.length}');

    setState(() {
      Log.log('EventList: ${eventList.toString()}');
      markersList.addAll(eventMarkersList);
      Log.log('markersList: ${markersList.length}');
    });
  }

  getDirections(LatLng startLocation, LatLng endLocation) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Utils().googleAPIKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _createPathToBuddy(polylineCoordinates);
  }

  _createPathToBuddy(List<LatLng> polylineCoordinates) {
    _polylines.clear();
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: kPrimaryColor,
      points: polylineCoordinates,
      width: 4,
    );
    _polylines.add(polyline);
  }

  searchBuddies(String catID) async {
    CustomDialogs.showLoadingAnimation(context);
    buddiesProfiles = await ApiService().searchBuddies(
        username: widget.loggedInUser.username,
        searchString: "",
        radius: radius.toString(),
        lat: latitude.toString(),
        gender: widget.loggedInUser.gender,
        long: longitude.toString(),
        category_id: catID);

    _swipeFlag = buddiesProfiles.isEmpty;

    if (buddiesProfiles.isNotEmpty) {
      profileIndex = 0;
      addWorkersMarker();
      Navigator.of(context).pop();
    } else {
      CustomSnackBar.showWarnSnackBar(context, "Cannot find matching profile nearby!");
      Navigator.of(context).pop();
    }

    setState(() {
      Log.log(buddiesProfiles);
    });
  }

  Future<void> addWorkersMarker() async {
    // CustomDialogs.showLoadingAnimation(context);
    LatLng workerLatLng = LatLng(double.parse(buddiesProfiles[profileIndex].latitude ?? "0.0"),
        double.parse(buddiesProfiles[profileIndex].longitude ?? "0.0"));
    Marker newMarker = Marker(
      position: workerLatLng,
      onTap: () async {
        BuddyModel bm = buddiesProfiles[profileIndex];
        CustomDialogs.showLoadingAnimation(context);
        List<ImageModel> imagesList = await getImages(bm.username);
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                    buddyData: bm,
                    loggedInUser: widget.loggedInUser,
                    viewAsBuddyProfile: true,
                    imagesList: imagesList,
                    myInterestList: widget.interestList,
                  )),
        );
      },
      markerId: MarkerId(buddiesProfiles[profileIndex].name ?? ""),
      anchor: const Offset(0.5, 0.5),
      icon: await MarkerIcon.downloadResizePictureCircle(
          '${ApiUrls.usersImageUrl}/${buddiesProfiles[profileIndex].image}',
          size: 150,
          addBorder: true,
          borderColor: kPrimaryColor,
          borderSize: 15),
      infoWindow: InfoWindow(title: buddiesProfiles[profileIndex].name),
    );
    markersList.add(newMarker);
    // await getDirections(
    //     LatLng(latitude, longitude),
    //     LatLng(double.parse(buddiesProfiles[profileIndex].latitude ?? "0.0"),
    //         double.parse(buddiesProfiles[profileIndex].longitude ?? "0.0")));
    final controllers = await _controller.future;
    controllers.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: workerLatLng, zoom: zoomLevel),
      ),
    );
    // Navigator.of(context).pop();

    setState(() {
      zoomLevel = MapFunctions.zoomIn(radius, zoomLevel) ?? 16.0;
    });
  }

  onClear() async {
    selectedCatID = "";
    profileIndex = -1;

    markersList = [];
    buddiesProfiles = [];
    _polylines.clear();

    Marker newMarker = Marker(
        markerId: MarkerId(myMarkerID),
        position: LatLng(latitude, longitude),
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(title: 'You are here!'),
        icon: customIcon);

    markersList.add(newMarker);
    markersList.addAll(eventMarkersList);

    final controllers = await _controller.future;
    zoomLevel = MapFunctions.zoomOut(radius, zoomLevel) ?? 16.0;
    setState(() {
      controllers.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latitude, longitude), zoom: zoomLevel),
        ),
      );
    });
  }

  Future<List<ImageModel>> getImages(String? username) async {
    List<ImageModel> imagesList = await ApiService().getImages(username: username);
    return imagesList;
  }
}
