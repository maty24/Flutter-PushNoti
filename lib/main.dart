import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/presentation/notifications/notifications_bloc.dart';
import 'package:push_app/router/app_router.dart';
import 'package:push_app/theme/app_theme.dart';

void main() async {
  //configuracion firebase noti push
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsBloc.initializeFCM();


  
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
    );
  }
}
