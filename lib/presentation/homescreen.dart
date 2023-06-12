import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/notifications/notifications_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.select(
          (NotificationsBloc bloc) => Text('${bloc.state.status}'),
        ),
        actions: [
          IconButton(
              onPressed: () {
                context.read<NotificationsBloc>().requestPermission();
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final notification = context.watch<NotificationsBloc>().state.notifications;
    return ListView.builder(
      itemCount: notification.length,
      itemBuilder: (BuildContext context, int index) {
        final notificacion = notification[index];
        return ListTile(
          title: Text(notificacion.title),
          subtitle: Text(notificacion.body),
          leading: notificacion.imageUrl != null
              ? Image.network(notificacion.imageUrl!)
              : null,
          onTap: () {
            context.push('/push-details/${notificacion.messageId}');
          },
        );
      },
    );
  }
}
