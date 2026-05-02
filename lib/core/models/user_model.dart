import '../constants.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String userType; // 'farmer', 'merchant', or 'user'
  final String? phone;
  final String? profileImage;
  final String? customTitle; // اللقب المخصص (مثل مزارع منتج، وكيل معتمد)
  final bool isVerified;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phone,
    this.profileImage,
    this.customTitle,
    this.isVerified = false,
    this.createdAt,
  });

  // ✅ صلاحيات السوق
  /// Alias for role
  String get role => userType;

  /// هل المستخدم تاجر أو مزارع (بائع)
  bool get isSeller =>
      userType.toLowerCase() == 'seller' ||
      userType.toLowerCase() == 'admin' ||
      // التوافق مع البيانات القديمة
      userType.toLowerCase() == 'merchant' ||
      userType.toLowerCase() == 'farmer';

  /// هل المستخدم العادي (مشتري فقط)؟
  bool get isRegularUser => userType.toLowerCase() == 'user';

  /// هل يستطيع فتح متجر والبيع؟ (البائعون)
  bool get canSell => isSeller;

  /// هل يستطيع الشراء من السوق؟ (الجميع)
  bool get canBuy => true;

  /// هل يستطيع إضافة منتجات؟ (البائعون الموثقون)
  bool get canAddProducts => canSell;

  /// رسالة توضيحية للصلاحيات
  String get permissionMessage {
    if (isSeller && !isVerified) {
      return 'حسابك قيد المراجعة. سيتم تفعيل البيع بعد التحقق.';
    } else if (isSeller && isVerified) {
      return 'يمكنك البيع والشراء في السوق';
    } else {
      return 'يمكنك الشراء من السوق فقط';
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // ✅ الباكند يُرسل 'profile_photo_url' (accessor كامل URL) من AuthController
    // و 'profile_image' هو العمود الخام. نُفضّل الـ accessor إذا كان موجوداً.
    final rawPhoto =
        json['profile_photo_url']?.toString() ??
        json['profile_image']?.toString() ??
        json['profileImage']?.toString();

    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userType:
          json['user_type'] ?? json['userType'] ?? json['role'] ?? 'user',
      phone: json['phone'],
      profileImage: AppConstants.buildUrl(rawPhoto),
      customTitle: json['custom_title'] ?? json['customTitle'],
      isVerified:
          json['is_verified'] == 1 ||
          json['is_verified'] == true ||
          json['isVerified'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : (json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'])
                : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      'phone': phone,
      'profileImage': profileImage,
      'customTitle': customTitle,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? userType,
    String? phone,
    String? profileImage,
    String? customTitle,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      customTitle: customTitle ?? this.customTitle,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// للتوافق مع الكود القديم
typedef UserModel = User;
