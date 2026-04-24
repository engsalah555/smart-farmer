import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatStorageHelper {
  static const String _storageKey = 'chatbot_sessions';

  /// جلب جميع الجلسات المحفوظة
  static Future<List<Map<String, dynamic>>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString(_storageKey);

    if (sessionsJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// حفظ تحديث الجلسة (إذا كان المعرف موجود يتم تحديثها، وإلا تُضاف جلسة جديدة)
  static Future<void> saveSession(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> sessions = await getSessions();

    final int index = sessions.indexWhere((s) => s['id'] == session['id']);

    if (index >= 0) {
      // تحديث
      sessions[index] = session;
    } else {
      // جلسة جديدة تُضاف في البداية (الأحدث)
      sessions.insert(0, session);
    }

    await prefs.setString(_storageKey, jsonEncode(sessions));
  }

  /// حذف جلسة محددة
  static Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> sessions = await getSessions();

    sessions.removeWhere((s) => s['id'] == sessionId);
    await prefs.setString(_storageKey, jsonEncode(sessions));
  }

  /// مسح جميع الجلسات
  static Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
