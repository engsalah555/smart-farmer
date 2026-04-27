import '../../../core/models/comment_model.dart';
import '../../../core/providers/base_provider.dart';
import '../services/community_service.dart';

class CommentProvider extends BaseProvider {
  final CommunityService _service;

  final Map<String, List<Comment>> _postComments = {};
  final Map<String, bool> _commentsLoading = {};

  CommentProvider(this._service);

  List<Comment> getComments(String postId) => _postComments[postId] ?? [];
  bool isCommentsLoading(String postId) => _commentsLoading[postId] ?? false;

  void syncCommentsFromPosts(List<dynamic> posts) {
    for (var post in posts) {
      if (post.comments.isNotEmpty) {
        _postComments[post.id] = List<Comment>.from(post.comments);
      }
    }
  }

  Future<void> fetchComments(String postId) async {
    _commentsLoading[postId] = true;
    notifyListeners();

    try {
      final result = await _service.getComments(postId);
      _postComments[postId] = result.data;
    } finally {
      _commentsLoading[postId] = false;
      notifyListeners();
    }
  }

  Future<Comment?> addComment(String postId, String content) async {
    final newComment = await execute(
      () => _service.addComment(postId, content),
    );
    if (newComment != null) {
      if (_postComments.containsKey(postId)) {
        _postComments[postId] = [..._postComments[postId]!, newComment];
      } else {
        _postComments[postId] = [newComment];
      }
      notifyListeners();
      return newComment;
    }
    return null;
  }

  Future<Comment?> editComment(
    String postId,
    String commentId,
    String content,
  ) async {
    final updatedComment = await execute(
      () => _service.updateComment(commentId, content),
    );
    if (updatedComment != null) {
      if (_postComments.containsKey(postId)) {
        final list = [..._postComments[postId]!];
        final idx = list.indexWhere((c) => c.id == commentId);
        if (idx != -1) {
          list[idx] = updatedComment;
          _postComments[postId] = list;
          notifyListeners();
        }
      }
      return updatedComment;
    }
    return null;
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    final success = await execute(() => _service.deleteComment(commentId));
    if (success == true) {
      if (_postComments.containsKey(postId)) {
        _postComments[postId] = _postComments[postId]!
            .where((c) => c.id != commentId)
            .toList();
        notifyListeners();
      }
      return true;
    }
    return false;
  }
}
