import 'package:flutter/material.dart';

import '../../../domain/entities/payment.dart';

class PaymentStatusChip extends StatelessWidget {
  final PaymentStatus status;

  const PaymentStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      PaymentStatus.paid => (
          'Paid',
          Colors.green.withValues(alpha: 0.12),
          Colors.green.shade700,
        ),
      PaymentStatus.pending => (
          'Pending',
          Colors.amber.withValues(alpha: 0.15),
          Colors.amber.shade800,
        ),
      PaymentStatus.overdue => (
          'Overdue',
          Colors.red.withValues(alpha: 0.12),
          Colors.red.shade700,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
