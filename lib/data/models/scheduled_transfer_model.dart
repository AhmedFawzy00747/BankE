import '../../domain/entities/scheduled_transfer.dart';

class ScheduledTransferModel extends ScheduledTransferEntity {
  const ScheduledTransferModel({
    required super.id,
    required super.senderId,
    required super.recipientAccount,
    required super.amount,
    required super.notes,
    required super.scheduledDate,
    required super.frequency,
    required super.status,
    required super.createdAt,
  });

  factory ScheduledTransferModel.fromJson(Map<String, dynamic> json) {
    return ScheduledTransferModel(
      id: json['id'],
      senderId: json['senderId'],
      recipientAccount: json['recipientAccount'],
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      frequency: TransferFrequency.values.firstWhere((e) => e.name == json['frequency']),
      status: ScheduledTransferStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientAccount': recipientAccount,
      'amount': amount,
      'notes': notes,
      'scheduledDate': scheduledDate.toIso8601String(),
      'frequency': frequency.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ScheduledTransferModel.fromEntity(ScheduledTransferEntity entity) {
    return ScheduledTransferModel(
      id: entity.id,
      senderId: entity.senderId,
      recipientAccount: entity.recipientAccount,
      amount: entity.amount,
      notes: entity.notes,
      scheduledDate: entity.scheduledDate,
      frequency: entity.frequency,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}
