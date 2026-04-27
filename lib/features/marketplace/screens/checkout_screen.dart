import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/helpers/image_helper.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/cart_provider.dart';
import '../providers/marketplace_provider.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedPaymentMethod = 'cash';
  File? _receiptImage;

  final Map<String, String> _paymentMethods = {
    'cash': 'نقدي عند الاستلام',
    'bank_transfer': 'حوالة بنكية / محفظة إلكترونية',
    'credit_card': 'بطاقة ائتمانية (قريباً)',
  };

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CartProvider>();

    if (_selectedPaymentMethod == 'bank_transfer' && _receiptImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء إرفاق صورة السند أو الحوالة الخاصة بك'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final success = await provider.checkout(
      paymentMethod: _selectedPaymentMethod,
      shippingAddress: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      receiptImagePath: _receiptImage?.path,
    );

    if (success) {
      if (mounted) {
        context.read<MarketplaceProvider>().loadMyOrders();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Icon(Icons.check_circle, color: context.primary, size: 60),
            content: const Text(
              'تم إرسال طلبك بنجاح، شكراً لتسوقك معنا.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  context.pop(); // close dialog
                  context.pop(); // return to marketplace
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'الاستمرار بالتسوق',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'فشل إتمام الشراء'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 15,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).hintColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        hintText: hint,
        suffixIcon: Icon(icon, color: context.primary, size: 22),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<CartProvider, bool>((p) => p.isLoading);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'إتمام الطلب',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: context.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'عنوان التوصيل',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildTextField(
                      controller: _addressController,
                      label: 'العنوان',
                      hint: 'المدينة، الحي، اسم الشارع ورقم المبنى',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                      validator: (val) => null,
                    ),
                    const SizedBox(height: 24),

                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'طريقة الدفع',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).cardTheme.color ?? Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPaymentMethod,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: context.primary,
                            ),
                          ),
                        ),
                        iconSize: 0,
                        isExpanded: true,
                        dropdownColor:
                            Theme.of(context).cardTheme.color ?? Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        alignment: Alignment.centerRight,
                        items: _paymentMethods.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            alignment: Alignment.centerRight,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedPaymentMethod = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Receipt Upload Section (only for bank transfer)
                    if (_selectedPaymentMethod == 'bank_transfer') ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'صورة السند / الحوالة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final img = await ImageHelper.pickImage(
                            context: context,
                            source: ImageSource.gallery,
                          );
                          if (img != null) {
                            setState(() => _receiptImage = img);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).cardTheme.color ??
                                Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _receiptImage != null
                                  ? context.primary
                                  : Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: _receiptImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _receiptImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 40,
                                      color: context.primary,
                                    ),
                                    SizedBox(height: 10),
                                    Text('انقر هنا لإرفاق صورة السند'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'ملاحظات إضافية (اختياري)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildTextField(
                      controller: _notesController,
                      label: 'ملاحظات',
                      hint: 'أي معلومات إضافية للتوصيل أو الطلب...',
                      icon: Icons.note_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _submitOrder(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'تأكيد الطلب',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
