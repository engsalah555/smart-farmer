import '../constants.dart';

/// Helper class to handle URL formatting across the application.
/// Specifically designed to bridge Laravel storage paths with the Flutter app.
class UrlHelper {
  /// Formats a relative or storage path into a full reachable URL.
  static String formatImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('assets/')) return path;

    // Remove any leading slashes and initial "storage/" if it's there to normalize
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (cleanPath.startsWith('storage/')) {
      cleanPath = cleanPath.substring(8);
    }

    // Now cleanly prepend base and storage root
    final baseUrl = AppConstants.apiBaseUrl.endsWith('/')
        ? AppConstants.apiBaseUrl.substring(0, AppConstants.apiBaseUrl.length - 1)
        : AppConstants.apiBaseUrl;
    
    return '$baseUrl/storage/$cleanPath';
  }
}
