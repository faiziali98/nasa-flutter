import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'models/images.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

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
          child: Image.network(url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showTop
        ? Scaffold(
            appBar: AppBar(
              title: const Text('AppBar Demo'),
            ),
            body: _imageWidget())
        : Scaffold(body: _imageWidget());
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey<String>('bottom-sliver-list');
    final imageRef = FirebaseFirestore.instance
        .collection('images')
        .withConverter<Images>(
          fromFirestore: (snapshots, _) => Images.fromJson(snapshots.data()!),
          toFirestore: (movie, _) => movie.toJson(),
        );

    Widget _imageItem(data) {
      final images = data.url;
      return Column(children: [
        Container(
          height: 8,
        ),
        // Text(data.heading),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
              child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 1.5,
              enlargeCenterPage: true,
              initialPage: 2,
              autoPlay: true,
            ),
            items: images
                .map<Widget>(
                  (item) => InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageFullScreenWidget(
                            url: item,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        child: Stack(
                          children: <Widget>[
                            Image.network(
                              item,
                              fit: BoxFit.cover,
                              width: 400.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          )),

          // ImageSlideshow(
          //   width: double.infinity,
          //   height: 400,
          //   initialPage: 0,
          //   indicatorColor: Colors.blue,
          //   indicatorBackgroundColor: Colors.grey,
          //   isLoop: true,
          //   autoPlayInterval: 2000,
          //   children: images
          //       .map<Widget>((item) => InkWell(
          //           onTap: () {
          //             Navigator.of(context).push(MaterialPageRoute(
          //               builder: (context) => ImageFullScreenWidget(url: item),
          //             ));
          //           },
          //           child: Container(
          //               decoration: BoxDecoration(
          //                 color: Colors.black,
          //               ),
          //               child: Image.network(item))))
          //       .toList(),
          // ),
        ),
        // Text(data.body),
        Container(
          height: 8,
        ),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('NASA Images App'),
      ),
      body: StreamBuilder<QuerySnapshot<Images>>(
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
      ),
    );
  }
}
