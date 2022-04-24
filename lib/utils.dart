import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

extension AppLaunch on SharedPreferences {
  static const _firstLaunchKey = 'firstLaunch';
  static Future<bool> isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
    if (firstLaunch) {
      await prefs.setBool(_firstLaunchKey, false);
    }
    return firstLaunch;
  }
}

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

Widget toast(color, text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(text),
        ],
      ),
    );

void requestPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  statuses[Permission.storage].toString();
}

const gradient = LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  stops: [
    0.3,
    0.7,
  ],
  colors: [
    Colors.black,
    Color.fromARGB(255, 14, 39, 71),
  ],
);

Future<void> setUserToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  FirebaseFirestore.instance.collection('fcmTokens').add({'token': token});
}
