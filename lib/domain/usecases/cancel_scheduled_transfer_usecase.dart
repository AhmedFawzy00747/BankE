import '../repositories/transfer_repository.dart';

class CancelScheduledTransferUseCase {
  final TransferRepository repository;

  CancelScheduledTransferUseCase(this.repository);

  Future<void> execute(String transferId) async {
    return await repository.cancelScheduledTransfer(transferId);
  }
}
