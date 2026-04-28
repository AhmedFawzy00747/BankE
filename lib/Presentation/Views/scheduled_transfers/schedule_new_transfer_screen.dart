import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/scheduled_transfer.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_bloc.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_event.dart';
import '../../bloc/scheduled_transfer/scheduled_transfer_state.dart';

class ScheduleNewTransferScreen extends StatefulWidget {
  final String accountId;

  const ScheduleNewTransferScreen({super.key, required this.accountId});

  @override
  State<ScheduleNewTransferScreen> createState() => _ScheduleNewTransferScreenState();
}

class _ScheduleNewTransferScreenState extends State<ScheduleNewTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TransferFrequency _frequency = TransferFrequency.once;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Transfer')),
      body: BlocListener<ScheduledTransferBloc, ScheduledTransferState>(
        listener: (context, state) {
          if (state is ScheduledTransferOperationSuccess) {
            Navigator.pop(context); // Go back after success
            context.read<ScheduledTransferBloc>().add(LoadScheduledTransfers(widget.accountId));
          } else if (state is ScheduledTransferError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _recipientController,
                  decoration: const InputDecoration(labelText: 'Recipient Account'),
                  validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
                ),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Scheduled Date: '),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Text(
                        _selectedDate == null 
                          ? 'Select Date' 
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<TransferFrequency>(
                  value: _frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: TransferFrequency.values.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(freq.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _frequency = val);
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _selectedDate != null) {
                      final transfer = ScheduledTransferEntity(
                        id: const Uuid().v4(),
                        senderId: widget.accountId,
                        recipientAccount: _recipientController.text,
                        amount: double.parse(_amountController.text),
                        notes: _notesController.text,
                        scheduledDate: _selectedDate!,
                        frequency: _frequency,
                        status: ScheduledTransferStatus.pending,
                        createdAt: DateTime.now(),
                      );
                      context.read<ScheduledTransferBloc>().add(ScheduleNewTransfer(transfer));
                    } else if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date')),
                      );
                    }
                  },
                  child: const Text('Schedule'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
