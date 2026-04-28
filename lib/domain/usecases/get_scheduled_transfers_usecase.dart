import '../entities/scheduled_transfer.dart';
import '../repositories/transfer_repository.dart';

class GetScheduledTransfersUseCase {
  final TransferRepository repository;

  GetScheduledTransfersUseCase(this.repository);

  Future<List<ScheduledTransferEntity>> execute(String accountId) async {
    return await repository.getScheduledTransfers(accountId);
  }
}
