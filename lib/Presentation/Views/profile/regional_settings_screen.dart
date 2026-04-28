import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/language/language_bloc.dart';
import '../../bloc/currency/currency_bloc.dart';

class RegionalSettingsScreen extends StatelessWidget {
  const RegionalSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regional Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('DISPLAY LANGUAGE'),
          const SizedBox(height: 16),
          _buildLanguageSelector(context),
          const SizedBox(height: 32),
          _buildSectionTitle('DEFAULT CURRENCY'),
          const SizedBox(height: 16),
          _buildCurrencySelector(context),
          const SizedBox(height: 40),
          _buildPreview(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _languageTile(context, 'English', 'en', '🇺🇸', state.locale.languageCode == 'en'),
              const Divider(height: 1, indent: 60),
              _languageTile(context, 'العربية', 'ar', '🇪🇬', state.locale.languageCode == 'ar'),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile(BuildContext context, String name, String code, String flag, bool isSelected) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
      onTap: () {
        context.read<LanguageBloc>().add(ChangeLanguageEvent(code));
      },
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _currencyChip(context, 'USD', '\$', state.currencyCode == 'USD'),
            _currencyChip(context, 'EUR', '€', state.currencyCode == 'EUR'),
            _currencyChip(context, 'GBP', '£', state.currencyCode == 'GBP'),
            _currencyChip(context, 'EGP', 'EGP', state.currencyCode == 'EGP'),
          ],
        );
      },
    );
  }

  Widget _currencyChip(BuildContext context, String code, String symbol, bool isSelected) {
    return InkWell(
      onTap: () => context.read<CurrencyBloc>().add(ChangeCurrencyEvent(code)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(symbol, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(code, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Text('Format Preview', style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                state.format(1250.50),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        );
      },
    );
  }
}
