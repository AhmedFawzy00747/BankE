import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LoanPdfViewerScreen extends StatelessWidget {
  final String filePath;
  final String userName;

  const LoanPdfViewerScreen({
    super.key, 
    required this.filePath, 
    required this.userName
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Loan Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Applicant: $userName', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              // Share logic could go here
            },
          ),
        ],
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    // Handle mock paths or missing files gracefully
    if (filePath.isEmpty) {
      return const Center(child: Text('No document uploaded for this application.'));
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Physical file not found on this device.'),
            const SizedBox(height: 8),
            Text('Path: $filePath', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      );
    }

    return SfPdfViewer.file(file);
  }
}
