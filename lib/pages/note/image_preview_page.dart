import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreviewScreen extends StatelessWidget {
  final List<String> imagePaths;
  final int currentIndex;

  const ImagePreviewScreen({
    super.key,
    required this.imagePaths,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: null,
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              alignment: Alignment.center,
              child: PhotoViewGallery.builder(
                itemCount: imagePaths.length,
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(
                      File(imagePaths[index]),
                    ),
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: imagePaths[index],
                      transitionOnUserGestures: true,
                    ),
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                pageController: PageController(initialPage: currentIndex),
              ),
            ),
            Positioned(
              top: 30.0,
              left: 10.0,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
