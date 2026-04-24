import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/catalog_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../providers/seller_provider.dart';

class ProductAssignmentDialog extends StatefulWidget {
  final CatalogModel catalog;

  const ProductAssignmentDialog({super.key, required this.catalog});

  static void show(BuildContext context, {required CatalogModel catalog}) {
    showDialog(
      context: context,
      builder: (context) => ProductAssignmentDialog(catalog: catalog),
    );
  }

  @override
  State<ProductAssignmentDialog> createState() =>
      _ProductAssignmentDialogState();
}

class _ProductAssignmentDialogState extends State<ProductAssignmentDialog> {
  late List<String> selectedProductIds;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SellerProvider>();
    final allProducts = provider.myProducts;
    selectedProductIds = allProducts
        .where((p) => p.catalogId == widget.catalog.id)
        .map((p) => p.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SellerProvider>();
    final allProducts = provider.myProducts;

    return AlertDialog(
      title: Text('إضافة منتجات لـ ${widget.catalog.name}'),
      backgroundColor: context.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.maxFinite,
        child: allProducts.isEmpty
            ? const Center(child: Text('لا يوجد لديك منتجات حالياً'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: allProducts.length,
                itemBuilder: (context, index) {
                  final product = allProducts[index];
                  final isSelected = selectedProductIds.contains(product.id);
                  final isInOtherCatalog =
                      product.catalogId != null &&
                      product.catalogId != widget.catalog.id;

                  return CheckboxListTile(
                    title: Text(product.title),
                    subtitle: isInOtherCatalog
                        ? const Text(
                            'موجود في كتالوج آخر',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    secondary: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImage(
                        imageUrl: product.images.isNotEmpty
                            ? product.images.first
                            : '',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedProductIds.add(product.id);
                        } else {
                          selectedProductIds.remove(product.id);
                        }
                      });
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            context.pop();

            final success = await provider.assignProductsToCatalog(
              widget.catalog.id,
              selectedProductIds,
            );

            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'تم تحديث المنتجات بنجاح'
                        : 'حدث خطأ في تحديث المنتجات',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
