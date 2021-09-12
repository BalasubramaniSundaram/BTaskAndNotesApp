import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

const String postUrl = 'https://fcm.googleapis.com/fcm/send';

Future<void> sendNotification(String receiverToken, msg) async {
  final data = {
    "notification": {
      "body": "Accept Ride Request",
      "title": "This is Ride Request"
    },
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done"
    },
    "to": "$receiverToken"
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization':
        'AAAA4W0zrk8:APA91bFlXRGnueoOxHOaeUjsYqM_AEnIUB3x21tP15wJDgZDGHrFlJa5TQ3qVb-iaXNI5QtTpf1zIuy5WwjqFdyhAkiP7_c61HL6ZH73OyhVfn8UTu5V2FLYHT-iI7kxzmx0b7zrgcSO'
  };

  BaseOptions options = new BaseOptions(
      followRedirects: false,
      validateStatus: (int? status) {
        return status != null ? status <= 500 : false;
      },
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers);

  try {
    final response = await Dio(options).post(postUrl, data: data);
    if (response.statusCode == 200) {
      print('');
    } else {
      print('');
    }
  } catch (e) {
    print(e);
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channel.description,
            icon: 'launch_background',
          ),
        ));
  }
}

Future<void> setUpCloudMessage() async {
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

void setUpMessageListener() {
  var initializationSettingAndroid =
      AndroidInitializationSettings("@mipmap/ic_launcher");
  var initializationSetting =
      InitializationSettings(android: initializationSettingAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSetting);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: 'launch_background',
            ),
          ));
    }
  });
}
