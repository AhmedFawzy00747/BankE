import 'package:equatable/equatable.dart';

enum TransferFrequency { once, daily, weekly, monthly }

enum ScheduledTransferStatus { pending, completed, cancelled, failed }

class ScheduledTransferEntity extends Equatable {
  final String id;
  final String senderId;
  final String recipientAccount;
  final double amount;
  final String notes;
  final DateTime scheduledDate;
  final TransferFrequency frequency;
  final ScheduledTransferStatus status;
  final DateTime createdAt;

  const ScheduledTransferEntity({
    required this.id,
    required this.senderId,
    required this.recipientAccount,
    required this.amount,
    required this.notes,
    required this.scheduledDate,
    required this.frequency,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        senderId,
        recipientAccount,
        amount,
        notes,
        scheduledDate,
        frequency,
        status,
        createdAt,
      ];
}
