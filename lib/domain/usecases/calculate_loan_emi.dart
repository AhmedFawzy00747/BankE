import 'dart:math';

class CalculateLoanEMI {
  double execute({
    required double amount,
    required int durationMonths,
    required double annualRate,
  }) {
    if (amount <= 0 || durationMonths <= 0) return 0.0;

    final monthlyRate = annualRate / 12 / 100;
    
    // EMI = [P x R x (1+R)^N]/[(1+R)^N-1]
    final p1 = pow(1 + monthlyRate, durationMonths);
    final emi = (amount * monthlyRate * p1) / (p1 - 1);

    return emi.isNaN || emi.isInfinite ? 0.0 : emi;
  }
}
