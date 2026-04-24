import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../providers/post_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/responsive_post_list.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Ensure fetch is called if not initialized properly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostProvider>().loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(context.wp(2)),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
                size: context.sp(16).clamp(14, 22),
              ),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        title: Hero(
          tag: 'forum_title',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'المجتمع الزراعي',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.w900,
                fontSize: context.sp(18).clamp(16, 24),
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PostSearchDelegate(context.read<PostProvider>()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              context.push('/notifications');
            },
          ),
        ],
      ),
      body: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Consumer<PostProvider>(
          builder: (context, provider, child) {
            return ResponsivePostList(
              posts: provider.posts,
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              onRefresh: () => provider.fetchPosts(),
              onLoadMore: () => provider.loadMorePosts(),
              hasMore: provider.hasMore,
              isLoadingMore: provider.isLoadingMore,
              emptyWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 100,
                      color: Theme.of(context).hintColor.withAlpha(50),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'المنتدى هادئ جداً اليوم',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'كن أول من يشارك خبرته الزراعية مع المجتمع',
                      style: TextStyle(color: Colors.grey[600], fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/create_post'),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('اكتب منشوراً الآن', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/create_post');
          if (!context.mounted) return;
          context.read<PostProvider>().fetchPosts();
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        highlightElevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: const Text(
          'شاركنا تجربتك',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}


class _PostSearchDelegate extends SearchDelegate<String> {
  final PostProvider _provider;

  _PostSearchDelegate(this._provider)
    : super(
        searchFieldLabel: 'ابحث في المنشورات...',
        searchFieldStyle: const TextStyle(fontSize: 16),
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('اكتب للبحث عن منشورات...', style: TextStyle(fontSize: 16)),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = _provider.posts.where((post) {
      final q = query.toLowerCase();
      return post.title.toLowerCase().contains(q) ||
          post.content.toLowerCase().contains(q) ||
          post.author.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج لـ "$query"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final post = results[index];
          return ListTile(
            title: Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.article, color: AppColors.primary),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${post.likesCount}',
                  style: const TextStyle(fontSize: 12),
                ),
                const Icon(Icons.favorite, size: 14, color: Colors.red),
              ],
            ),
            onTap: () => close(context, post.id),
          );
        },
      ),
    );
  }
}
