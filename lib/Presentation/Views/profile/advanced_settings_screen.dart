import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Customization', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('APPEARANCE'),
          const SizedBox(height: 16),
          _buildThemeToggle(context),
          const SizedBox(height: 24),
          _buildSectionTitle('PRIMARY COLOR'),
          const SizedBox(height: 16),
          _buildColorPicker(context),
          const SizedBox(height: 32),
          _buildSectionTitle('TEXT SIZE'),
          const SizedBox(height: 16),
          _buildFontScaler(context),
          const SizedBox(height: 32),
          _buildSectionTitle('PRIVACY'),
          const SizedBox(height: 16),
          _buildPrivacyToggles(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              _themeOption(context, 'Light', ThemeMode.light, Icons.light_mode, state.themeMode == ThemeMode.light),
              _themeOption(context, 'Dark', ThemeMode.dark, Icons.dark_mode, state.themeMode == ThemeMode.dark),
              _themeOption(context, 'System', ThemeMode.system, Icons.settings_brightness, state.themeMode == ThemeMode.system),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOption(BuildContext context, String label, ThemeMode mode, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<ThemeBloc>().add(ChangeThemeModeEvent(mode)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final colors = [
      const Color(0xFF2563EB), // Blue
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF059669), // Green
      const Color(0xFFDC2626), // Red
      const Color(0xFFD97706), // Orange
      const Color(0xFF0F172A), // Slate
    ];

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = state.primaryColor.value == color.value;
              return GestureDetector(
                onTap: () => context.read<ThemeBloc>().add(ChangePrimaryColorEvent(color)),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.white, width: 3) : null),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFontScaler(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Column(
          children: [
            Slider(
              value: state.fontScale,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              label: '${(state.fontScale * 100).toInt()}%',
              onChanged: (val) => context.read<ThemeBloc>().add(ChangeFontScaleEvent(val)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Small', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Standard', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Large', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrivacyToggles(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                title: const Text('Hide Balance', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Mask account balance on dashboard', style: TextStyle(fontSize: 12)),
                value: state.hideBalance,
                onChanged: (val) => context.read<SettingsBloc>().add(TogglePrivacyModeEvent(val)),
              ),
              const Divider(height: 1, indent: 16),
              ListTile(
                title: const Text('Daily Transfer Limit', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Current: \$${state.dailyTransferLimit.toInt()}', style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                onTap: () => _showLimitDialog(context, state.dailyTransferLimit),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLimitDialog(BuildContext context, double currentLimit) {
    final controller = TextEditingController(text: currentLimit.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Daily Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '\$ ', hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(controller.text) ?? currentLimit;
              context.read<SettingsBloc>().add(UpdateDailyLimitEvent(limit));
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
