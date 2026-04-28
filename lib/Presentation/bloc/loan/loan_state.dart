import 'package:equatable/equatable.dart';
import '../../../../domain/entities/loan_entity.dart';

enum LoanSubmissionStatus { initial, submitting, success, error }

abstract class LoanState extends Equatable {
  final double estimatedEmi;
  final List<LoanEntity> loans;
  final LoanSubmissionStatus submissionStatus;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoading;
  final double uploadProgress;

  const LoanState({
    this.estimatedEmi = 0.0,
    this.loans = const [],
    this.submissionStatus = LoanSubmissionStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.uploadProgress = 0.0,
  });

  @override
  List<Object?> get props => [
        estimatedEmi,
        loans,
        submissionStatus,
        errorMessage,
        successMessage,
        isLoading,
        uploadProgress,
      ];
}

class LoanStatusUpdateState extends LoanState {
  const LoanStatusUpdateState({
    super.estimatedEmi,
    super.loans,
    super.submissionStatus,
    super.errorMessage,
    super.successMessage,
    super.isLoading,
    super.uploadProgress,
  });

  LoanStatusUpdateState copyWith({
    double? estimatedEmi,
    List<LoanEntity>? loans,
    LoanSubmissionStatus? submissionStatus,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
    double? uploadProgress,
  }) {
    return LoanStatusUpdateState(
      estimatedEmi: estimatedEmi ?? this.estimatedEmi,
      loans: loans ?? this.loans,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isLoading: isLoading ?? this.isLoading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
