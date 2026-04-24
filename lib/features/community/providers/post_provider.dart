import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/models/post_model.dart';
import '../../../core/models/comment_model.dart';
import '../../../core/providers/base_provider.dart';
import '../services/community_service.dart';

class PostProvider extends BaseProvider {
  final CommunityService _service;

  List<PostModel> _posts = [];
  List<PostModel> _myPosts = [];
  List<PostModel> _savedPosts = [];
  List<PostModel> _activityPosts = [];
  final Map<String, List<Comment>> _postComments = {};
  final Map<String, bool> _commentsLoading = {};

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  List<PostModel> get posts => _posts;
  List<PostModel> get myPosts => _myPosts;
  List<PostModel> get savedPosts => _savedPosts;
  List<PostModel> get activityPosts => _activityPosts;
  List<Comment> getComments(String postId) => _postComments[postId] ?? [];
  bool isCommentsLoading(String postId) => _commentsLoading[postId] ?? false;

  PostProvider(this._service);

  Future<void> init() async {
    await fetchPosts();
  }

  Future<void> fetchPosts({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore) return;

    final result = await execute(() => _service.getPosts(page: _currentPage));
    if (result != null) {
      if (refresh) {
        _posts = result.data;
      } else {
        _posts.addAll(result.data);
      }
      _currentPage = result.meta.currentPage + 1;
      _hasMore = result.meta.hasMore;
      
      _syncComments(result.data);
      
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
      _myPosts = result.data;
      _syncComments(result.data);
      notifyListeners();
    }
  }

  Future<void> fetchActivityPosts() async {
    final result = await execute(() => _service.getActivityPosts());
    if (result != null) {
      _activityPosts = result.data;
      _syncComments(result.data);
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    // Save current state for potential rollback
    PostModel? originalPost;
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) originalPost = _posts[index];

    // Optimistically update
    _updatePostInLists(postId, (post) {
      final newIsLiked = !post.isLiked;
      return post.copyWith(
        isLiked: newIsLiked,
        likesCount: post.likesCount + (newIsLiked ? 1 : -1),
      );
    });

    try {
      final result = await _service.toggleLike(postId);
      // Ensure local state matches server just in case
      _updatePostInLists(postId, (post) {
        return post.copyWith(
          isLiked: result['is_liked'],
          likesCount: post.likesCount, // Keep the optimistic count or sync if reliable
        );
      });
    } catch (e) {
      debugPrint('Error toggling like, rolling back: $e');
      // Rollback on error
      if (originalPost != null) {
        _updatePostInLists(postId, (post) => originalPost!);
      }
    }
  }

  Future<void> toggleSave(String postId) async {
    try {
      final result = await _service.toggleSave(postId);
      _updatePostInLists(postId, (post) {
        return post.copyWith(isSaved: result['is_saved']);
      });
    } catch (e) {
      debugPrint('Error toggling save: $e');
    }
  }

  Future<void> fetchComments(String postId) async {
    _commentsLoading[postId] = true;
    notifyListeners();

    try {
      final result = await _service.getComments(postId);
      _postComments[postId] = result.data;
      // Update the post in lists to have the full comment list too if needed
      _updatePostInLists(postId, (post) => post.copyWith(comments: result.data));
    } finally {
      _commentsLoading[postId] = false;
      notifyListeners();
    }
  }

  Future<void> addComment(String postId, String content) async {
    final newComment = await execute(
      () => _service.addComment(postId, content),
    );
    if (newComment != null) {
      // Update the comments map
      if (_postComments.containsKey(postId)) {
        _postComments[postId] = [..._postComments[postId]!, newComment];
      } else {
        _postComments[postId] = [newComment];
      }

      _updatePostInLists(postId, (post) {
        return post.copyWith(
          commentsCount: post.commentsCount + 1,
          comments: [...post.comments, newComment],
        );
      });
    }
  }

  Future<void> addPost(PostModel post, {File? imageFile}) async {
    final newPost = await execute(
      () => _service.createPost(post, imageFile: imageFile),
    );
    if (newPost != null) {
      _posts.insert(0, newPost);
      _myPosts.insert(0, newPost);
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
      _updatePostInLists(id, (post) {
        return updatedPost.copyWith(
          comments: post.comments,
          isLiked: post.isLiked,
          isSaved: post.isSaved,
        );
      });
    }
  }

  Future<void> deletePost(String id) async {
    final success = await execute(() => _service.deletePost(id));
    if (success == true) {
      _posts.removeWhere((p) => p.id == id);
      _myPosts.removeWhere((p) => p.id == id);
      notifyListeners();
    }
  }

  Future<void> editComment(
    String postId,
    String commentId,
    String content,
  ) async {
    final updatedComment = await execute(
      () => _service.updateComment(commentId, content),
    );
    if (updatedComment != null) {
      // Update the comments map
      if (_postComments.containsKey(postId)) {
        final list = [..._postComments[postId]!];
        final idx = list.indexWhere((c) => c.id == commentId);
        if (idx != -1) {
          list[idx] = updatedComment;
          _postComments[postId] = list;
        }
      }

      _updatePostInLists(postId, (post) {
        final comments = [...post.comments];
        final commentIndex = comments.indexWhere((c) => c.id == commentId);
        if (commentIndex != -1) {
          comments[commentIndex] = updatedComment;
        }
        return post.copyWith(comments: comments);
      });
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final success = await execute(() => _service.deleteComment(commentId));
    if (success == true) {
      // Update the comments map
      if (_postComments.containsKey(postId)) {
        _postComments[postId] = _postComments[postId]!
            .where((c) => c.id != commentId)
            .toList();
      }

      _updatePostInLists(postId, (post) {
        return post.copyWith(
          commentsCount: post.commentsCount - 1,
          comments: post.comments.where((c) => c.id != commentId).toList(),
        );
      });
    }
  }

  Future<void> fetchSavedPosts() async {
    final result = await execute(() => _service.getSavedPosts());
    if (result != null) {
      _savedPosts = result.data;
      _syncComments(result.data);
      notifyListeners();
    }
  }

  Future<bool> reportPost(String postId, String reason, {String? details}) async {
    final success = await execute(
      () => _service.reportPost(postId, reason, details: details),
    );
    if (success == true) {
      // Opt out of showing this post locally for the user who reported it
      _posts.removeWhere((p) => p.id == postId);
      _myPosts.removeWhere((p) => p.id == postId);
      _activityPosts.removeWhere((p) => p.id == postId);
      _savedPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    }
    return false;
  }

  void _updatePostInLists(
    String postId,
    PostModel Function(PostModel) updateAction,
  ) {
    final globalIndex = _posts.indexWhere((p) => p.id == postId);
    if (globalIndex != -1) {
      _posts[globalIndex] = updateAction(_posts[globalIndex]);
    }

    final myIndex = _myPosts.indexWhere((p) => p.id == postId);
    if (myIndex != -1) {
      _myPosts[myIndex] = updateAction(_myPosts[myIndex]);
    }

    final activityIndex = _activityPosts.indexWhere((p) => p.id == postId);
    if (activityIndex != -1) {
      _activityPosts[activityIndex] = updateAction(_activityPosts[activityIndex]);
    }

    final savedIndex = _savedPosts.indexWhere((p) => p.id == postId);
    if (savedIndex != -1) {
      _savedPosts[savedIndex] = updateAction(_savedPosts[savedIndex]);
    }

    notifyListeners();
  }

  void _syncComments(List<PostModel> posts) {
    for (var post in posts) {
      if (post.comments.isNotEmpty) {
        _postComments[post.id] = List.from(post.comments);
      }
    }
  }
}
