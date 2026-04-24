import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/social_media_post.dart';
import '../widgets/skeleton_post.dart';

class ResponsivePostList extends StatelessWidget {
  final List<PostModel> posts;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? emptyWidget;

  const ResponsivePostList({
    super.key,
    required this.posts,
    required this.isLoading,
    this.errorMessage,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && posts.isEmpty) {
      return _buildSkeletons(context);
    }

    if (errorMessage != null && posts.isEmpty) {
      return _buildError(context);
    }

    if (posts.isEmpty) {
      return emptyWidget ?? _buildEmpty(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final isDesktop = constraints.maxWidth > 1024;
          
          // Max width for content to look "Pro Max" on large screens
          final double maxWidth = isDesktop ? 1000 : (isTablet ? 800 : double.infinity);
          
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!isLoadingMore && hasMore && 
                  scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                onLoadMore?.call();
              }
              return false;
            },
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 0,
                        vertical: context.hp(1),
                      ),
                      sliver: !isTablet 
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => SocialMediaPost(post: posts[index]),
                              childCount: posts.length,
                            ),
                          )
                        : SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 3 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75, // Better for grid items with images
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => SocialMediaPost(post: posts[index]),
                              childCount: posts.length,
                            ),
                          ),
                    ),
                    if (isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 1024;
        final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
        
        return Padding(
          padding: EdgeInsets.all(context.wp(2)),
          child: crossAxisCount == 1
            ? ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => const SkeletonPost(),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: context.wp(2),
                  mainAxisSpacing: context.wp(2),
                  mainAxisExtent: context.hp(50),
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const SkeletonPost(),
              ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ: $errorMessage',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 80, color: Colors.grey.withAlpha(128)),
          const SizedBox(height: 16),
          const Text(
            'لا توجد منشورات حتى الآن',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
