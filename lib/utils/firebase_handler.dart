// import 'dart:io';
//
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:logger/web.dart';
//
// @pragma("vm:entry-point")
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print('Title: ${message.notification?.title}');
//   print('Body: ${message.notification?.body}');
//   print('Payload: ${message.data}');
// }
//
// class FirebaseHandler {
//   final _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     try {
//       if (Platform.isIOS) {
//         print("Requesting APNS token");
//         final apnsToken = await _firebaseMessaging.getAPNSToken();
//         print('APNs Token: $apnsToken');
//       }
//       final fcmToken = await _firebaseMessaging.getToken();
//       print('FCM Token: $fcmToken');
//     } catch (e, s) {
//       Logger().t(e, stackTrace: s);
//     }
//
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//     FirebaseMessaging.onMessage.listen((message) {
//       // Logger().d('Received message in foreground: ${message.notification}');
//       Logger().d('Title: ${message.notification?.title}');
//       Logger().d('Body: ${message.notification?.body}');
//       Logger().d('Payload: ${message.data}');
//       AwesomeNotifications().createNotification(
//           content: NotificationContent(
//         id: 1,
//         channelKey: 'basic_channel',
//         backgroundColor: Colors.green,
//         title: message.notification?.title,
//         body: message.notification?.body,
//       ));
//     });
//   }
// }
