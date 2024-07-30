import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_notif.dart';
import 'scackbars.dart';

class FirebaseNotif {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final LocalNotif localNotif = LocalNotif();

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('yey');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('yey 2');
    } else {
      print('gagal');
    }
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      String title = message.notification!.title.toString().toLowerCase();
      bool payloadAnnouncement = title.contains('announcement');
      if (payloadAnnouncement) {
        print('Announcement : $payloadAnnouncement');
      } else {
        print('Announcement : $payloadAnnouncement');
      }

      localNotif.showNotifications(
        id: message.notification.hashCode,
        title: message.notification?.title,
        body: message.notification?.body,
        payload: payloadAnnouncement.toString(),
      );

      print(message.data['key1'] == null
          ? 'key1 kosong'
          : 'Key : ${message.data['key1']}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      String title = message.notification!.title.toString().toLowerCase();
      bool payloadAnnouncement = title.contains('announcement');

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');
      if (token != null) {
        if (payloadAnnouncement) {
          Get.offAllNamed('/dashboard', arguments: 0);
        } else {
          Get.offAllNamed('/dashboard', arguments: 2);
        }
      } else {
        infoSnackbar(
          "You're not logged in",
          'Please log in first',
        );
        Get.offAllNamed('/login');
      }
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}