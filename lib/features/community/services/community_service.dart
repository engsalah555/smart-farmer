import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/comment_model.dart';
import '../../../core/services/base_api_service.dart';
import '../../../core/models/paginated_response.dart';

import '../../../core/services/persistence_service.dart';
import '../../../core/services/locator.dart';

class CommunityService extends BaseApiService {
  CommunityService(super.dio);

  Future<PaginatedResponse<PostModel>> getPosts({int page = 1, int perPage = 10}) async {
    return await get<PaginatedResponse<PostModel>>(
          AppConstants.communityPostsUrl,
          queryParameters: {'page': page, 'per_page': perPage},
          mapper: (data) {
            final response = PaginatedResponse.fromJson(
              data,
              (json) => PostModel.fromJson(json),
            );
            
            // Cache first page for offline access
            if (page == 1) {
              try {
                locator<PersistenceService>().save('offline_cache', 'cached_posts', data['data']);
              } catch (e) {
                debugPrint('Persistence cache write error: $e');
              }
            }
            
            return response;
          },
        ) ??
        PaginatedResponse(data: [], meta: PaginationMeta(currentPage: 1, lastPage: 1, perPage: perPage, total: 0));
  }

  Future<Map<String, dynamic>> toggleLike(String postId) async {
    return await post<Map<String, dynamic>>(
          '${AppConstants.communityPostsUrl}/$postId/like',
          mapper: (data) => data as Map<String, dynamic>,
        ) ??
        {};
  }

  Future<Map<String, dynamic>> toggleSave(String postId) async {
    return await post<Map<String, dynamic>>(
          '${AppConstants.communityPostsUrl}/$postId/save',
          mapper: (data) => data as Map<String, dynamic>,
        ) ??
        {};
  }

  Future<Comment?> addComment(String postId, String content) async {
    return await post<Comment>(
      '${AppConstants.communityPostsUrl}/$postId/comments',
      data: {'content': content},
      mapper: (data) => Comment.fromJson(data),
    );
  }

  Future<PaginatedResponse<Comment>> getComments(String postId, {int page = 1, int perPage = 15}) async {
    return await get<PaginatedResponse<Comment>>(
          '${AppConstants.communityPostsUrl}/$postId/comments',
          queryParameters: {'page': page, 'per_page': perPage},
          mapper: (data) => PaginatedResponse.fromJson(
            data,
            (json) => Comment.fromJson(json),
          ),
        ) ??
        PaginatedResponse(data: [], meta: PaginationMeta(currentPage: 1, lastPage: 1, perPage: perPage, total: 0));
  }

  Future<PostModel?> createPost(PostModel postModel, {File? imageFile}) async {
    dynamic data;
    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      data = FormData.fromMap({
        'title': postModel.title,
        'content': postModel.content,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
    } else {
      data = postModel.toJson();
    }

    return await post<PostModel>(
      AppConstants.communityPostsUrl,
      data: data,
      mapper: (data) => PostModel.fromJson(data),
    );
  }

  Future<PaginatedResponse<PostModel>> getSavedPosts({int page = 1, int perPage = 10}) async {
    return await get<PaginatedResponse<PostModel>>(
          AppConstants.savedPostsUrl,
          queryParameters: {'page': page, 'per_page': perPage},
          mapper: (data) => PaginatedResponse.fromJson(
            data,
            (json) => PostModel.fromJson(json),
          ),
        ) ??
        PaginatedResponse(data: [], meta: PaginationMeta(currentPage: 1, lastPage: 1, perPage: perPage, total: 0));
  }

  Future<PaginatedResponse<PostModel>> getMyPosts({int page = 1, int perPage = 10}) async {
    return await get<PaginatedResponse<PostModel>>(
          AppConstants.myPostsUrl,
          queryParameters: {'page': page, 'per_page': perPage},
          mapper: (data) => PaginatedResponse.fromJson(
            data,
            (json) => PostModel.fromJson(json),
          ),
        ) ??
        PaginatedResponse(data: [], meta: PaginationMeta(currentPage: 1, lastPage: 1, perPage: perPage, total: 0));
  }

  Future<PaginatedResponse<PostModel>> getActivityPosts({int page = 1, int perPage = 10}) async {
    return await get<PaginatedResponse<PostModel>>(
          AppConstants.userActivityUrl,
          queryParameters: {'page': page, 'per_page': perPage},
          mapper: (data) => PaginatedResponse.fromJson(
            data,
            (json) => PostModel.fromJson(json),
          ),
        ) ??
        PaginatedResponse(data: [], meta: PaginationMeta(currentPage: 1, lastPage: 1, perPage: perPage, total: 0));
  }

  Future<PostModel?> updatePost(
    String id,
    String content, {
    String? title,
    File? imageFile,
    bool removeImage = false,
  }) async {
    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      final data = FormData.fromMap({
        '_method': 'PUT',
        // ignore: use_null_aware_elements
        if (title != null) 'title': title,
        'content': content,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
      return await post<PostModel>(
        '${AppConstants.communityPostsUrl}/$id',
        data: data,
        mapper: (data) => PostModel.fromJson(data),
      );
    } else {
      final data = {
        'content': content,
        // ignore: use_null_aware_elements
        if (title != null) 'title': title,
        if (removeImage) 'remove_image': 'true',
      };
      return await put<PostModel>(
        '${AppConstants.communityPostsUrl}/$id',
        data: data,
        mapper: (data) => PostModel.fromJson(data),
      );
    }
  }

  Future<bool> deletePost(String id) async {
    return await delete('${AppConstants.communityPostsUrl}/$id');
  }

  Future<Comment?> updateComment(String id, String content) async {
    return await put<Comment>(
      '/community/comments/$id',
      data: {'content': content},
      mapper: (data) => Comment.fromJson(data),
    );
  }

  Future<bool> deleteComment(String id) async {
    return await delete('/community/comments/$id');
  }

  Future<bool> reportPost(String postId, String reason, {String? details}) async {
    return await post<bool>(
      '${AppConstants.communityPostsUrl}/$postId/report',
      data: {
        'reason': reason,
        'details': details,
      },
      mapper: (data) => true,
    ) ?? false;
  }
}
