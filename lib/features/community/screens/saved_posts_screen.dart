import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/responsive_post_list.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchSavedPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: context.wp(4.5)),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
          ),
          title: Text(
            'المنشورات المحفوظة',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontFamily: 'Cairo',
              fontSize: context.sp(18).clamp(16, 22),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Consumer<PostProvider>(
          builder: (context, provider, child) {
            return ResponsivePostList(
              posts: provider.savedPosts,
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              onRefresh: () => provider.fetchSavedPosts(),
              emptyWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: context.wp(20),
                      color: Theme.of(context).hintColor.withAlpha(100),
                    ),
                    SizedBox(height: context.hp(2)),
                    Text(
                      'لم تقم بحفظ أي منشورات بعد',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: context.sp(16).clamp(14, 18),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
