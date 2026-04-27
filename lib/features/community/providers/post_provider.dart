import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/models/post_model.dart';
import '../../../core/providers/base_provider.dart';
import '../services/community_service.dart';

class PostProvider extends BaseProvider {
  final CommunityService _service;

  // O(1) Store
  final Map<String, PostModel> _postStore = {};

  // ID Lists
  List<String> _postIds = [];
  List<String> _myPostIds = [];
  List<String> _savedPostIds = [];
  List<String> _activityPostIds = [];

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  List<String> get postIds => _postIds;
  List<String> get myPostIds => _myPostIds;
  List<String> get savedPostIds => _savedPostIds;
  List<String> get activityPostIds => _activityPostIds;

  PostModel? getPost(String id) => _postStore[id];
  List<PostModel> getAllPosts() => _postStore.values.toList();

  PostProvider(this._service);

  Future<void> init() async {
    await fetchPosts();
  }

  void _addPostsToStore(List<PostModel> fetchedPosts) {
    for (var post in fetchedPosts) {
      _postStore[post.id] = post;
    }
  }

  Future<void> fetchPosts({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore) return;

    final result = await execute(() => _service.getPosts(page: _currentPage));
    if (result != null) {
      _addPostsToStore(result.data);

      final newIds = result.data.map((p) => p.id).toList();

      if (refresh) {
        _postIds = newIds;
      } else {
        _postIds.addAll(newIds);
      }
      _currentPage = result.meta.currentPage + 1;
      _hasMore = result.meta.hasMore;
      
      notifyListeners();
    }
  }

  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    
    await fetchPosts(refresh: false);
    
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchMyPosts() async {
    final result = await execute(() => _service.getMyPosts());
    if (result != null) {
      _addPostsToStore(result.data);
      _myPostIds = result.data.map((p) => p.id).toList();
      notifyListeners();
    }
  }

  Future<void> fetchActivityPosts() async {
    final result = await execute(() => _service.getActivityPosts());
    if (result != null) {
      _addPostsToStore(result.data);
      _activityPostIds = result.data.map((p) => p.id).toList();
      notifyListeners();
    }
  }

  Future<void> fetchSavedPosts() async {
    final result = await execute(() => _service.getSavedPosts());
    if (result != null) {
      _addPostsToStore(result.data);
      _savedPostIds = result.data.map((p) => p.id).toList();
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final originalPost = _postStore[postId];
    if (originalPost == null) return;

    // Optimistically update
    final newIsLiked = !originalPost.isLiked;
    _postStore[postId] = originalPost.copyWith(
      isLiked: newIsLiked,
      likesCount: originalPost.likesCount + (newIsLiked ? 1 : -1),
    );
    notifyListeners();

    try {
      final result = await _service.toggleLike(postId);
      // Ensure local state matches server just in case
      final currentPost = _postStore[postId];
      if (currentPost != null) {
        _postStore[postId] = currentPost.copyWith(
          isLiked: result['is_liked'],
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling like, rolling back: $e');
      // Rollback on error
      _postStore[postId] = originalPost;
      notifyListeners();
    }
  }

  Future<void> toggleSave(String postId) async {
    final originalPost = _postStore[postId];
    if (originalPost == null) return;

    // Optimistically update
    final newIsSaved = !originalPost.isSaved;
    _postStore[postId] = originalPost.copyWith(isSaved: newIsSaved);
    notifyListeners();

    try {
      final result = await _service.toggleSave(postId);
      final currentPost = _postStore[postId];
      if (currentPost != null) {
        _postStore[postId] = currentPost.copyWith(isSaved: result['is_saved']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling save: $e');
      _postStore[postId] = originalPost;
      notifyListeners();
    }
  }

  // Called from CommentProvider when a comment is added/deleted
  void updateCommentCount(String postId, int newCount) {
    final post = _postStore[postId];
    if (post != null) {
      _postStore[postId] = post.copyWith(commentsCount: newCount);
      notifyListeners();
    }
  }

  Future<void> addPost(PostModel post, {File? imageFile}) async {
    final newPost = await execute(
      () => _service.createPost(post, imageFile: imageFile),
    );
    if (newPost != null) {
      PostModel finalPost = newPost;
      // If the backend didn't return the postImage immediately, but we uploaded an image,
      // optimistically set it to the local file path.
      if ((finalPost.postImage == null || finalPost.postImage!.isEmpty || finalPost.postImage!.endsWith('/null')) && imageFile != null) {
        finalPost = finalPost.copyWith(postImage: imageFile.path);
      }

      _postStore[finalPost.id] = finalPost;
      _postIds.insert(0, finalPost.id);
      if (!_myPostIds.contains(finalPost.id)) {
        _myPostIds.insert(0, finalPost.id);
      }
      notifyListeners();
    }
  }

  Future<void> editPost(
    String id,
    String content, {
    String? title,
    File? imageFile,
    bool removeImage = false,
  }) async {
    final updatedPost = await execute(
      () => _service.updatePost(
        id,
        content,
        title: title,
        imageFile: imageFile,
        removeImage: removeImage,
      ),
    );
    if (updatedPost != null) {
      final oldPost = _postStore[id];
      _postStore[id] = updatedPost.copyWith(
        comments: oldPost?.comments ?? [],
        isLiked: oldPost?.isLiked ?? updatedPost.isLiked,
        isSaved: oldPost?.isSaved ?? updatedPost.isSaved,
      );
      notifyListeners();
    }
  }

  Future<void> deletePost(String id) async {
    final success = await execute(() => _service.deletePost(id));
    if (success == true) {
      _postStore.remove(id);
      _postIds.remove(id);
      _myPostIds.remove(id);
      _savedPostIds.remove(id);
      _activityPostIds.remove(id);
      notifyListeners();
    }
  }

  Future<bool> reportPost(String postId, String reason, {String? details}) async {
    final success = await execute(
      () => _service.reportPost(postId, reason, details: details),
    );
    if (success == true) {
      // Opt out of showing this post locally for the user who reported it
      _postStore.remove(postId);
      _postIds.remove(postId);
      _myPostIds.remove(postId);
      _activityPostIds.remove(postId);
      _savedPostIds.remove(postId);
      notifyListeners();
      return true;
    }
    return false;
  }
}
