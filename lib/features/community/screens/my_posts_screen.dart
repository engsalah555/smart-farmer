import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../providers/post_provider.dart';
import '../widgets/responsive_post_list.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchMyPosts();
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
            'منشوراتي',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              
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
              posts: provider.myPosts,
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              onRefresh: () => provider.fetchMyPosts(),
              emptyWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.post_add_rounded,
                      size: context.wp(20),
                      color: Theme.of(context).hintColor.withAlpha(100),
                    ),
                    SizedBox(height: context.hp(2)),
                    Text(
                      'لم تقم بنشر أي منشورات بعد',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: context.sp(16).clamp(14, 18),
                        
                      ),
                    ),
                    SizedBox(height: context.hp(3)),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/create_post'),
                      icon: const Icon(Icons.add),
                      label: Text(
                        'أنشئ أول منشور لك',
                        style: TextStyle(
                          
                          fontSize: context.sp(14).clamp(12, 16),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: context.wp(6), vertical: context.hp(1.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
