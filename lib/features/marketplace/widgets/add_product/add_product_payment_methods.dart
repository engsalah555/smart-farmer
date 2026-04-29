import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../core/providers/settings_provider.dart';

class AddProductPaymentMethods extends StatelessWidget {
  final List<String> selectedPaymentMethods;
  final Function(String) onMethodToggled;

  const AddProductPaymentMethods({
    super.key,
    required this.selectedPaymentMethods,
    required this.onMethodToggled,
  });

  @override
  Widget build(BuildContext context) {
    final availableMethods = context.watch<SettingsProvider>().paymentMethods;

    if (availableMethods.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'طرق الدفع المفضلة',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableMethods.map((method) {
            final isSelected = selectedPaymentMethods.contains(method['id']);
            return ChoiceChip(
              avatar: method['icon'] != null ? Icon(
                _getIconData(method['icon']),
                size: 18,
                color: isSelected ? context.primary : Colors.grey,
              ) : null,
              label: Text(method['label']),
              selected: isSelected,
              onSelected: (_) => onMethodToggled(method['id']),
              selectedColor: context.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? context.primary
                    : Theme.of(context).hintColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? context.primary
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'cash':
        return Icons.payments_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'bank':
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      default:
        return Icons.payment_outlined;
    }
  }
}
