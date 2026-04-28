class LoanValidation {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a loan amount';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount greater than 0';
    }
    return null;
  }

  static String? validatePurpose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the purpose of the loan';
    }
    if (value.trim().length < 5) {
      return 'Purpose must be at least 5 characters';
    }
    return null;
  }

  static String? validateFile(String? fileName) {
    if (fileName == null) {
      return 'Please upload a supporting PDF document';
    }
    return null;
  }
}
