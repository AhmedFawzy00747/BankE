import 'package:flutter/material.dart';
import '../../../domain/entities/card_entity.dart';
import '../../../core/theme/app_theme.dart';

class CardWidget extends StatelessWidget {
  final CardEntity card;
  final VoidCallback onFreezeToggle;
  final VoidCallback onDelete;
  final VoidCallback onPinChange;
  final VoidCallback onLimitChange;

  const CardWidget({
    Key? key,
    required this.card,
    required this.onFreezeToggle,
    required this.onDelete,
    required this.onPinChange,
    required this.onLimitChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mask card number
    String maskedNumber =
        '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.isFrozen
              ? [Colors.grey.shade600, Colors.grey.shade800]
              : (card.cardType == 'Credit'
                  ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)]
                  : [
                      const Color(0xFF0F2027),
                      const Color(0xFF203A43),
                      const Color(0xFF2C5364)
                    ]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.isVirtual ? 'VIRTUAL CARD' : 'PHYSICAL CARD',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      card.cardType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Icon(
                  card.isFrozen
                      ? Icons.ac_unit_rounded
                      : Icons.contactless_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            Text(
              maskedNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                letterSpacing: 3.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Courier',
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('CARD HOLDER', card.cardHolderName),
                _buildInfoColumn('EXPIRES', card.expiryDate),
                _buildInfoColumn(
                    'LIMIT', '\$${card.spendLimit.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 24.0),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildActionButton(
                      icon: card.isFrozen
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      label: card.isFrozen ? 'Unfreeze' : 'Freeze',
                      onPressed: onFreezeToggle,
                    ),
                    _buildActionButton(
                      icon: Icons.lock_outline_rounded,
                      label: 'PIN',
                      onPressed: onPinChange,
                    ),
                    _buildActionButton(
                      icon: Icons.tune_rounded,
                      label: 'Limit',
                      onPressed: onLimitChange,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_sweep_rounded,
                      color: Colors.redAccent, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
