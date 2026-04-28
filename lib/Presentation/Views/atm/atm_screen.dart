import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/atm/atm_bloc.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_state.dart';
import '../../bloc/account_event.dart';

class AtmScreen extends StatefulWidget {
  const AtmScreen({super.key});

  @override
  State<AtmScreen> createState() => _AtmScreenState();
}

class _AtmScreenState extends State<AtmScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isWithdraw = true;

  void _processTransaction(String accountId) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'))
      );
      return;
    }

    if (_isWithdraw) {
      _showPinDialog(accountId, amount);
    } else {
      context.read<AtmBloc>().add(DepositEvent(accountId, amount));
    }
  }

  void _showPinDialog(String accountId, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enter PIN', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your 4-digit secret PIN to authorize this withdrawal.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _pinController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final pin = _pinController.text;
                _pinController.clear();
                Navigator.pop(context);
                context.read<AtmBloc>().add(WithdrawEvent(accountId, amount, pin));
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATM Services', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocListener<AtmBloc, AtmState>(
        listener: (context, state) {
          if (state is AtmSuccess) {
            _amountController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green)
            );
            // Refresh account balance
            final accountState = context.read<AccountBloc>().state;
            if (accountState is AccountLoaded) {
              context.read<AccountBloc>().add(FetchAccountBalance(accountState.account.id));
            }
          } else if (state is AtmError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red)
            );
          }
        },
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, accountState) {
            if (accountState is! AccountLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final account = accountState.account;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(account.balance),
                  const SizedBox(height: 32),
                  _buildTypeSelector(),
                  const SizedBox(height: 32),
                  _buildAmountInput(),
                  const SizedBox(height: 48),
                  _buildActionButtons(account.id),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('\$${balance.toStringAsFixed(2)}', 
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _selectorBtn(
            label: 'Withdraw', 
            icon: Icons.upload_rounded, 
            isSelected: _isWithdraw,
            onTap: () => setState(() => _isWithdraw = true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _selectorBtn(
            label: 'Deposit', 
            icon: Icons.download_rounded, 
            isSelected: !_isWithdraw,
            onTap: () => setState(() => _isWithdraw = false),
          ),
        ),
      ],
    );
  }

  Widget _selectorBtn({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.transparent : theme.dividerColor.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : theme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.attach_money_rounded),
            hintText: '0.00',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String accountId) {
    return BlocBuilder<AtmBloc, AtmState>(
      builder: (context, state) {
        final isLoading = state is AtmLoading;
        return SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _processTransaction(accountId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_isWithdraw ? 'Proceed to Withdraw' : 'Deposit Cash', 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
