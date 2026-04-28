import '../../domain/entities/scheduled_transfer.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../models/scheduled_transfer_model.dart';
import '../../core/error/failures.dart';

class TransferRepositoryImpl implements TransferRepository {
  // Mock storage for demonstration purposes. In a real application, 
  // this would interface with a remote API or local database.
  final List<ScheduledTransferModel> _mockStorage = [];

  @override
  Future<void> scheduleTransfer(ScheduledTransferEntity transfer) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      final model = ScheduledTransferModel.fromEntity(transfer);
      _mockStorage.add(model);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<ScheduledTransferEntity>> getScheduledTransfers(String accountId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return _mockStorage.where((t) => t.senderId == accountId).toList();
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> cancelScheduledTransfer(String transferId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _mockStorage.indexWhere((t) => t.id == transferId);
      if (index != -1) {
        final current = _mockStorage[index];
        _mockStorage[index] = ScheduledTransferModel(
          id: current.id,
          senderId: current.senderId,
          recipientAccount: current.recipientAccount,
          amount: current.amount,
          notes: current.notes,
          scheduledDate: current.scheduledDate,
          frequency: current.frequency,
          status: ScheduledTransferStatus.cancelled,
          createdAt: current.createdAt,
        );
      } else {
        throw const ServerFailure(message: 'Transfer not found');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }
}
