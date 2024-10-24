import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageFullScreen extends StatelessWidget {
  final List<String> imageUrlsList;
  final String imageUrl;
  int initialIndex = 0;
  final String imageName;
  bool isCarousel = false;

  ImageFullScreen({
    Key? key,
    this.isCarousel = false,
    required this.imageUrl,
    this.initialIndex = 0,
    required this.imageName,
    required this.imageUrlsList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          imageName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_back,
            color: kWhiteColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          /* IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // handle download button click
            },
          ),*/
        ],
      ),
      body: (isCarousel)
          ? CarouselSlider.builder(
              itemCount: imageUrlsList.length,
              options: CarouselOptions(
                initialPage: initialIndex,
                enableInfiniteScroll: false,
                viewportFraction:1,
                height: double.infinity,

                enlargeCenterPage: false,
              ),
              itemBuilder: (BuildContext context, int index, int realIndex) {
                return Container(

                  color: Colors.black,
                  child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(imageUrlsList[index]),
                    maxScale: PhotoViewComputedScale.contained * 3.0,
                    minScale: PhotoViewComputedScale.contained,
                    enableRotation: false,
                  ),
                );
              },
            )
          : Hero(
              tag: imageName,
              child: Container(
                color: Colors.black,
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(imageUrl),
                  maxScale: PhotoViewComputedScale.contained * 3.0,
                  minScale: PhotoViewComputedScale.contained,
                  enableRotation: false,
                ),
              ),
            ),
    );
  }
}
