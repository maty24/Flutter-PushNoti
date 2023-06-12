import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entites/push_message.dart';

import '../../firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

//cae aca cuando la app esta en segundo plano
//cuando la app esta cerrada esto esta a la espera que caiga una notificacion
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationStatusChanged);
    on<NotificationReceived>(_onPushMessageReceived);

    // Verificar estado de las notificaciones
    _initalStatusCheck();

    // listerner opara notificacione background
    _onForegroudMessage();
  }

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationStatusChanged(
      NotificationStatusChanged event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(status: event.status));
    _getFCMToken();
  }

  void _onPushMessageReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(state
        //enviamos el estado, tomo el evento y el spread para obtener todas las demas y poner la nueva como principal
        .copyWith(notifications: [event.pushMessage, ...state.notifications]));
  }

  //esta funcion solo el estado actular no estoy haciendo una peticion si esta activado las notificaciones
  void _initalStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  //esto tiene el token del dispositivo
  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();
    print(token);
  }

//data notic enviada desde el servidor y aca la recibo
  void handleRemoteMessage(RemoteMessage message) {
    //si viene una notificacion hacemos algo de lo contrario no hacemos nada
    if (message.notification == null) return;

    final notification = PushMessage(
        //le pongo el ?? por si viene nulo y lo reemplazo por otro valor
        messageId: message.messageId?.replaceAll(':', '').replaceAll('%', '') ??
            '',
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sentDate: message.sentTime ?? DateTime.now(),
        data: message.data,

        //si es android busca el de android de lo contrario busca el de apple
        imageUrl: Platform.isAndroid
            ? message.notification!.android?.imageUrl
            : message.notification!.apple?.imageUrl);

//le envio la notificacion
    add(NotificationReceived(notification));
  }

  void _onForegroudMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  //esta funcion hace que pregunte para ver si esta autorizado , sino le manda algo para que acepte las notificaciones
  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exist = state.notifications
        .any((element) => element.messageId == pushMessageId);
    if (!exist) return null;

//si existe me busque y me retorne la notificacion del array que tengo en el bloc
    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
  }
}
