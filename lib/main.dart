import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/presentation/notifications/notifications_bloc.dart';
import 'package:push_app/router/app_router.dart';
import 'package:push_app/theme/app_theme.dart';

void main() async {
  //configuracion firebase noti push
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsBloc.initializeFCM();

  //esto sirve para recivir notificacion cuando cerre la app o esta terminada
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  //pongo mi bloc a lo mas alto de mi app
  runApp(MultiBlocProvider(
    providers: [BlocProvider(create: (_) => NotificationsBloc())],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      builder: (context, child) =>
          //simpre voy a tener el child
          //toda ,mi app la estoy envolviendo en mi handlenotifi
          HandleNotificationInteractions(child: child!),
    );
  }
}

//
class HandleNotificationInteractions extends StatefulWidget {
  final Widget child;
  const HandleNotificationInteractions({super.key, required this.child});

  @override
  State<HandleNotificationInteractions> createState() =>
      _HandleNotificationInteractionsState();
}

class _HandleNotificationInteractionsState
    extends State<HandleNotificationInteractions> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  //esto cuando todo la notificacion
  void _handleMessage(RemoteMessage message) {
    //el apretar la notificacion me hace como un push al array de las notificaciones
    context.read<NotificationsBloc>().handleRemoteMessage(message);
    final messageId =
        message.messageId?.replaceAll(':', '').replaceAll('%', '');
    appRouter.push('/push-details/$messageId');
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
