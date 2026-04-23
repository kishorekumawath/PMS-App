import 'package:flutter/material.dart';

import '../../../domain/entities/property.dart';

class PropertyStatusBadge extends StatelessWidget {
  final PropertyStatus status;

  const PropertyStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final isOccupied = status == PropertyStatus.occupied;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOccupied
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOccupied ? 'Occupied' : 'Vacant',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isOccupied ? Colors.green.shade700 : Colors.orange.shade800,
        ),
      ),
    );
  }
}
