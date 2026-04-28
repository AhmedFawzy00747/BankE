import 'package:contr_project/Presentation/bloc/account_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:permission_handler/permission_handler.dart';
import '../../bloc/loan/loan_bloc.dart';
import '../../bloc/loan/loan_event.dart';
import '../../bloc/loan/loan_state.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_state.dart';
import '../../../core/utils/loan_validation.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _isFormValid = ValueNotifier<bool>(false);
  final _durationNotifier = ValueNotifier<double>(24.0);
  String? _selectedPdfName;
  String? _selectedPdfPath;

  @override
  void initState() {
    super.initState();
    // Dispatch initial event
    context.read<LoanBloc>().add(const FetchLoansEvent());

    // Initialize listeners
    _amountController.addListener(_validateForm);
    _purposeController.addListener(_validateForm);
    _amountController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateForm);
    _purposeController.removeListener(_validateForm);
    _amountController.removeListener(_onInputChanged);
    _isFormValid.dispose();
    _durationNotifier.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final hasFile = _selectedPdfPath != null;
    _isFormValid.value = isValid && hasFile;
  }

  void _onInputChanged() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    context.read<LoanBloc>().add(CalculateEMIEvent(
          amount: amount,
          durationMonths: _durationNotifier.value.toInt(),
        ));
  }

  Future<void> _pickFile() async {
    HapticFeedback.lightImpact();

    try {
      final fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );

      if (result == null) {
        return;
      }

      if (result.files.isEmpty) return;
      final file = result.files.first;

      if (file.extension?.toLowerCase() != 'pdf') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Invalid file type. Please select a PDF.'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      if (file.path != null) {
        setState(() {
          _selectedPdfName = file.name;
          _selectedPdfPath = file.path;
        });
        _validateForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error picking file: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _submit(BuildContext context, AccountLoaded accountState) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPdfName == null || _selectedPdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload a PDF document'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    context.read<LoanBloc>().add(SubmitLoanRequestEvent(
          amount: double.parse(_amountController.text),
          purpose: _purposeController.text.trim(),
          durationMonths: _durationNotifier.value.toInt(),
          pdfFileName: _selectedPdfName!,
          pdfFilePath: _selectedPdfPath!,
          userId: accountState.account.id,
          userName: accountState.account.accountHolderName,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Apply for a Loan',
            style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.titleLarge?.color),
        centerTitle: true,
      ),
      body: BlocListener<LoanBloc, LoanState>(
        listener: (context, state) {
          if (state.submissionStatus == LoanSubmissionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.successMessage ?? 'Success'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating),
            );
            Navigator.pop(context, true);
          } else if (state.submissionStatus == LoanSubmissionStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? 'Error'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating),
            );
          }
        },
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, accountState) {
            if (accountState is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (accountState is AccountError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(accountState.message),
                    TextButton(
                      onPressed: () => context
                          .read<AccountBloc>()
                          .add(const LoadUserAccounts('acc_123')),
                      child: const Text('Retry'),
                    )
                  ],
                ),
              );
            }

            if (accountState is! AccountLoaded) {
              return const Center(
                  child: Text('Please log in to apply for a loan'));
            }

            return Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEMICard(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Loan Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _amountController,
                      label: 'Loan Amount',
                      hint: 'e.g. 10000',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: LoanValidation.validateAmount,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _purposeController,
                      label: 'Purpose',
                      hint: 'e.g. Home Renovation',
                      prefixIcon: Icons.help_outline,
                      validator: LoanValidation.validatePurpose,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Repayment Period'),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<double>(
                      valueListenable: _durationNotifier,
                      builder: (context, duration, _) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Duration',
                                    style: TextStyle(color: Colors.grey[600])),
                                Text('${duration.toInt()} Months',
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Slider(
                              value: duration,
                              min: 6,
                              max: 60,
                              divisions: 54,
                              activeColor: theme.primaryColor,
                              inactiveColor:
                                  theme.primaryColor.withOpacity(0.1),
                              onChanged: (val) {
                                _durationNotifier.value = val;
                                _onInputChanged();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Verification'),
                    const SizedBox(height: 16),
                    _buildFileUpload(context),
                    const SizedBox(height: 48),
                    _buildSubmitButton(context, accountState),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEMICard(BuildContext context) {
    return BlocBuilder<LoanBloc, LoanState>(
        buildWhen: (previous, current) =>
            previous.estimatedEmi != current.estimatedEmi,
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                const Text('Estimated Monthly EMI',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('\$${state.estimatedEmi.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Interest Rate: 5% p.a.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, color: Theme.of(context).primaryColor),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: const TextStyle(height: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedPdfName == null
                ? Colors.grey.withOpacity(0.2)
                : Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _selectedPdfName == null ? Icons.upload_file : Icons.check_circle,
              size: 48,
              color: _selectedPdfName == null ? Colors.grey : Colors.green,
            ),
            const SizedBox(height: 12),
            Text(
              _selectedPdfName ?? 'Upload Supporting Documents (PDF)',
              style: TextStyle(
                color: _selectedPdfName == null
                    ? Colors.grey
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, AccountLoaded accountState) {
    return BlocBuilder<LoanBloc, LoanState>(
      buildWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus ||
          previous.uploadProgress != current.uploadProgress,
      builder: (context, state) {
        final isSubmitting =
            state.submissionStatus == LoanSubmissionStatus.submitting;

        return Column(
          children: [
            if (isSubmitting) ...[
              LinearProgressIndicator(
                value: state.uploadProgress,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Uploading document... ${(state.uploadProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            ValueListenableBuilder<bool>(
              valueListenable: _isFormValid,
              builder: (context, isValid, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      disabledBackgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                    onPressed: (isSubmitting || !isValid)
                        ? null
                        : () => _submit(context, accountState),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Submit Application',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
