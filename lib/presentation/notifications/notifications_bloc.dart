import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationStatusChanged);

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

//data notic enviada desde el servidor
  void _handleRemoteMessage(RemoteMessage message) {

    //si viene una notificacion hacemos algo de lo contrario no hacemos nada
    if (message.notification != null) return;
  }

  void _onForegroudMessage(){
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
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
}
