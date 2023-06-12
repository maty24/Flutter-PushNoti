import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_app/router/app_router.dart';

class LocalNotifications {
  static Future<void> requestPermissionLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  static Future<void> initializeLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    //TODO ios configuration

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // TODO ios configuration settings
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        //va a la ruta de donde aprete la notificacion o navego a la app
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data,
  }) {
    const androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName',
        importance: Importance.max, priority: Priority.high);

    //agrupador de notificaciones
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      //TODO IOS
    );
    //toma la instancia , pide permiso
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //paa la data
    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails,
        payload: data);
  }

  //funcion cuando llega la notificacion al apretar me lleve a la pagina de esta
  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    appRouter.push('/push-details/${response.payload}');
  }
}
