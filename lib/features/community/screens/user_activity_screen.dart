import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../providers/post_provider.dart';
import '../widgets/responsive_post_list.dart';

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchActivityPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
          ),
          title: const Text(
            'نشاطاتي',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<PostProvider>(
          builder: (context, provider, child) {
            return ResponsivePostList(
              postIds: provider.activityPostIds,
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              onRefresh: () => provider.fetchActivityPosts(),
              emptyWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 80,
                      color: Theme.of(context).hintColor.withAlpha(100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد نشاط سابق (إعجابات أو تعليقات)',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/forum'),
                      icon: const Icon(Icons.explore),
                      label: const Text('استكشف المنتدى', style: TextStyle()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
