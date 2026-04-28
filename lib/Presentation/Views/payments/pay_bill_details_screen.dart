import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/biller.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_state.dart';
import '../transfer/transfer_review_screen.dart';

class PayBillDetailsScreen extends StatefulWidget {
  final BillerEntity biller;

  const PayBillDetailsScreen({
    super.key,
    required this.biller,
  });

  @override
  State<PayBillDetailsScreen> createState() => _PayBillDetailsScreenState();
}

class _PayBillDetailsScreenState extends State<PayBillDetailsScreen> {
  final _consumerIdController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isValidating = false;
  bool _isBillFetched = false;
  double? _suggestedAmount;

  @override
  void dispose() {
    _consumerIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchBillDetails() async {
    if (_consumerIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Consumer ID'))
      );
      return;
    }

    setState(() {
      _isValidating = true;
    });

    // Simulate API call to fetch bill details
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isValidating = false;
      _isBillFetched = true;
      // Mocked suggested amount based on ID length
      _suggestedAmount = (_consumerIdController.text.length * 15.5);
      _amountController.text = _suggestedAmount!.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Pay ${widget.biller.name}',
            style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.textTheme.titleLarge?.color),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBalanceHeader(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bill Information',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color),
                  ),
                  const SizedBox(height: 24),
                  _buildPremiumTextField(
                    context,
                    label: 'Consumer / Account ID',
                    hint: 'Enter ID number',
                    controller: _consumerIdController,
                    icon: Icons.account_circle_outlined,
                    onChanged: (_) {
                      if (_isBillFetched) {
                        setState(() {
                          _isBillFetched = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  if (!_isBillFetched)
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isValidating ? null : _fetchBillDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: primaryColor.withOpacity(0.2))),
                        ),
                        child: _isValidating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Fetch Bill Details',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (_isBillFetched) ...[
                    _buildBillSummaryCard(context),
                    const SizedBox(height: 24),
                    _buildPremiumTextField(
                      context,
                      label: 'Payment Amount',
                      hint: '0.00',
                      controller: _amountController,
                      icon: Icons.attach_money_rounded,
                      isNumber: true,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          if (_amountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please enter an amount')));
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransferReviewScreen(
                                account: widget.biller.name,
                                amount: _amountController.text,
                                notes: 'Bill ID: ${_consumerIdController.text}',
                                billerId: widget.biller.id,
                                consumerId: _consumerIdController.text,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 4,
                          shadowColor: primaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Review Payment',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Note: A convenience fee might apply depending on the service provider.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.green,
            radius: 20,
            child: Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bill Found',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Customer: John Doe (Mock)',
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
          ),
          Text('\$${_suggestedAmount?.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBalanceHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '\$${state.account.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
              ],
            );
          }
          return const SizedBox(height: 60);
        },
      ),
    );
  }

  Widget _buildPremiumTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: theme.dividerColor.withOpacity(0.1), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: theme.primaryColor),
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.normal),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
