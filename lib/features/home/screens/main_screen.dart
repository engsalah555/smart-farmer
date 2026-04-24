import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  // UI Bottom Bar Indices:
  // 0: Home, 1: Marketplace, 2: Space (Scanner FAB), 3: Crops, 4: Profile
  // StatefulShellRoute Branches Indices:
  // 0: Home, 1: Marketplace, 2: Crops, 3: Profile

  int _uiIndexToBranchIndex(int uiIndex) {
    if (uiIndex == 0) return 0;
    if (uiIndex == 1) return 1;
    if (uiIndex == 3) return 2;
    if (uiIndex == 4) return 3;
    return 0; // fallback
  }

  int _branchIndexToUiIndex(int branchIndex) {
    if (branchIndex == 0) return 0;
    if (branchIndex == 1) return 1;
    if (branchIndex == 2) return 3;
    if (branchIndex == 3) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 2) {
      context.push('/disease_detection');
    } else {
      final branchIndex = _uiIndexToBranchIndex(index);
      navigationShell.goBranch(
        branchIndex,
        initialLocation: branchIndex == navigationShell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUiIndex = _branchIndexToUiIndex(navigationShell.currentIndex);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          navigationShell,
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: isDark ? 0.4 : 0.2,
              ),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'scanner_fab',
          onPressed: () => context.push('/disease_detection'),
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_scanner_rounded, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8,
        color: isDark ? AppColors.darkSurface : Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, 'الرئيسية', 0, currentUiIndex),
              _buildNavItem(context, Icons.eco_rounded, 'المحاصيل', 3, currentUiIndex),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(context, Icons.shopping_bag_rounded, 'المتجر', 1, currentUiIndex),
              _buildNavItem(context, Icons.person_rounded, 'حسابي', 4, currentUiIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int currentUiIndex,
  ) {
    final isSelected = currentUiIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;
    final inactiveColor = (isDark ? Colors.white : AppColors.textPrimary).withValues(alpha: 0.4);

    return InkWell(
      onTap: () => _onItemTapped(context, index),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

