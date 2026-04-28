import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/security/security_bloc.dart';
import '../../bloc/security/security_event.dart';
import '../../bloc/security/security_state.dart';
import '../../../domain/entities/security_activity.dart';
import 'package:intl/intl.dart';

class SecurityCenterScreen extends StatelessWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Security Center', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          if (state is SecurityLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SecurityLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBiometricSection(context, state),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Active Sessions & Login Activity'),
                  const SizedBox(height: 16),
                  _buildLoginActivity(context, state),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Security Questions'),
                  const SizedBox(height: 16),
                  _buildSecurityQuestions(context, state),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
    );
  }

  Widget _buildBiometricSection(BuildContext context, SecurityLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.fingerprint, color: Colors.blueAccent, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Use FaceID or Fingerprint for login', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: state.biometricsEnabled,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  context.read<SecurityBloc>().add(ToggleBiometricsEvent(val));
                },
                activeColor: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginActivity(BuildContext context, SecurityLoaded state) {
    return Column(
      children: state.activities.map((activity) => _ActivityTile(activity: activity)).toList(),
    );
  }

  Widget _buildSecurityQuestions(BuildContext context, SecurityLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: state.securityQuestions.entries.map((entry) {
          return ListTile(
            title: Text(entry.key, style: const TextStyle(fontSize: 14)),
            subtitle: const Text('********', style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () {
              // Show edit dialog
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final SecurityActivity activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(
              activity.deviceName.contains('Mac') || activity.deviceName.contains('Windows') 
                ? Icons.laptop_mac 
                : Icons.phone_iphone,
              size: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(activity.deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (activity.isCurrentDevice) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text('CURRENT', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text('${activity.location} • ${activity.ipAddress}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(DateFormat('dd MMM, HH:mm').format(activity.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          if (!activity.isCurrentDevice)
            TextButton(
              onPressed: () {
                _showLogoutConfirmation(context, activity.id);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, String deviceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remote Logout'),
        content: const Text('Are you sure you want to log out from this device?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<SecurityBloc>().add(RemoteLogoutEvent(deviceId));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Device logged out successfully'), behavior: SnackBarBehavior.floating)
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
