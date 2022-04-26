import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysample/single_image_screen.dart';
import 'package:mysample/utils.dart';
import 'all_images_screen.dart';
import 'models/images.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool showMenu = false;
  List<dynamic> savedUrls = [];
  bool isSwitched = false;
  String tokenId = '';
  final storage = const FlutterSecureStorage();
  var allImagesUrls = [];

  void initStore() async {
    final firstLaunch = await AppLaunch.isFirstLaunch();

    if (firstLaunch) {
      storage.delete(key: "saved");
      storage.delete(key: "isSwitched");
      tokenId = await setUserToken();
      storage.write(
        key: "tokenId",
        value: tokenId,
      );
    } else {
      var data = await storage.read(key: "saved");
      String? isSwitchedSaved = await storage.read(key: "isSwitched");
      String? savedtTokenId = await storage.read(key: "tokenId");
      if (data != null) savedUrls = jsonDecode(data);
      if (savedtTokenId != null) tokenId = savedtTokenId;
      if (isSwitchedSaved != null) {
        isSwitched = isSwitchedSaved == 'true' ? true : false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initStore();
    requestPermission();
  }

  List<Widget> getImagesItems(images) {
    return images.map<Widget>((item) {
      final splitValues = item.split('t1t11e');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: InkWell(
          onTap: () {
            if (showMenu == true) {
              setState(() {
                showMenu = false;
              });
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SingleImageScreen(
                    fullUrl: item,
                    savedUrls: savedUrls,
                  ),
                ),
              );
            }
            ;
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
    }).toList();
  }

  Widget _imageItemList(data) {
    final images = data.url;
    final childrenImages = getImagesItems(images);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: childrenImages,
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final imageRef = FirebaseFirestore.instance
        .collection('images')
        .withConverter<Images>(
          fromFirestore: (snapshots, _) => Images.fromJson(snapshots.data()!),
          toFirestore: (movie, _) => movie.toJson(),
        );

    List<Widget> widgetList = [
      StreamBuilder<QuerySnapshot<Images>>(
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
          final dataUrls = data.map((ele) => ele.data().url).toList().forEach(
            (e) {
              final toAdd = e.map((val) => val.split('t1t11e')[1]).toList();
              allImagesUrls.addAll(toAdd);
            },
          );

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _imageItemList(
                data[index].data(),
              );
            },
          );
        },
      ),
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
                    builder: (context) =>
                        AllImagesScreen(savedUrls: allImagesUrls),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.grid_on,
                      color: Colors.white,
                    ),
                    Container(
                      width: 8,
                    ),
                    Text(
                      "All Images",
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Notifications",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: showMenu ? 20 : 0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 8,
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                        storage.write(
                          key: "isSwitched",
                          value: isSwitched.toString(),
                        );
                        FirebaseFirestore.instance
                            .collection('fcmTokens')
                            .doc(tokenId)
                            .update({'sendNotification': isSwitched});
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                    inactiveTrackColor: Colors.grey[350],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
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
