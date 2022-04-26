import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notification_permissions/notification_permissions.dart';

import 'home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

var permGranted = "granted";
var permDenied = "denied";
var permUnknown = "unknown";
var permProvisional = "provisional";

Future<String> getCheckNotificationPermStatus() {
  return NotificationPermissions.getNotificationPermissionStatus()
      .then((status) {
    switch (status) {
      case PermissionStatus.denied:
        return permDenied;
      case PermissionStatus.granted:
        return permGranted;
      case PermissionStatus.unknown:
        return permUnknown;
      case PermissionStatus.provisional:
        return permProvisional;
      default:
        return '';
    }
  });
}

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.data.toString());
  print(message.notification!.title);
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (Platform.isIOS) {
    await NotificationPermissions.requestNotificationPermissions(
      iosSettings: const NotificationSettingsIos(
        sound: true,
        badge: true,
        alert: true,
      ),
    );
  }

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(scaffoldBackgroundColor: Color.fromARGB(255, 14, 39, 71)),
      title: _title,
      home: const MainScreen(),
    );
  }
}
