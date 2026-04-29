import '../../core/models/user_model.dart';
import '../../core/providers/base_provider.dart';
import '../../core/services/admin_service.dart';
import 'auth_provider.dart';

class AdminProvider extends BaseProvider {
  final AdminService _adminService;

  AdminProvider(this._adminService);

  List<User> _users = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalUsers = 0;

  List<User> get users => _users;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalUsers => _totalUsers;

  /// جلب المستخدمين
  Future<void> fetchUsers({int page = 1, bool isRefresh = false}) async {
    if (isRefresh) {
      _users = [];
      _currentPage = 1;
    }

    await execute(() async {
      final response = await _adminService.getUsers(page: page);
      final List<dynamic> data = response['data'];
      final List<User> fetchedUsers = data.map((e) => User.fromJson(e)).toList();

      if (page == 1) {
        _users = fetchedUsers;
      } else {
        _users.addAll(fetchedUsers);
      }

      _currentPage = response['meta']['current_page'];
      _lastPage = response['meta']['last_page'];
      _totalUsers = response['meta']['total'];
      
      notifyListeners();
    });
  }

  /// تبديل حالة التوثيق لمستخدم
  Future<bool> toggleUserVerification(String userId, AuthProvider authProvider) async {
    bool result = false;
    await executeSilently(() async {
      final updatedUser = await _adminService.toggleVerification(userId);
      
      // تحديث القائمة المحلية
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }

      // إذا كان المستخدم المحدث هو المستخدم الحالي المسجل دخوله، نحدثه في AuthProvider أيضاً
      if (authProvider.currentUser?.id == userId) {
        authProvider.updateUserLocally(updatedUser);
      }

      result = true;
    });
    return result;
  }

  /// حذف مستخدم
  Future<bool> deleteUser(String userId) async {
    bool result = false;
    await execute(() async {
      final success = await _adminService.deleteUser(userId);
      if (success) {
        _users.removeWhere((u) => u.id == userId);
        _totalUsers--;
        notifyListeners();
        result = true;
      }
    });
    return result;
  }
}
