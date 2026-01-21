import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iomdailyazkar/core/universal_widgets/app_snackbar.dart';

class FirebaseNotificationServices {

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
  }


  initFCM() async{
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    String? token = await firebaseMessaging.getToken();
    print("Firebase Messaging Token: $token");

    // Recive Notification

    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        if (message.notification != null) {
          String title = message.notification!.title ?? '';
          AppSnackbar.showInfo(title);

        }
      }
    );

    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        print('A new onMessage event was published!');
        if (message.notification != null) {
          String title = message.notification!.title ?? '';
          AppSnackbar.showInfo(title);
        }
      }
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
}