import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_state.dart';
import '../../bloc/qr/qr_bloc.dart';
import '../../bloc/qr/qr_event.dart';
import '../../bloc/qr/qr_state.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  @override
  void initState() {
    super.initState();
    final accountState = context.read<AccountBloc>().state;
    if (accountState is AccountLoaded) {
      context.read<QrBloc>().add(GenerateQrEvent(
        userId: accountState.account.id,
        accountId: accountState.account.accountNumber,
      ));
    } else {
      context.read<QrBloc>().add(const GenerateQrEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: BlocBuilder<QrBloc, QrState>(
        builder: (context, state) {
          if (state is QrLoading || state is QrInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is QrError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message),
                  TextButton(
                    onPressed: () => context.read<QrBloc>().add(const GenerateQrEvent()),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          if (state is QrLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), 
                          blurRadius: 20, 
                          offset: const Offset(0, 10)
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Text(
                            state.accountHolderName.isNotEmpty ? state.accountHolderName[0].toUpperCase() : 'U',
                            style: TextStyle(color: theme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(state.accountHolderName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('Scan this to pay me', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: QrImageView(
                            data: state.qrData,
                            version: QrVersions.auto,
                            size: 200.0,
                            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor, 
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.05))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(state.accountNumber, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              IconButton(
                                icon: Icon(Icons.copy_rounded, size: 20, color: theme.primaryColor),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: state.accountNumber));
                                  HapticFeedback.selectionClick();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Account number copied!'),
                                      backgroundColor: theme.primaryColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    )
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Icon(Icons.security_rounded, color: theme.primaryColor.withOpacity(0.5), size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Your QR code is encrypted and only contains information required for local bank transfers.', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.grey, fontSize: 12)
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
