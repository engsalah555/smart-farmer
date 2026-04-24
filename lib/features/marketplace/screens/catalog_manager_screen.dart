import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farm2/features/marketplace/widgets/catalog_dialog.dart';

import '../../../core/constants.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../providers/seller_provider.dart';
import '../../../core/models/catalog_model.dart';

class CatalogManagerScreen extends StatefulWidget {
  const CatalogManagerScreen({super.key});

  @override
  State<CatalogManagerScreen> createState() => _CatalogManagerScreenState();
}

class _CatalogManagerScreenState extends State<CatalogManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showProductAssignmentDialog(CatalogModel catalog) {
    final provider = context.read<SellerProvider>();
    final allProducts = provider.myProducts;

    // Initial selected products (those already in this catalog)
    List<String> selectedProductIds = allProducts
        .where((p) => p.catalogId == catalog.id)
        .map((p) => p.id)
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('إضافة منتجات لـ ${catalog.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: allProducts.isEmpty
                  ? const Center(child: Text('لا يوجد لديك منتجات حالياً'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: allProducts.length,
                      itemBuilder: (context, index) {
                        final product = allProducts[index];
                        final isSelected = selectedProductIds.contains(
                          product.id,
                        );
                        final isInOtherCatalog =
                            product.catalogId != null &&
                            product.catalogId != catalog.id;

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
                            setDialogState(() {
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
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  context.pop();

                  final success = await provider.assignProductsToCatalog(
                    catalog.id,
                    selectedProductIds,
                  );

                  if (context.mounted) {
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<SellerProvider, bool>((p) => p.isLoading);
    final catalogs = context.select<SellerProvider, List<CatalogModel>>(
      (p) => p.myCatalogs,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة الكتالوجات')),
        body: isLoading && catalogs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : catalogs.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: catalogs.length,
                itemBuilder: (context, index) {
                  final catalog = catalogs[index];
                  return FadeInSlide(
                    delay: Duration(milliseconds: 50 * index),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppColors.cardLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child:
                                catalog.imageUrl != null &&
                                    catalog.imageUrl!.isNotEmpty
                                ? CustomImage(
                                    imageUrl: catalog.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.category_outlined,
                                    color: AppColors.primary,
                                  ),
                          ),
                        ),
                        title: Text(
                          catalog.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          catalog.description.isEmpty
                              ? 'بدون وصف'
                              : catalog.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                color: AppColors.primary,
                              ),
                              onPressed: () =>
                                  _showProductAssignmentDialog(catalog),
                              tooltip: 'إدارة المنتجات',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: () =>
                                  CatalogDialog.show(context, catalog: catalog),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _showDeleteConfirmation(context, catalog),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: catalogs.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => CatalogDialog.show(context),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'كتالوج جديد',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CatalogModel catalog) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الكتالوج'),
        content: Text(
          'هل أنت متأكد من حذف الكتالوج "${catalog.name}"؟ لن يتم حذف المنتجات المرتبطة به ولكنها ستفقد تصنيفها.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final provider = context.read<SellerProvider>();
              final success = await provider.deleteCatalog(catalog.id);
              if (context.mounted) {
                context.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? 'تم الحذف' : 'فشل في الحذف'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد كتالوجات حالياً',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'قم بإنشاء كتالوجات لتنظيم منتجاتك وتسهيل عرضها.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => CatalogDialog.show(context),
            icon: const Icon(Icons.add),
            label: const Text('إنشاء أول كتالوج'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
