import '../../../../core/constants.dart';
import '../../../../core/utils/formatters.dart';
import 'comment_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String author;
  final String time;
  final String title;
  final String content;
  final String? image;
  final String? postImage;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final bool isAuthorVerified;
  final List<Comment> comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.author,
    required this.time,
    required this.title,
    required this.content,
    this.image,
    this.postImage,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
    this.isSaved = false,
    this.isAuthorVerified = false,
    this.comments = const [],
  });

  PostModel copyWith({
    String? id,
    String? userId,
    String? author,
    String? time,
    String? title,
    String? content,
    String? image,
    String? postImage,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    bool? isAuthorVerified,
    List<Comment>? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      author: author ?? this.author,
      time: time ?? this.time,
      title: title ?? this.title,
      content: content ?? this.content,
      image: image ?? this.image,
      postImage: postImage ?? this.postImage,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isAuthorVerified: isAuthorVerified ?? this.isAuthorVerified,
      comments: comments ?? this.comments,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Advanced boolean parser
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    // Safe date parser
    String parseDate(dynamic value) {
      if (value == null) return 'الآن';
      final str = value.toString();
      final date = DateFormatter.parseIso(str);
      if (date != null) {
        return DateFormatter.formatRelative(date);
      }
      return str;
    }

    return PostModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ??
          json['user']?['id']?.toString() ??
          '',
      author: json['author'] ?? json['user']?['name'] ?? 'مستخدم مجهول',
      time: parseDate(json['time'] ?? json['created_at']),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      image: AppConstants.buildUrl(json['image'] ?? json['user']?['profile_image'] ?? json['user']?['profile_photo_url']),
      postImage: AppConstants.buildUrl(json['post_image'] ?? json['image_url']),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: parseBool(json['is_liked']),
      isSaved: parseBool(json['is_saved']),
      isAuthorVerified: parseBool(json['is_verified'] ?? json['user']?['is_verified']),
      comments: json['comments'] != null
          ? (json['comments'] as List).map((i) => Comment.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': postImage,
    };
  }
}
