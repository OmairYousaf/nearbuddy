import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

import 'package:nearby_buddy_app/screens/main_screen/sub_screens/home/components/map_functions.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/userProfile/user_profile_screen.dart';
import '../../../components/custom_dialogs.dart';
import '../../../components/custom_snack_bars.dart';
import '../../../components/interest_chip_widget.dart';
import '../../../constants/apis_urls.dart';
import '../../../constants/icon_paths.dart';
import '../../../helper/utils.dart';
import '../../../models/buddy_model.dart';
import '../../../models/image_model.dart';
import '../../../models/interest_chip_model.dart';
import '../../../models/user_model.dart';
import '../../../routes/api_service.dart';
import 'package:custom_marker/marker_icon.dart';

import '../sub_screens/home/components/google_map_widget.dart';
import '../sub_screens/home/components/slider_widget.dart';
import '../sub_screens/home/components/small_profile_card_widget.dart';

class HomeScreenWeb extends StatefulWidget {
  List<InterestChipModel> interestList;
  List<InterestChipModel> fullInterestList;
  double longitude;
  double latitude;
  UserModel loggedInUser;
  BitmapDescriptor customIcon;
  double distance;
  Function(double radius) updateDistance;

  HomeScreenWeb({
    super.key,
    required this.interestList,
    required this.fullInterestList,
    required this.longitude,
    required this.latitude,
    required this.loggedInUser,
    required this.distance,
    required this.updateDistance,
    required this.customIcon,
  });

  @override
  State<HomeScreenWeb> createState() => _HomeScreenWebState();
}

class _HomeScreenWebState extends State<HomeScreenWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var bearing = 0.0; //init bear
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

  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();

    // Add the observer.

    initializeApp();
  }

  Future<void> initializeApp() async {
    Log.log('This is the new radius ${widget.distance} and $zoomLevel');
    circles = {
      Circle(
        circleId: CircleId(myCircleID),
        center: LatLng(widget.latitude, widget.longitude),
        radius: radius * 1000,
      )
    };
    if (mounted) {
      isAppReady = true;
      setState(() {
        zoomLevel = MapFunctions.zoomOut(widget.distance, zoomLevel) ?? 16.0;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (isAppReady)
        ? /*Stack(
          children: [
            buildMapWidget(),
            Column(
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
                      padding:
                      const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      child: buildSlider(),
                    ),
                  ),
                ),
                //Categories
                buildInterestsChips(),
                //subcategories
              ],
            ),
            Visibility(
              visible: buddiesProfiles.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 200,
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
                            interestList:
                            getInterestList(buddiesProfiles[index]),
                            buddyProfile: buddiesProfiles[index]);
                      },
                      control: const SwiperControl(
                          color: Colors.transparent,
                          disableColor: Colors.transparent),
                      indicatorLayout: _swipeFlag
                          ? PageIndicatorLayout.SCALE
                          : PageIndicatorLayout.NONE,
                      autoplay: true,
                      loop: _swipeFlag,
                      duration: 10,
                      itemCount: buddiesProfiles.length,
                      pagination: SwiperPagination(
                        margin: EdgeInsets.all(0.0),
                        alignment: Alignment.bottomCenter,
                        builder: DotSwiperPaginationBuilder(
                            color: Colors.grey,
                            activeColor: kPrimaryColor),
                      ),
                      fade: 1.0,
                      viewportFraction: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )*/
        Stack(
            children: [
              _buildMapWidget(),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Builds upper Buttons
                      _buildAppBar(),

                      //Search bar
                      Visibility(
                        visible: _onRadiusChanged,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _buildSlider(),
                        ),
                      ),
                      //Categories
                      _buildInterestsChips(),
                      //subcategories
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: buddiesProfiles.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      height: 200,
                      child: Swiper(
                        onIndexChanged: (index) {},
                        itemBuilder: (BuildContext context, int index) {
                          return ProfileCardWidgetSmall(
                              loggedInUser: widget.loggedInUser,
                              interestList:
                                  getInterestList(buddiesProfiles[index]),
                              buddyProfile: buddiesProfiles[index]);
                        },
                        control: const SwiperControl(
                            color: Colors.transparent,
                            disableColor: Colors.transparent),
                        indicatorLayout: _swipeFlag
                            ? PageIndicatorLayout.SCALE
                            : PageIndicatorLayout.NONE,
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
                        viewportFraction: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(
              color: kPrimaryColor,
              strokeWidth: 1,
            ),
          );
  }

  List<InterestChipModel> getInterestList(BuddyModel buddyProfile) {
    List<InterestChipModel> interestList = [];
    List<String> selectedInterestsList =
        buddyProfile.selectedInterests!.split(",").map((id) => id).toList();
    for (String id in selectedInterestsList) {
      for (InterestChipModel interest in widget.fullInterestList) {
        if (interest.catID == id) {
          interestList.add(interest);
          break; // Exit the inner loop once a match is found
        }
      }
    }
    return interestList;
  }

  _buildInterestsChips() {
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
                  interestSelected: (String name, InterestChipModel interest,
                      bool interestSelected) {
                    Log.log(interestSelected);

                    widget.interestList = widget.interestList.map((chip) {
                      final newChip = chip.copy(false);
                      return interestChip == newChip
                          ? newChip.copy(interestSelected)
                          : newChip;
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

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "NEARBY BUDDY",
          style: TextStyle(
              fontSize: 18, color: kPrimaryColor, fontWeight: FontWeight.bold),
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
    );
  }

  _buildSlider() {
    Log.log('Rslider');
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
                CameraPosition(
                    target: LatLng(widget.latitude, widget.longitude),
                    zoom: zoomLevel),
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

  _buildMapWidget() {
    return GoogleMapWidget(
      userLat: widget.latitude,
      userLong: widget.longitude,
      profileIndex: profileIndex,
      //swipe index workerprofile card index =0
      radius: radius,
      //slider
      zoomlevel: zoomLevel,
      bearing: bearing,
      //
      buddyProfileList: buddiesProfiles,
      //empty hoti api call-> fill up
      customIcon: widget.customIcon,
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
      center: LatLng(widget.latitude, widget.longitude),
      fillColor: kPrimaryTransparent,
      strokeWidth: 2,
      strokeColor: kPrimaryLight,
      radius: radius.toDouble() * 100,
    ));

    return circles;
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
        lat: widget.latitude.toString(),
        gender: '',
        long: widget.longitude.toString(),
        category_id: catID);

    _swipeFlag = buddiesProfiles.isEmpty;

    if (buddiesProfiles.isNotEmpty) {
      profileIndex = 0;
      addWorkersMarker();
      Navigator.of(context).pop();
    } else {
      CustomSnackBar.showWarnSnackBar(
          context, "Cannot find matching profile nearby!");
      Navigator.of(context).pop();
    }

    setState(() {
      Log.log(buddiesProfiles);
    });
  }

  Future<void> addWorkersMarker() async {
    // CustomDialogs.showLoadingAnimation(context);
    LatLng workerLatLng = LatLng(
        double.parse(buddiesProfiles[profileIndex].latitude ?? "0.0"),
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
          size: 50,
          addBorder: true,
          borderColor: kPrimaryColor,
          borderSize: 5),
      infoWindow: InfoWindow(title: buddiesProfiles[profileIndex].name),
    );
    markersList.add(newMarker);
    // await getDirections(
    //     LatLng(widget.latitude, widget.longitude),
    //     LatLng(double.parse(buddiesProfiles[profileIndex].widget.latitude ?? "0.0"),
    //         double.parse(buddiesProfiles[profileIndex].widget.longitude ?? "0.0")));

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
        position: LatLng(widget.latitude, widget.longitude),
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(title: 'You are here!'),
        icon: widget.customIcon);

    markersList.add(newMarker);

    final controllers = await _controller.future;
    zoomLevel = MapFunctions.zoomOut(radius, zoomLevel) ?? 16.0;
    setState(() {
      controllers.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: zoomLevel),
        ),
      );
    });
  }

  Future<List<ImageModel>> getImages(String? username) async {
    List<ImageModel> imagesList =
        await ApiService().getImages(username: username);
    return imagesList;
  }
}
