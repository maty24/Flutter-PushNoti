import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/homescreen.dart';

final appRouter = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomeScreen(),
  )
]);
