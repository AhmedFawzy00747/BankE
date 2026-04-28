import '../entities/scheduled_transfer.dart';
import '../repositories/transfer_repository.dart';

class ScheduleTransferUseCase {
  final TransferRepository repository;

  ScheduleTransferUseCase(this.repository);

  Future<void> execute(ScheduledTransferEntity transfer) async {
    return await repository.scheduleTransfer(transfer);
  }
}
