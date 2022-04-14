import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageFullScreenWidget extends StatefulWidget {
  final String url;
  const ImageFullScreenWidget({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<ImageFullScreenWidget> createState() =>
      _ImageFullScreenWidget(url: url);
}

class _ImageFullScreenWidget extends State<ImageFullScreenWidget> {
  bool showTop = false;

  final String url;
  _ImageFullScreenWidget({
    required this.url,
  });

  Widget _imageWidget() {
    return InkWell(
      onTap: () {
        setState(() {
          showTop = !showTop;
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      body: Stack(children: [
        _imageWidget(),
        AnimatedOpacity(
          opacity: showTop ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: () {
              if (showTop == true) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              primary: Colors.transparent,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}
