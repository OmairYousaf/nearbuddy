import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/helper/device_location.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/constants/image_paths.dart';
import 'package:nearby_buddy_app/models/chat_model.dart';
import 'package:nearby_buddy_app/models/request_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../../../components/custom_dialogs.dart';
import '../../../../components/interest_chip_widget.dart';
import '../../../../components/shimmer_widget.dart';
import '../../../../constants/apis_urls.dart';
import '../../../../helper/utils.dart';
import '../../../../models/buddy_model.dart';
import '../../../../models/image_model.dart';
import '../../../../models/interest_chip_model.dart';
import '../../../../models/user_model.dart';
import '../../../../responsive.dart';
import '../../../../routes/api_service.dart';
import '../chat/chatScreen/chat_screen.dart';
import '../userProfile/user_profile_screen.dart';

class ConnectScreen extends StatefulWidget {
  UserModel userModel;
  double latitude;
  double longitude;
  double distance;
  List<InterestChipModel> fullInterestList;
  Function(double radius) updateDistance;

  ConnectScreen({
    Key? key,
    required this.userModel,
    required this.fullInterestList,
    required this.updateDistance,
    required this.distance,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final bool _isNavigationOpen = false;
  List<InterestChipModel> sideInterestList = [];
  double distance = 100;
  int? switchValue;
  String gender = '';
  String _catID = '-1';
  bool isFilteredSearch = false;
  bool reset = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  RangeValues _age = const RangeValues(18, 20);
  List<BuddyModel> buddiesProfiles = [];
  final TextEditingController _messgaeController = TextEditingController();
  DeviceLocation deviceLocation = DeviceLocation();
  List<String> messagesSentProfile = [];
  Map<int, String> interestUrls = {};
  final bool _swipeFlag = false;
  int index = 0;
  final bool _isDone = false;
  final PageController _pageController = PageController(
    initialPage: 1,
    viewportFraction: 0.7,
  );
  final SwiperController _swiperController = SwiperController();
  final StreamController _controller = StreamController();
  bool isLandMode=false;

  @override
  void initState() {

    super.initState();
    isLandMode=(kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _swiperController.addListener(() {});
    //create sidenavigation list;
    copy();
    // Call the getData method when the widget is initialized
    searchBuddies();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.log('Hello');
    return Stack(
      children: [
        (buddiesProfiles.isNotEmpty)
            ? _buildBackDrop()
            : const SizedBox(),
       _buildBackDropOpacity(),
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          key: _scaffoldKey, // Assign the scaffold key
          appBar: AppBar(
            title: Text(
              "Connects",
              style: TextStyle(fontSize: 18, color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: kPrimaryColor,
            automaticallyImplyLeading: false,
            actions: [
             _buildSideNavBtn()
            ],
          ),
          endDrawer: Drawer(child: _buildSideNav()),
          body: _buildForegroundWidget(),
        )
      ],
    );
  }
  _buildForegroundWidget() {
    return StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        Log.log("The state is ${snapshot.connectionState}");
        if (snapshot.hasData) {
          // Display the data in a widget
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: _buildIPgViewer()),
            ],
          );
        } else if (snapshot.hasError) {
          // Handle the error
          return _buildNoProfiles();
        } else {
          // Show a loading indicator while the data is being fetched
          return _buildLoadingProfiles();
        }
      },
    );
  }

  _buildBackDropOpacity() {
    return  Positioned.fill(
      child: Opacity(
        opacity: 0.7, // Set opacity level here
        child: Container(
          color: Colors.white60, // Set color here
        ),
      ),
    );
  }

  _buildBackDrop() {
    return Positioned.fill(
      child: CachedNetworkImage(

        imageUrl: _getFirstInterest(index),
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          fit:isLandMode?BoxFit.fitWidth:BoxFit.cover,
          repeat: ImageRepeat.repeat,

        ),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            child: const Image(
              image: AssetImage(ImagesPaths.placeholderImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          backgroundColor: kGrey,
          radius: 30,
          backgroundImage: const AssetImage(ImagesPaths.placeholderImage),
        ),
      ),
    );
  }





  _buildIPgViewer() {
    return Swiper(
      onIndexChanged: (index) {
        //animate the camera to its location
        this.index = index;
        Log.log(this.index);

        // check if page is a whole number
        setState(() {});
      },
      control: SwiperControl(
          color: (isLandMode) ? Colors.white : Colors.transparent,
          disableColor: (isLandMode) ? Colors.white : Colors.transparent),
      indicatorLayout:
          _swipeFlag ? PageIndicatorLayout.SCALE : PageIndicatorLayout.NONE,
      autoplay: false,
      loop: _swipeFlag,
      scrollDirection: Axis.horizontal,
      controller: _swiperController,
      physics: const BouncingScrollPhysics(),
      itemCount: buddiesProfiles.length,
      pagination: SwiperPagination(
        margin: const EdgeInsets.all(10.0),
        alignment: Alignment.bottomCenter,
        builder: DotSwiperPaginationBuilder(
            size: 6.0, color: Colors.grey, activeColor: kPrimaryColor),
      ),
      fade: 1.0,
      viewportFraction: isLandMode ? 0.9 : 0.8,
      itemBuilder: (BuildContext context, int index) {
        return (isLandMode) ? _buildWebView() : _buildMobileView();
      },
    );
  }

  _buildMobileView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProfileNameWdgt(),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: 250.0,
          height: 250.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 5.0,
            ),
          ),
          child: _buildImageOvalWgt(),
        ),
        const SizedBox(
          height: 20,
        ),
        _buildBioBoxWgt(),
      ],
    );
  }

  _buildWebView() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: _buildImageOvalWgt(),
              ),
              const SizedBox(
                height: 10,
              ),
              Flexible(
                child: _buildConnectBtn(),
              ),
            ],
          ),
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileNameWdgt(),
            const SizedBox(
              height: 10,
            ),
            _buildBioBoxWgt(),
          ],
        )),
      ],
    );
  }

  _buildProfileNameWdgt() {
    return Text(
      (buddiesProfiles.isEmpty) ? '' : '${buddiesProfiles[index].name}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: isLandMode ? kPrimaryColor : Colors.white,
      ),
    );
  }

  _buildImageOvalWgt() {
    return ClipOval(
        child: InkWell(
      onTap: () async {
        CustomDialogs.showLoadingAnimation(context);
        List<ImageModel> imagesList =
            await getImages(buddiesProfiles[index].username);
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                    buddyData: buddiesProfiles[index],
                    loggedInUser: widget.userModel,
                    viewAsBuddyProfile: true,
                    imagesList: imagesList,
                    onRequestSent: () {
                      buddiesProfiles[index].requestStatus =
                          RequestStatus.Pending;
                      setState(() {});
                    },
                    myInterestList: _getInterestList(buddiesProfiles[index]),
                  )),
        );
      },
      child: CachedNetworkImage(
        imageUrl: '${ApiUrls.usersImageUrl}/${buddiesProfiles[index].image}',
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundColor: kGrey,
          radius: 200,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: CircleAvatar(
            radius: 24.0,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: Container(
                color: Colors.white,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          backgroundColor: kGrey,
          radius: 30,
          backgroundImage: const AssetImage(ImagesPaths.placeholderImage),
        ),
      ),
    ));
  }

  _buildBioBoxWgt() {
    return Container(
      margin: const EdgeInsets.only(right: 4, left: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      height: isLandMode ? null : 250,
      width: isLandMode ? null : 300,
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Interests",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              isLandMode?_buildInterestsChips(
                  interestsList: _getInterestList(buddiesProfiles[index]),
                  onInterestSelected: (String selectedCategoryName,
                      InterestChipModel categoryChipModel, bool isSelected) {}):SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildInterestsChips(
                    interestsList: _getInterestList(buddiesProfiles[index]),
                    onInterestSelected: (String selectedCategoryName,
                        InterestChipModel categoryChipModel, bool isSelected) {}),
              ),
              Visibility(visible:isLandMode,child: const SizedBox(height: 10,)),
              Text(
                "About",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                "${buddiesProfiles[index].bio}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.8),
              ),
              const SizedBox(height: 10),
              Visibility(child: _buildConnectBtn(),visible: !isLandMode,)
            ],
          )),
    );
  }

  _buildConnectBtn(){
    return  ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: (buddiesProfiles[index].requestStatus ==
              RequestStatus.Pending ||
              buddiesProfiles[index].requestStatus == RequestStatus.Accepted)
              ? kGreyDark
              : kPrimaryColor,

          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
      onPressed: () {
        if ((buddiesProfiles[index].requestStatus == RequestStatus.Accepted)) {
          //then go to chatscreen
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatList: ChatModel(
                    id: buddiesProfiles[index].chatId ?? "-1",
                    user1: buddiesProfiles[index].username ?? "",
                    user2: widget.userModel.username,
                    profileImage: buddiesProfiles[index].image ?? "",
                    fullName: buddiesProfiles[index].name ?? "",
                  ),
                  userLoggedIn: widget.userModel,
                  isNewChatlist: false,
                )),
          );
        }
        else if ((buddiesProfiles[index].requestStatus ==
            RequestStatus.NotSent ||  buddiesProfiles[index].requestStatus == RequestStatus.Cancel)) {
          CustomDialogs.showTextDialog(
              context: context,
              message: "Send a Message",
              sendTextController: _messgaeController,
              buttonLabel1: "SEND",
              callbackMethod1: () => _sendRequest(),
              buttonLabel2: "CANCEL",
              callbackMethod2: () {
                Navigator.of(context).pop();
              });
        } else if (buddiesProfiles[index].requestStatus ==
            RequestStatus.Pending) {
          return;
        }
      },
      icon: Icon((buddiesProfiles[index].requestStatus != RequestStatus.NotSent)
          ? FontAwesomeIcons.check
          : FontAwesomeIcons.handshake),
      label: Text(
        (buddiesProfiles[index].requestStatus == RequestStatus.NotSent ||
            buddiesProfiles[index].requestStatus == RequestStatus.Declined ||
            buddiesProfiles[index].requestStatus == RequestStatus.Cancel)
            ? " Connect"
            : (buddiesProfiles[index].requestStatus == RequestStatus.Pending)
            ? " Pending Request"
            : " Lets Chat",
      ),
    );
  }


  _buildSideNavBtn() {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipOval(
        child: Material(
          color: kWhiteColor,
          child: InkWell(
            splashColor: kPrimaryTransparent, // Splash color
            onTap: () => _toggleNavigation(),
            child: const SizedBox(
                width: 40,
                height: 30,
                child: Icon(
                  Icons.filter_list_outlined,
                  size: 24,
                  color: Color(0xFF949AB9),
                )),
          ),
        ),
      ),
    );
  }

  _buildNoProfiles() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.sadCry,
                  color: kPrimaryColor,
                  size: 32,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "No profiles matched!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () => resetFilters(),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                  child: const Text("Reset Filters or Retry"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildLoadingProfiles() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Center(child: ShimmerWidget.circular(width: 200, height: 200))),
      ],
    );
  }


  _buildSideNav() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        width: 300,
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Text(
                      "Filter",
                      style: TextStyle(fontSize: 18),
                    )),
                    IconButton(
                        onPressed: resetFilters,
                        icon: Icon(
                          Icons.refresh,
                          color: kPrimaryColor,
                        )),
                    IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState!.closeEndDrawer();
                        },
                        icon: Icon(
                          Icons.close,
                          color: kPrimaryColor,
                        ))
                  ],
                ),
                Divider(
                  height: 1,
                  color: kGreyDark,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text("Distance"),
                _buildSlider(true),
                const SizedBox(
                  height: 20,
                ),
                const Text("Age"),
                _buildSlider(false),
                const SizedBox(
                  height: 20,
                ),
                const Text("Gender"),
                const SizedBox(
                  height: 10,
                ),
                ToggleSwitch(
                  minWidth: 129.0,
                  initialLabelIndex: switchValue,
                  cornerRadius: 5.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: const Color(0xFFF1F1F1),
                  inactiveFgColor: Colors.grey,
                  totalSwitches: 2,
                  labels: const ['Male', 'Female'],
                  icons: const [FontAwesomeIcons.mars, FontAwesomeIcons.venus],
                  activeBgColors: [
                    [kPrimaryColor],
                    [kPrimaryColor]
                  ],
                  onToggle: (index) {
                    if (index == 0) {
                      switchValue = 0;
                      gender = 'Male';
                    } else {
                      switchValue = 1;
                      gender = 'Female';
                    }

                    print('switched to: $index');
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text("Interests"),
                const SizedBox(
                  height: 10,
                ),
                _buildInterestsChips(
                    interestsList: sideInterestList,
                    onInterestSelected: (String selectedCategoryName,
                        InterestChipModel interestChip, bool interestSelected) {
                      setState(() {
                        if (interestSelected) {
                          _catID = interestChip.catID;
                        } else {
                          _catID = '-1';
                        }
                        sideInterestList = sideInterestList.map((chip) {
                          final newChip = chip.copy(false);
                          return interestChip == newChip ? newChip.copy(interestSelected) : newChip;
                          /*    return interestChip == chip
                          ? chip.copy(interestSelected)
                          : chip;*/
                        }).toList();
                      });
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }





  _buildInterestsChips(
      {required List<InterestChipModel> interestsList,
        required Function(String, InterestChipModel, bool) onInterestSelected}) {
    return Wrap(
      spacing: 6,
      runSpacing: isLandMode?5:0,
      children: interestsList
          .map((interestChip) => InterestChipWidget(
          backgroundColor: Colors.grey.shade100,
          selectedColor: kWhiteColor,
          textColor: kBlackLight,
          fontSize: 13,
          interestChipModel: interestChip,
          interestSelected: onInterestSelected))
          .toList(),
    );
  }

  void _sendRequest() async {
    if (_messgaeController.text.isNotEmpty) {
      CustomDialogs.showLoadingAnimation(context);
      bool result = await ApiService().sendRequest(
        sender: widget.userModel.username,
        receiver: buddiesProfiles[index].username ?? "",
        msg: _messgaeController.text.trim(),
      );
      if (result) {
        _messgaeController.text = "";
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        setState(() {
          buddiesProfiles[index].requestStatus = RequestStatus.Pending;
        });
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, "Connection Error");
      }
    } else {
      CustomSnackBar.showErrorSnackBar(context, "No Message Added");
    }
  }
  Future<void> _toggleNavigation() async {
    _scaffoldKey.currentState!.openEndDrawer();
    _controller.add(null);
    // Call the getData method to fetch new data
    await searchBuddies();
  }

  _buildSlider(bool basicSlider) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
        overlayColor: Colors.purple.withOpacity(0.2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
        showValueIndicator: ShowValueIndicator.always,
        valueIndicatorColor: Colors.purple, // color of the value indicator
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: (basicSlider)
          ? Slider(
        value: widget.distance,
        min: 1,
        max: 100,
        label: '${widget.distance.round().toString()} km',
        onChanged: (value) {
          setState(() {
            widget.distance = value;
            widget.updateDistance(value);
          });
        },
      )
          : RangeSlider(
        values: _age,
        max: 60,
        min: 18,
        divisions: 5,
        labels: RangeLabels(
          _age.start.round().toString(),
          _age.end.round().toString(),
        ),
        onChanged: (RangeValues values) {
          setState(() {
            _age = values;
          });
        },
      ),
    );
  }

  searchBuddies() async {
    buddiesProfiles = await ApiService().searchBuddies(
        username: widget.userModel.username,
        searchString: "",
        radius: distance.round().toString(),
        gender: gender,
        lat: widget.latitude.toString(),
        long: widget.longitude.toString(),
        category_id: _catID);
    if (mounted) {
      if (buddiesProfiles.isEmpty) {
        _controller.addError("No data found");
      } else {
        _controller.add(buddiesProfiles);
      }

      setState(() {
        for (int i = 0; i < buddiesProfiles.length; i++) {
          interestUrls[i] = _getFirstInterest(i);
        }
        Log.log(buddiesProfiles);
      });
    }
  }

  List<InterestChipModel> _getInterestList(BuddyModel buddyProfile) {
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

  _getFirstInterest(int index) {
    if (interestUrls.containsKey(index)) {
      return interestUrls[index]!;
    }

    if (buddiesProfiles.isNotEmpty) {
      List<String> selectedInterestsList =
      buddiesProfiles[index].selectedInterests!.split(",").map((id) => id).toList();

      if (selectedInterestsList.isNotEmpty) {
        final randomInterestId =
        selectedInterestsList[Random().nextInt(selectedInterestsList.length)];

        for (InterestChipModel interest in widget.fullInterestList) {
          if (interest.catID == randomInterestId) {
            String labelWithoutEmoji =
            interest.label.replaceAll(RegExp(r'[^\w\s]+'), '').trim().replaceAll(" ", "");
            String url = 'https://loremflickr.com/500/1000/$labelWithoutEmoji';
            interestUrls[index] = url;
            Log.log(url);
            return url;
          }
        }
      }
    }

    return 'https://loremflickr.com/500/1000/purple';
  }

  void copy() {
    sideInterestList = widget.fullInterestList.map((interest) => interest.copy(false)).toList();
  }

  UserModel copyBuddyToUser(BuddyModel buddy) {
    return UserModel(
      id: buddy.id ?? "",
      phone: buddy.phone ?? "",
      username: buddy.username ?? "",
      image: buddy.image ?? "",
      name: buddy.name ?? "",
      email: buddy.email ?? "",
      bio: buddy.bio ?? "",
      location: "${buddy.latitude!},${buddy.longitude!}",
      birthday: buddy.birthday ?? "",
      gender: buddy.gender ?? "",
      selectedInterests: buddy.selectedInterests ?? '',
      emailVerified: true,
    );
  }

  Future<List<ImageModel>> getImages(username) async {
    List<ImageModel> imagesList = await ApiService().getImages(username: username);
    return imagesList;
  }

  resetFilters() async {
    switchValue = null;
    _catID = "-1";
    _age = const RangeValues(18, 20);
    copy();
    CustomDialogs.showLoadingAnimation(context);
    await searchBuddies();
    setState(() {
      Navigator.of(context).pop();
    });
  }
}
