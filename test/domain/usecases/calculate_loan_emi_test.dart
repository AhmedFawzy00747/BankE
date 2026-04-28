import 'package:flutter_test/flutter_test.dart';
import 'package:contr_project/domain/usecases/calculate_loan_emi.dart';

void main() {
  late CalculateLoanEMI calculateLoanEMI;

  setUp(() {
    calculateLoanEMI = CalculateLoanEMI();
  });

  group('CalculateLoanEMI Tests', () {
    test('should calculate correct EMI for \$10,000 at 5% for 24 months', () {
      const amount = 10000.0;
      const duration = 24;
      const rate = 5.0;

      final result = calculateLoanEMI.execute(
        amount: amount,
        durationMonths: duration,
        annualRate: rate,
      );

      // Expected EMI = 438.71
      expect(result, closeTo(438.71, 0.01));
    });

    test('should return 0.0 for zero amount', () {
      final result = calculateLoanEMI.execute(
        amount: 0,
        durationMonths: 24,
        annualRate: 5.0,
      );
      expect(result, 0.0);
    });

    test('should return 0.0 for zero duration', () {
      final result = calculateLoanEMI.execute(
        amount: 10000,
        durationMonths: 0,
        annualRate: 5.0,
      );
      expect(result, 0.0);
    });

    test('should handle high interest rates and amounts', () {
      final result = calculateLoanEMI.execute(
        amount: 500000,
        durationMonths: 360, // 30 years
        annualRate: 15.0,
      );
      // Expected EMI = 6322.22
      expect(result, closeTo(6322.22, 0.01));
    });
  });
}
