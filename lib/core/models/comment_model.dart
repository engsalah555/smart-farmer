import '../constants.dart';

/// نموذج التعليق على المنشورات
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final bool isVerified;
  
  String get createdAtFormatted {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    }
  }

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    this.isVerified = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Advanced boolean parser
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    // Safe user name parser
    String parseUserName(dynamic user) {
      if (user == null) return 'مستخدم';
      if (user is String) return user;
      if (user is Map) return user['name'] ?? 'مستخدم';
      return 'مستخدم';
    }

    return Comment(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? json['postId']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: json['userName'] ?? parseUserName(json['user']),
      userAvatar: AppConstants.buildUrl(json['userAvatar'] ?? (json['user'] is Map ? json['user']['profile_image'] : null)),
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
      likes: json['likes_count'] ?? json['likes'] ?? 0,
      isLiked: parseBool(json['is_liked'] ?? json['isLiked']),
      isVerified: parseBool(json['is_verified'] ?? json['isVerified'] ?? (json['user'] is Map ? json['user']['is_verified'] : null)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
      'isVerified': isVerified,
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    DateTime? createdAt,
    int? likes,
    bool? isLiked,
    bool? isVerified,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
