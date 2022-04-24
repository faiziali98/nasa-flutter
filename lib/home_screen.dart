import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysample/utils.dart';
import 'all_images_screen.dart';
import 'image_full_screen.dart';
import 'models/images.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String url = '';
  String title = '';
  bool showMenu = false;
  FToast fToast = FToast();
  List<dynamic> savedUrls = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final storage = const FlutterSecureStorage();

  void initStore() async {
    final firstLaunch = await AppLaunch.isFirstLaunch();

    if (firstLaunch) {
      storage.delete(key: "saved");
      await setUserToken();
    } else {
      var data = await storage.read(key: "saved");
      if (data != null) savedUrls = jsonDecode(data);
      print(savedUrls);
    }
  }

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    initStore();
    // requestPermission();
  }

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

  Widget _imageItem(data) {
    final images = data.url;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: images.map<Widget>((item) {
            final splitValues = item.split('t1t11e');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (showMenu == true) {
                      showMenu = false;
                    } else {
                      url = splitValues[1];
                      title = splitValues[0];
                    }
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(
                        splitValues[1],
                        fit: BoxFit.cover,
                        width: 400.0,
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Text(
                            splitValues[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    bool isBookmarked = savedUrls.contains(url);

    final imageRef = FirebaseFirestore.instance
        .collection('images')
        .withConverter<Images>(
          fromFirestore: (snapshots, _) => Images.fromJson(snapshots.data()!),
          toFirestore: (movie, _) => movie.toJson(),
        );

    List<Widget> widgetList = [
      url == ''
          ? StreamBuilder<QuerySnapshot<Images>>(
              stream: imageRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData.docs;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return _imageItem(
                      data[index].data(),
                    );
                  },
                );
              },
            )
          : Container(),
      AnimatedContainer(
        width: showMenu ? 3 * MediaQuery.of(context).size.width / 4 : 0,
        height: MediaQuery.of(context).size.height,
        duration: const Duration(milliseconds: 500),
        decoration: const BoxDecoration(
          gradient: gradient,
        ),
        curve: Curves.fastOutSlowIn,
        child: Column(
          children: [
            Container(height: 200, child: Image.asset('assets/logo.png')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "JWST",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: showMenu ? 24 : 0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AllImagesScreen(savedUrls: savedUrls),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bookmark,
                      color: Colors.white,
                    ),
                    Container(
                      width: 8,
                    ),
                    Text(
                      "Saved Images",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: showMenu ? 20 : 0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      AnimatedContainer(
        width: MediaQuery.of(context).size.width,
        height: url != '' ? MediaQuery.of(context).size.height : 0,
        duration: const Duration(milliseconds: 900),
        curve: Curves.fastOutSlowIn,
        child: url != ''
            ? Stack(
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
                            setState(() {
                              url = '';
                            });
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
                                    savedUrls.add(url);
                                  } else {
                                    savedUrls.remove(url);
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
              )
            : Container(),
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            setState(() {
              showMenu = !showMenu;
            });
          },
          child: const Icon(
            Icons.menu,
          ),
        ),
        title: const Text('NASA Images App'),
        backgroundColor: Colors.black,
        toolbarHeight: url != '' ? 0 : AppBar().preferredSize.height,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: gradient,
        ),
        child: Stack(
          children: widgetList,
        ),
      ),
    );
  }
}
