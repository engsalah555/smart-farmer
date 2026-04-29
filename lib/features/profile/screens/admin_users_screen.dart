import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/fade_in_slide.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers(isRefresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<AdminProvider>();
        if (!provider.isLoading && provider.currentPage < provider.lastPage) {
          provider.fetchUsers(page: provider.currentPage + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين والتوثيق'),
        centerTitle: true,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.users.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمين حالياً'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchUsers(isRefresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.users.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.users.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final user = provider.users[index];
                return FadeInSlide(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 50 * (index % 10)),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: context.primary.withValues(alpha: 0.1),
                          backgroundImage:
                              user.profileImage != null &&
                                      user.profileImage!.isNotEmpty
                                  ? NetworkImage(user.profileImage!)
                                  : null,
                          child:
                              user.profileImage == null ||
                                      user.profileImage!.isEmpty
                                  ? Icon(Icons.person, color: context.primary)
                                  : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: AppTypography.bodyLarge(isDark: isDark)
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (user.isVerified)
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 18,
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email, style: AppTypography.bodySmall(isDark: isDark)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRoleColor(user.userType).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getRoleName(user.userType),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getRoleColor(user.userType),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Switch(
                          value: user.isVerified,
                          activeTrackColor: context.primary,
                          onChanged: (value) async {
                            final messenger = ScaffoldMessenger.of(context);
                            final authProvider = context.read<AuthProvider>();
                            final success = await provider.toggleUserVerification(user.id, authProvider);
                            if (success) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value ? 'تم توثيق المستخدم' : 'تم إلغاء التوثيق',
                                  ),
                                  backgroundColor: value ? Colors.green : Colors.orange,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getRoleName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'مدير النظام';
      case 'seller':
      case 'merchant':
      case 'farmer':
        return 'تاجر / مزارع';
      default:
        return 'مستخدم';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'seller':
      case 'merchant':
      case 'farmer':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
