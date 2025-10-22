import 'package:flutter/material.dart';

enum DateRange { sevenDays, thirtyDays, ninetyDays }

class RangeSelector extends StatelessWidget {
  final DateRange selectedRange;
  final Function(DateRange) onRangeChanged;

  const RangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRangeButton(context, '7d', DateRange.sevenDays),
            const SizedBox(width: 8),
            _buildRangeButton(context, '30d', DateRange.thirtyDays),
            const SizedBox(width: 8),
            _buildRangeButton(context, '90d', DateRange.ninetyDays),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeButton(
    BuildContext context,
    String label,
    DateRange range,
  ) {
    final isSelected = selectedRange == range;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onRangeChanged(range),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
