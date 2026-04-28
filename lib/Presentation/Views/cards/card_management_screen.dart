import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/card/card_bloc.dart';
import '../../bloc/card/card_event.dart';
import '../../bloc/card/card_state.dart';
import '../../widgets/card_widget.dart';
import '../../../core/constants/app_constants.dart';
import 'add_card_screen.dart';

class CardManagementScreen extends StatefulWidget {
  const CardManagementScreen({Key? key}) : super(key: key);

  @override
  _CardManagementScreenState createState() => _CardManagementScreenState();
}

class _CardManagementScreenState extends State<CardManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    context.read<CardBloc>().add(const LoadCardsEvent(AppConstants.currentAccountId));
  }

  void _generateVirtualCard() {
    context.read<CardBloc>().add(const GenerateVirtualCardEvent(AppConstants.currentAccountId, 'John Doe'));
  }

  void _showPinChangeDialog(BuildContext context, String cardId) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Card PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(hintText: 'Enter new 4-digit PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                context.read<CardBloc>().add(ChangeCardPinEvent(cardId, pinController.text, AppConstants.currentAccountId));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLimitDialog(BuildContext context, String cardId, double currentLimit) {
    final limitController = TextEditingController(text: currentLimit.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Spend Limit'),
        content: TextField(
          controller: limitController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter new daily limit', prefixText: '\$'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newLimit = double.tryParse(limitController.text);
              if (newLimit != null) {
                context.read<CardBloc>().add(UpdateCardLimitEvent(cardId, newLimit, AppConstants.currentAccountId));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCardScreen()),
    ).then((_) {
      _loadCards();
    });
  }

  void _showDeleteConfirmation(BuildContext context, String cardId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CardBloc>().add(DeleteCardEvent(cardId, AppConstants.currentAccountId));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Management', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _navigateToAddCard,
            tooltip: 'Add Physical Card',
          ),
        ],
      ),
      body: BlocConsumer<CardBloc, CardState>(
        listener: (context, state) {
          if (state is CardOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), behavior: SnackBarBehavior.floating),
            );
          } else if (state is CardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
            );
          }
        },
        buildWhen: (previous, current) => current is CardLoading || current is CardsLoaded || current is CardError,
        builder: (context, state) {
          if (state is CardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CardsLoaded) {
            return Column(
              children: [
                _buildVirtualCardPromo(context),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: state.cards.length,
                    itemBuilder: (context, index) {
                      final card = state.cards[index];
                      return CardWidget(
                        card: card,
                        onFreezeToggle: () {
                          context.read<CardBloc>().add(
                                FreezeCardEvent(card.id, !card.isFrozen, AppConstants.currentAccountId),
                              );
                        },
                        onDelete: () => _showDeleteConfirmation(context, card.id),
                        onPinChange: () => _showPinChangeDialog(context, card.id),
                        onLimitChange: () => _showLimitDialog(context, card.id, card.spendLimit),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is CardError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: Text('Initialize to view your cards.'));
        },
      ),
    );
  }

  Widget _buildVirtualCardPromo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Need a secure online card?', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Generate a virtual card instantly for safer online shopping.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _generateVirtualCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
