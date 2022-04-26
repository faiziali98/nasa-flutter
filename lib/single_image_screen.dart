import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysample/utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
import 'image_full_screen.dart';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SingleImageScreen extends StatefulWidget {
  final String fullUrl;
  final List<dynamic> savedUrls;

  const SingleImageScreen({
    Key? key,
    required this.fullUrl,
    required this.savedUrls,
  }) : super(key: key);

  @override
  State<SingleImageScreen> createState() => _SingleImageScreen();
}

class _SingleImageScreen extends State<SingleImageScreen> {
  bool showTop = false;
  FToast fToast = FToast();
  bool isBookmarked = false;
  final storage = const FlutterSecureStorage();

  String url = '';
  String title = '';
  List<dynamic> savedUrls = [];

  _SingleImageScreen();

  _asyncMethod() async {
    fToast.showToast(
      child: toast(Colors.grey, "Downloading..."),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

    List<String> urlSplit = url.split('.');
    String extension = urlSplit.removeLast();

    var response = await Dio().get(
      '${urlSplit.join('.')}_b.${extension}',
      options: Options(responseType: ResponseType.bytes),
    );
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 60,
      name: "hello",
    );

    fToast.showToast(
      child: toast(Colors.green, "Downloaded"),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    final splitValues = widget.fullUrl.split('t1t11e');

    url = splitValues[1];
    title = splitValues[0];

    fToast.init(context);
    savedUrls = widget.savedUrls;
    isBookmarked = savedUrls.contains(widget.fullUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageFullScreenWidget(
                          url: url,
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    height: 300,
                  ),
                ),
              ),
              Container(
                height: 16,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                height: 16,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "This new selfie was created using a specialised pupil imaging lens inside the James Webb Space Telescope (Webb's) Near-Infrared Camera (NIRCam), designed to take images of the primary mirror segments instead of images of the sky. This configuration is not used during scientific operations and is used strictly for engineering and alignment purposes. In this image, all of Webb’s 18 primary mirror segments are shown collecting light from the same star in unison.",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _asyncMethod();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (!isBookmarked) {
                            savedUrls.add(widget.fullUrl);
                            isBookmarked = true;
                          } else {
                            savedUrls.remove(widget.fullUrl);
                            isBookmarked = false;
                          }

                          storage.write(
                            key: "saved",
                            value: jsonEncode(savedUrls),
                          );
                        });
                        fToast.showToast(
                          child: toast(Colors.green, "Saved"),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: Duration(seconds: 2),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: Colors.transparent,
                      ),
                      child: Icon(
                        isBookmarked == true
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
