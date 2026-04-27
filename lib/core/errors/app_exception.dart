
class AppException implements Exception {
  final String message;
  final String? technicalMessage;
  final int? statusCode;

  AppException({
    required this.message,
    this.technicalMessage,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({super.technicalMessage})
      : super(
          message: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',
        );
}

class ServerException extends AppException {
  ServerException({String? message, super.statusCode, super.technicalMessage})
      : super(
          message: message ?? 'فشل الاتصال بالخادم. حاول مرة أخرى لاحقاً.',
        );
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException({String? message, this.errors})
      : super(
          message: message ?? 'البيانات المدخلة غير صحيحة.',
          statusCode: 422,
        );
}

class AuthenticationException extends AppException {
  AuthenticationException({String? message})
      : super(
          message: message ?? 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.',
          statusCode: 401,
        );
}
