import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/catalog_model.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../providers/seller_provider.dart';
import 'add_product_text_field.dart';

class AddProductBasicInfo extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final String? selectedCatalogId;
  final Function(String) onCategoryChanged;
  final Function(String?) onCatalogChanged;

  const AddProductBasicInfo({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedCatalogId,
    required this.onCategoryChanged,
    required this.onCatalogChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = settings.productCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddProductTextField(
          controller: titleController,
          label: 'اسم المنتج',
          hint: 'مثال: بذور طماطم هجين',
          icon: Icons.shopping_bag_outlined,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'يرجى إدخال اسم المنتج' : null,
        ),
        const SizedBox(height: 16),
        AddProductTextField(
          controller: descriptionController,
          label: 'الوصف',
          hint: 'وصف تفصيلي للمنتج...',
          icon: Icons.description_outlined,
          maxLines: 4,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'يرجى إدخال وصف المنتج' : null,
        ),
        const SizedBox(height: 16),
        if (categories.isNotEmpty) ...[
          _buildCategoryDropdown(context, categories),
          const SizedBox(height: 16),
        ],
        _buildCatalogDropdown(context),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, List<Map<String, dynamic>> categories) {
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
        initialValue: categories.any((c) => c['id'] == selectedCategory) ? selectedCategory : categories.first['id'],
        iconSize: 0,
        isExpanded: true,
        dropdownColor: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        alignment: Alignment.centerRight,
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.green),
          ),
        ),
        items: categories
            .map((c) => DropdownMenuItem<String>(
                  value: c['id'],
                  alignment: Alignment.centerRight,
                  child: Text(c['label']),
                ))
            .toList(),
        onChanged: (value) => onCategoryChanged(value!),
      ),
    );
  }

  Widget _buildCatalogDropdown(BuildContext context) {
    final catalogs = context.select<SellerProvider, List<CatalogModel>>(
      (p) => p.myCatalogs,
    );
    if (catalogs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الكتالوج (اختياري)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: selectedCatalogId,
            hint: const Text('اختر كتالوج للمنتج'),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('بدون كتالوج')),
              ...catalogs.map(
                (c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: onCatalogChanged,
          ),
        ),
      ],
    );
  }
}
