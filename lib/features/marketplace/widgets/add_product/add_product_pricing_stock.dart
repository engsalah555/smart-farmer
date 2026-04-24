import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/settings_provider.dart';
import 'add_product_text_field.dart';

class AddProductPricingStock extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final String selectedUnit;
  final Function(String) onUnitChanged;

  const AddProductPricingStock({
    super.key,
    required this.priceController,
    required this.quantityController,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final units = context.watch<SettingsProvider>().units;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AddProductTextField(
                controller: priceController,
                label: 'السعر (ريال)',
                hint: '0.00',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى إدخال السعر';
                  if (double.tryParse(v) == null) return 'أدخل رقم صحيح';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            if (units.isNotEmpty)
              Expanded(
                child: _buildUnitDropdown(context, units),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AddProductTextField(
          controller: quantityController,
          label: 'الكمية المتوفرة',
          hint: 'مثال: 50',
          icon: Icons.inventory_2_outlined,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'يرجى إدخال الكمية';
            if (int.tryParse(v) == null) return 'أدخل رقم صحيح';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUnitDropdown(BuildContext context, List<String> units) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: units.contains(selectedUnit) ? selectedUnit : units.first,
        iconSize: 0,
        alignment: Alignment.center,
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.green),
        ),
        items: units
            .map((u) => DropdownMenuItem(
                  value: u,
                  alignment: Alignment.center,
                  child: Text(u),
                ))
            .toList(),
        onChanged: (v) => onUnitChanged(v!),
      ),
    );
  }
}
