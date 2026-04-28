import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_bloc.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_event.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_state.dart';
import 'schedule_new_transfer_screen.dart';
import '../../../domain/entities/scheduled_transfer.dart';

class ScheduledTransfersScreen extends StatefulWidget {
  final String accountId;

  const ScheduledTransfersScreen({super.key, required this.accountId});

  @override
  State<ScheduledTransfersScreen> createState() => _ScheduledTransfersScreenState();
}

class _ScheduledTransfersScreenState extends State<ScheduledTransfersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduledTransferBloc>().add(LoadScheduledTransfers(widget.accountId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Transfers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScheduleNewTransferScreen(accountId: widget.accountId),
                ),
              );
            },
          )
        ],
      ),
      body: BlocConsumer<ScheduledTransferBloc, ScheduledTransferState>(
        listener: (context, state) {
          if (state is ScheduledTransferOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ScheduledTransferError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        buildWhen: (previous, current) => 
          current is ScheduledTransferLoading || current is ScheduledTransferLoaded || current is ScheduledTransferError,
        builder: (context, state) {
          if (state is ScheduledTransferLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScheduledTransferLoaded) {
            if (state.transfers.isEmpty) {
              return const Center(child: Text("No scheduled transfers found."));
            }
            return ListView.builder(
              itemCount: state.transfers.length,
              itemBuilder: (context, index) {
                final transfer = state.transfers[index];
                return ListTile(
                  title: Text('To: ${transfer.recipientAccount}'),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(transfer.scheduledDate)} • ${transfer.frequency.name.toUpperCase()}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${transfer.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (transfer.status != ScheduledTransferStatus.cancelled)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            context.read<ScheduledTransferBloc>().add(
                              CancelTransfer(transfer.id, widget.accountId),
                            );
                          },
                        )
                    ],
                  ),
                );
              },
            );
          } else if (state is ScheduledTransferError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
