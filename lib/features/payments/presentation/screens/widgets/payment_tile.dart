import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../domain/entities/payment.dart';
import 'payment_status_chip.dart';

class PaymentTile extends StatelessWidget {
  final Payment payment;
  final String tenantName;
  final String propertyName;
  final VoidCallback onDelete;
  final VoidCallback onMarkPaid;

  const PaymentTile({
    super.key,
    required this.payment,
    required this.tenantName,
    required this.propertyName,
    required this.onDelete,
    required this.onMarkPaid,
  });

  bool get _canMarkPaid =>
      payment.status == PaymentStatus.pending ||
      payment.status == PaymentStatus.overdue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(payment.id),
      // Allow right-swipe only when payment can still be marked as paid.
      direction: _canMarkPaid
          ? DismissDirection.horizontal
          : DismissDirection.endToStart,

      // Right-swipe → Mark as Paid (green).
      background: _canMarkPaid
          ? Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 28),
                  SizedBox(height: 4),
                  Text('Mark Paid',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : const SizedBox.shrink(),

      // Left-swipe → Delete (red).
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as paid — confirm only if overdue (extra care).
          if (payment.status == PaymentStatus.overdue) {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Mark as Paid'),
                content: Text(
                    'Mark this overdue payment of ${CurrencyFormatter.format(payment.amount)} as paid today?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade600),
                    child: const Text('Mark Paid'),
                  ),
                ],
              ),
            );
          }
          // Pending — mark directly without dialog.
          return true;
        }

        // Delete — always confirm.
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Payment'),
            content:
                const Text('Delete this payment record? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style:
                    FilledButton.styleFrom(backgroundColor: colorScheme.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },

      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onMarkPaid();
        } else {
          onDelete();
        }
      },

      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long,
                    color: colorScheme.onPrimaryContainer, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tenantName,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(payment.amount),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      propertyName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        PaymentStatusChip(payment.status),
                        const Spacer(),
                        Icon(Icons.calendar_today_outlined,
                            size: 12, color: colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          'Due ${DateFormatter.format(payment.dueDate)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                      ],
                    ),
                    if (payment.paidDate != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 12, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Paid ${DateFormatter.format(payment.paidDate!)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ],
                    if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        payment.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
