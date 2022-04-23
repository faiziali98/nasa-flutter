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

  @override
  Widget build(BuildContext context) {
    List<String> urlSplit = url.split('.');
    String extension = urlSplit.removeLast();
    String imageUrl = '${urlSplit.join('.')}_b.${extension}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      body: Stack(children: [
        InkWell(
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
            child: imageUrl == ''
                ? Container()
                : PhotoView(
                    loadingBuilder: (context, loadingProgress) {
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Some errors occurred!'),
                    imageProvider: NetworkImage(imageUrl),
                  ),
          ),
        ),
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
