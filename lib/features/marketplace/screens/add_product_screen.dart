import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/models/product_model.dart';
import '../providers/seller_provider.dart';
import '../widgets/add_product/add_product_image_picker.dart';
import '../widgets/add_product/add_product_basic_info.dart';
import '../widgets/add_product/add_product_pricing_stock.dart';
import '../widgets/add_product/add_product_payment_methods.dart';
import '../widgets/add_product/add_product_text_field.dart';

/// صفحة إضافة منتج جديد أو تعديل منتج موجود - النسخة النظيفة والديناميكية (Backend-Driven)
class AddProductScreen extends StatefulWidget {
  final ProductModel? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCatalogId;
  String _selectedCategory = 'بذور';
  String _selectedUnit = 'كيلوجرام';

  final List<String> _selectedImages = [];
  final List<String> _selectedPaymentMethods = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final seller = context.read<SellerProvider>();
        final settings = context.read<SettingsProvider>();

        seller.loadMyCatalogs();

        if (settings.productCategories.isEmpty ||
            settings.paymentMethods.isEmpty) {
          await settings.loadMetadata();
        }

        // Initialize defaults from dynamic metadata
        if (widget.productToEdit == null && mounted) {
          setState(() {
            if (settings.productCategories.isNotEmpty) {
              _selectedCategory = settings.productCategories.first['id'];
            }
            if (settings.units.isNotEmpty) {
              _selectedUnit = settings.units.first;
            }
          });
        }
      }
    });
    _prefillFromEdit();
  }

  void _prefillFromEdit() {
    final p = widget.productToEdit;
    if (p == null) return;

    _titleController.text = p.title;
    _descriptionController.text = p.description;
    _priceController.text = p.price.toString();
    _quantityController.text = p.quantity.toString();
    _locationController.text = p.location;
    _phoneController.text = p.phoneNumber;
    _notesController.text = p.notes ?? '';

    _selectedCategory = p.category;
    _selectedUnit = p.unit;
    _selectedCatalogId = p.catalogId;
    _selectedPaymentMethods.addAll(p.paymentMethods);
    _selectedImages.addAll(p.images);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : context.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      _showSnackBar('يرجى إضافة صورة واحدة على الأقل', isError: true);
      return;
    }
    if (_selectedPaymentMethods.isEmpty) {
      _showSnackBar('يرجى اختيار طريقة دفع واحدة على الأقل', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final sellerId = auth.currentUser?.id ?? '';
    final storeName = auth.currentUser?.name ?? '';

    final product = ProductModel(
      id: widget.productToEdit?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      price: double.tryParse(_priceController.text) ?? 0.0,
      unit: _selectedUnit,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      storeName: storeName,
      storeId: sellerId,
      images: _selectedImages,
      paymentMethods: _selectedPaymentMethods,
      location: _locationController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      catalogId: _selectedCatalogId,
      notes: _notesController.text.trim(),
      createdAt: widget.productToEdit?.createdAt ?? DateTime.now(),
      sellerId: sellerId,
    );

    final provider = context.read<SellerProvider>();
    final bool success;

    final localImages = _selectedImages
        .where((path) => !path.startsWith('http'))
        .toList();
    final imagePath = localImages.isNotEmpty ? localImages.first : null;
    final otherImages = localImages.length > 1 ? localImages.sublist(1) : null;

    if (widget.productToEdit != null) {
      success = await provider.updateProduct(
        product,
        imagePath: imagePath,
        otherImagePaths: otherImages,
      );
    } else {
      success = await provider.addProduct(
        product,
        imagePath: imagePath,
        otherImagePaths: otherImages,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _showSnackBar('تمت العملية بنجاح');
      context.pop();
    } else {
      _showSnackBar(provider.errorMessage ?? 'فشلت العملية', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (settings.isLoading && settings.productCategories.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل إعدادات المتجر...'),
            ],
          ),
        ),
      );
    }

    if (settings.errorMessage != null && settings.productCategories.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(settings.errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => settings.loadMetadata(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productToEdit != null ? 'تعديل المنتج' : 'إضافة منتج جديد',
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('صور المنتج'),
            AddProductImagePicker(
              selectedImages: _selectedImages,
              onImageAdded: (path) => setState(() => _selectedImages.add(path)),
              onImageRemoved: (index) =>
                  setState(() => _selectedImages.removeAt(index)),
              showSnackBar: (msg, {isError = false}) =>
                  _showSnackBar(msg, isError: isError),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('المعلومات الأساسية'),
            AddProductBasicInfo(
              titleController: _titleController,
              descriptionController: _descriptionController,
              selectedCategory: _selectedCategory,
              selectedCatalogId: _selectedCatalogId,
              onCategoryChanged: (v) => setState(() => _selectedCategory = v),
              onCatalogChanged: (v) => setState(() => _selectedCatalogId = v),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('السعر والكمية'),
            AddProductPricingStock(
              priceController: _priceController,
              quantityController: _quantityController,
              selectedUnit: _selectedUnit,
              onUnitChanged: (v) => setState(() => _selectedUnit = v),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('معلومات التواصل والموقع'),
            AddProductTextField(
              controller: _locationController,
              label: 'الموقع/المدينة',
              hint: 'مثال: صنعاء',
              icon: Icons.location_on_outlined,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'يرجى إدخال الموقع' : null,
            ),
            const SizedBox(height: 16),
            AddProductTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              hint: '05xxxxxxxx',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'يرجى إدخال رقم الهاتف' : null,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('طرق الدفع'),
            AddProductPaymentMethods(
              selectedPaymentMethods: _selectedPaymentMethods,
              onMethodToggled: (id) => setState(() {
                _selectedPaymentMethods.contains(id)
                    ? _selectedPaymentMethods.remove(id)
                    : _selectedPaymentMethods.add(id);
              }),
            ),
            const SizedBox(height: 32),

            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _isSubmitting
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              widget.productToEdit != null ? 'تعديل المنتج' : 'إضافة المنتج',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
