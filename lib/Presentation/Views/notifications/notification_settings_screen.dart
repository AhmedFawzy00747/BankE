import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoaded) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'PREFERENCES',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                _buildToggle(context, 'Transactions', 'Alerts for credits and debits', state),
                _buildToggle(context, 'Promotions', 'Exclusive offers and rewards', state),
                _buildToggle(context, 'Security', 'Login alerts and critical updates', state),
                _buildToggle(context, 'System', 'App updates and maintenance', state),
                const SizedBox(height: 32),
                const Text(
                  'PUSH NOTIFICATIONS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                _buildSimpleTile('Pause All', Icons.pause_circle_outline),
                _buildSimpleTile('Quiet Hours', Icons.nightlight_outlined),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildToggle(BuildContext context, String title, String subtitle, NotificationLoaded state) {
    final enabled = state.settings[title] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Switch.adaptive(
          value: enabled,
          onChanged: (val) {
            final newSettings = Map<String, bool>.from(state.settings);
            newSettings[title] = val;
            context.read<NotificationBloc>().add(UpdateNotificationSettingsEvent(newSettings));
          },
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSimpleTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}
