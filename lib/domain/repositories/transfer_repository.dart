import '../entities/scheduled_transfer.dart';

abstract class TransferRepository {
  Future<void> scheduleTransfer(ScheduledTransferEntity transfer);
  Future<List<ScheduledTransferEntity>> getScheduledTransfers(String accountId);
  Future<void> cancelScheduledTransfer(String transferId);
}
