import 'package:flutter/material.dart';
import 'package:mysample/utils.dart';

import 'image_full_screen.dart';

class AllImagesScreen extends StatefulWidget {
  final savedUrls;
  const AllImagesScreen({
    Key? key,
    required this.savedUrls,
  }) : super(key: key);

  @override
  State<AllImagesScreen> createState() => _AllImagesScreen();
}

class _AllImagesScreen extends State<AllImagesScreen> {
  _AllImagesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images Gallery'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: gradient,
        ),
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(12),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          crossAxisCount: 3,
          children: widget.savedUrls.map<Widget>(
            (item) {
              final splitValues = item.split('t1t11e');
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageFullScreenWidget(
                        url: item,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(
                        splitValues[1],
                        fit: BoxFit.cover,
                        height: 100.0,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
