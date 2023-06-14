import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart' show OpenFile;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int currentIndex;

  const ImagePreviewScreen({
    super.key,
    required this.imagePaths,
    required this.currentIndex,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  itemCount: widget.imagePaths.length,
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(
                        File(widget.imagePaths[index]),
                      ),
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: widget.imagePaths[index],
                        transitionOnUserGestures: true,
                      ),
                    );
                  },
                  pageController:
                      PageController(initialPage: widget.currentIndex),
                  onPageChanged: (index) => setState(() => _index = index),
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
              Positioned(
                top: 30.0,
                right: 10.0,
                child: IconButton(
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  onPressed: () => OpenFile.open(widget.imagePaths[_index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
