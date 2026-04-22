import 'package:flutter/material.dart';
import '../../../domain/entities/card_entity.dart';
import '../../../core/theme/app_theme.dart';

class CardWidget extends StatelessWidget {
  final CardEntity card;
  final VoidCallback onFreezeToggle;
  final VoidCallback onDelete;

  const CardWidget({
    Key? key,
    required this.card,
    required this.onFreezeToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mask card number
    String maskedNumber = '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.isFrozen 
              ? [Colors.grey.shade400, Colors.grey.shade600]
              : (card.cardType == 'Credit'
                  ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)]
                  : [const Color(0xFF009FFF), const Color(0xFFec2F4B)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.isVirtual ? 'Virtual ${card.cardType} Card' : '${card.cardType} Card',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (card.isFrozen)
                  const Icon(Icons.ac_unit, color: Colors.blueAccent)
                else
                  const Icon(Icons.credit_card, color: Colors.white),
              ],
            ),
            const SizedBox(height: 24.0),
            Text(
              maskedNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Card Holder',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      card.cardHolderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expires',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      card.expiryDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onFreezeToggle,
                  icon: Icon(
                    card.isFrozen ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    card.isFrozen ? 'Unfreeze' : 'Freeze',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Delete Card',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
