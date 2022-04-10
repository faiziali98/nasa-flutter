import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'models/images.dart';

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
          height: 5,
        ),
        Text(data.heading),
        ImageSlideshow(
          width: double.infinity,
          height: 300,
          initialPage: 0,
          indicatorColor: Colors.blue,
          indicatorBackgroundColor: Colors.grey,
          isLoop: true,
          children: images.map<Widget>((item) => Image.network(item)).toList(),
        ),
        Text(data.body),
        Container(
          height: 5,
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
