/// أدوات التحقق من صحة البيانات
class Validators {
  /// التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// التحقق من كلمة المرور
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    if (value.length < minLength) {
      return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل';
    }

    return null;
  }

  /// التحقق من رقم الجوال
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الجوال';
    }

    // رقم سعودي: يبدأ بـ 05 ويتكون من 10 أرقام
    final phoneRegex = RegExp(r'^05\d{8}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'رقم الجوال غير صحيح (يجب أن يبدأ بـ 05)';
    }

    return null;
  }

  /// التحقق من حقل مطلوب
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? 'يرجى إدخال $fieldName' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// التحقق من الحد الأدنى للطول
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // استخدم validateRequired للتحقق من الحقول المطلوبة
    }

    if (value.length < minLength) {
      return fieldName != null
          ? '$fieldName يجب أن يكون $minLength أحرف على الأقل'
          : 'يجب أن يكون $minLength أحرف على الأقل';
    }

    return null;
  }

  /// التحقق من الحد الأقصى للطول
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return fieldName != null
          ? '$fieldName يجب ألا يتجاوز $maxLength حرف'
          : 'يجب ألا يتجاوز $maxLength حرف';
    }

    return null;
  }

  /// التحقق من الأرقام فقط
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return fieldName != null
          ? '$fieldName يجب أن يحتوي على أرقام فقط'
          : 'يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  /// التحقق من تطابق كلمتي المرور
  static String? validatePasswordMatch(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }

    if (value != originalPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  /// التحقق من السعر
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال السعر';
    }

    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'السعر غير صحيح';
    }

    return null;
  }

  /// التحقق من الكمية
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الكمية';
    }

    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'الكمية غير صحيحة';
    }

    return null;
  }
}
