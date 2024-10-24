import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_address_from_latlng/flutter_address_from_latlng.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/models/buddy_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';

import '../../../../../helper/device_location.dart';
import '../../../../../constants/apis_urls.dart';
import '../../../../../helper/utils.dart';
import '../../../../../responsive.dart';
import '../../../../../models/group_model.dart';
import '../../../../registration/components/small_map_component.dart';
import 'components/add_member_group_screen.dart';
import 'components/edit_group_details_screen.dart';
import 'channel_chat_screen.dart';
import 'package:geolocator/geolocator.dart';

class CreateGroupScreen extends StatefulWidget {
  UserModel loggedInUser;
  bool isEditMode;
  GroupModel? groupModel;
  CreateGroupScreen(
      {Key? key, required this.loggedInUser, this.isEditMode = false, this.groupModel})
      : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupDetailsTxtCntrl = TextEditingController();
  final StreamController<BuddyModel> _userController = StreamController.broadcast();
  List<BuddyModel> selectedUsers = [];
  List<BuddyModel> usersFound = [];
  File? _imageFile;
  bool isFullNameTrue = false;
  bool isDescriptionTrue = false;
  bool searchFlag = false;
  bool isLandMode = false;
  double newLat = 43.2994;
  double newLong = 74.2179;
  bool _permissionGranted = false;
  bool isPrivate = false;

  late GoogleMapController _controller; //to control the camera of the google map
  final markers = <Marker>{}; //a set of markers is needed to pin the location on map
  MarkerId markerId =
      const MarkerId("myLocationMarker"); //this marker is added to the previous markers set
  LatLng myLatLng = const LatLng(43.2994, 74.2179); //the init lat and lng
  String addressTxt = ""; //user's address
  DeviceLocation deviceLocation = DeviceLocation();
  final PermissionStatus _status = PermissionStatus.denied;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.groupModel != null) {
      _fullnameController.text = widget.groupModel!.groupName ?? "";
      _groupDetailsTxtCntrl.text = widget.groupModel!.groupDescription ?? "";
      isFullNameTrue = true;
      isDescriptionTrue = true;
      isPrivate=widget.groupModel!.isPrivate;
    }
    if (kIsWeb) {
      _getLocation();
    } else {
      setData();
    }
  }

  @override
  Widget build(BuildContext context) {
    isLandMode = (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: kWhiteColor,
        foregroundColor: const Color(0xFF575757),
        leading: isLandMode
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop();
                },
              ),
        title: Text(
          (widget.isEditMode) ? 'Edit Event' : "Create an Event",
          style: TextStyle(color: kPurple, fontWeight: FontWeight.w500),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(padding: const EdgeInsets.all(15.0), child: _buildGroupDetailsScreen()),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      _imageFile = await Utils().getImageFromCamera();
    } else {
      _imageFile = await Utils().getImageFromGallery();
    }

    if (_imageFile != null) {
      setState(() {});
    }
  }

  Widget _buildGroupDetailsScreen() {
    return EditGroupDetailsScreen(
      filled: isFullNameTrue,
      filled2: isDescriptionTrue,
      filled3: addressTxt.isNotEmpty,
      imageFile: _imageFile,
      markers: markers,
      myLatitude: newLat,
      myLongitude: newLat,
      isPrivate: isPrivate,
      onSwitchChanged: (bool value) {
        setState(() {
          isPrivate = value;
        });
      },
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      updatePosition: (CameraPosition position) {
        WidgetsFlutterBinding.ensureInitialized();
        if (!mounted) {
          setState(() {
            markers.add(Marker(markerId: markerId, position: position.target));
            myLatLng = position.target;
          });
        }
      },
      fullnameController: _fullnameController,
      groupDetailsTxtCntrl: _groupDetailsTxtCntrl,
      addressTxt: addressTxt,
      onLocationPicked: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        LatLng result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapSmallWidget(newLat, newLong, true),
          ),
        );
        newLat = double.parse(result.latitude.toStringAsFixed(6));
        newLong = double.parse(result.longitude.toStringAsFixed(6));
        getAddressFromLatLong(newLat, newLong);
        setState(() {
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(newLat, newLong), zoom: 20),
            ),
          );
        });
      },
      onChangedTitle: (value) {
        setState(() {
          isFullNameTrue = value.isNotEmpty;
        });
      },
      onChangeDesp: (value) {
        setState(() {
          isDescriptionTrue = value.isNotEmpty;
        });
      },
      onComplete: () {
        if (_groupDetailsTxtCntrl.text.isEmpty || _fullnameController.text.isEmpty) {
          CustomSnackBar.showErrorSnackBar(context, "Please add event title and about");
        } else {
          if (widget.isEditMode) {
            updateGroup();
          } else {
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => AddMemberGroupScreen(
                          isEditMode: widget.isEditMode,
                          userLoggedIn: widget.loggedInUser,
                          onNextPressed: (selectedUsers) {
                            setState(() {
                              this.selectedUsers = selectedUsers;
                              createGroup();
                            });
                          })));
            });
          }
        }
      },
      onImageChange: () {
        _pickImage(ImageSource.gallery);
      },
      urlImage:
          (widget.isEditMode) ? "${ApiUrls.groupsImageUrl}/${widget.groupModel?.groupIcon}" : '',
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

  createGroup() async {
    CustomDialogs.showLoadingAnimation(context);

    selectedUsers.add(BuddyModel(
        username: widget.loggedInUser.username,
        image: widget.loggedInUser.image)); //adding the user?

    GroupModel? groupModel = await ApiService().createGroupModel(
        groupAdmin: widget.loggedInUser.username,
        groupIcon: _imageFile,
        groupName: _fullnameController.text,
        groupDescription: _groupDetailsTxtCntrl.text,
        location: "$newLat,$newLong",
        isPrivate: isPrivate ? "1" : "0",
        groupMembers: selectedUsers);

    if (groupModel == null) {
      Navigator.of(context).pop();
      CustomSnackBar.showErrorSnackBar(context, "Error while creating a group");
    } else {
      bool result = false;
      if (_imageFile != null) {
        result =
            await ApiService().uploadImageToServer(_imageFile!, groupModel.groupIcon!, 'groups');
      }

      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChannelChatScreen(
            userLoggedIn: widget.loggedInUser,
            groupChatList: groupModel,
            isGroupNewChatlist: true,
            updateChatDetails: (GroupModel groupModel) {},
          ),
        ),
      );
    }
  }

  updateGroup() async {
    CustomDialogs.showLoadingAnimation(context);
    String groupIconName = '';
    if (_imageFile != null) {
      groupIconName = ApiService().getUniqueName(_imageFile!);
      await ApiService().uploadImageToServer(_imageFile!, groupIconName, 'groups');
    }
    bool result = await ApiService().updateGroup(
        groupId: widget.groupModel!.id,
        groupAdmin: widget.loggedInUser.username,
        groupIcon: groupIconName.isNotEmpty ? groupIconName : widget.groupModel!.groupIcon ?? "",
        groupName: _fullnameController.text,
        location: "$newLat,$newLong",
        isPrivate: widget.groupModel!.isPrivate ? '1' : '0',
        groupDescription: _groupDetailsTxtCntrl.text,
        groupMembers:
            widget.groupModel!.groupMemberList.map((member) => member.username).join(', '));

    if (!result) {
      Navigator.of(context).pop();
      CustomSnackBar.showErrorSnackBar(context, "Error while updating the event");
    } else {
      Navigator.of(context).pop();
      GroupModel groupModel = GroupModel(
        id: widget.groupModel!.id,
        groupAdmin: widget.groupModel!.groupAdmin,
        groupIcon: groupIconName.isNotEmpty ? groupIconName : widget.groupModel!.groupIcon ?? "",
        groupName: _fullnameController.text,
        groupDescription: _groupDetailsTxtCntrl.text,
        location: "$newLat,$newLong",
        latitude: _parseLocation( "$newLat,$newLong").latitude,
        longitude: _parseLocation( "$newLat,$newLong").longitude,
        isPrivate: isPrivate,

      );

      groupModel.groupMemberList = widget.groupModel!.groupMemberList;

      Navigator.of(context).pop(groupModel);
    }
  }
  LatLng _parseLocation(String location){
    List<String> coordinates = location!.split(',');
    if (coordinates.length == 2) {
     double latitude = double.parse(coordinates[0]);
     double longitude = double.parse(coordinates[1]);
      LatLng latLng=LatLng(latitude, longitude);
      return latLng;

    } else {
      print('Invalid location format');
      return LatLng(0, 0);
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
    if(widget.isEditMode){
      newLat = widget.groupModel!.latitude;
      newLong = widget.groupModel!.longitude;
      getAddressFromLatLong(widget.groupModel!.latitude, widget.groupModel!.longitude);
    }
    setState(() {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(newLat, newLong), zoom: 20),
        ),
      );

      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
