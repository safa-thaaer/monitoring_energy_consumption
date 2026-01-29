import 'package:firebase_database/firebase_database.dart';
import 'dart:developer' as developer;

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  DatabaseReference get database => _database;

  // جرب الاستماع لمسار محدد - عدل اسم المسار حسب بنية البيانات في Firebase
  // المسارات الشائعة: 'readings', 'sensor_data', 'energy_data'
  Stream<DatabaseEvent> get dataStream => _database.child('readings').onValue;

  // دالة للتحقق من الاتصال
  Future<bool> checkConnection() async {
    try {
      developer.log(
        '🔍 محاولة الاتصال بـ Firebase...',
        name: 'FirebaseService',
      );

      final DatabaseReference connectedRef = FirebaseDatabase.instance.ref(
        ".info/connected",
      );
      final snapshot = await connectedRef.get();
      final isConnected = snapshot.value as bool? ?? false;

      developer.log(
        '✅ حالة الاتصال: ${isConnected ? "متصل" : "غير متصل"}',
        name: 'FirebaseService',
      );
      return isConnected;
    } catch (e) {
      developer.log('❌ خطأ في التحقق من الاتصال: $e', name: 'FirebaseService');
      return false;
    }
  }

  // دالة لقراءة البيانات مباشرة
  Future<Map<dynamic, dynamic>?> readData() async {
    try {
      developer.log(
        '📖 قراءة البيانات من Firebase...',
        name: 'FirebaseService',
      );

      final snapshot = await _database.child('readings').get();

      if (snapshot.exists) {
        developer.log('✅ تم العثور على بيانات!', name: 'FirebaseService');
        developer.log(
          '📊 البيانات: ${snapshot.value}',
          name: 'FirebaseService',
        );
        return snapshot.value as Map<dynamic, dynamic>?;
      } else {
        developer.log(
          '⚠️ لا توجد بيانات في Firebase!',
          name: 'FirebaseService',
        );
        developer.log(
          '💡 تأكد من أن ESP32 يرسل البيانات إلى المسار الصحيح',
          name: 'FirebaseService',
        );
        return null;
      }
    } catch (e) {
      developer.log('❌ خطأ في قراءة البيانات: $e', name: 'FirebaseService');
      return null;
    }
  }

  // دالة لعرض جميع البيانات في الـ root
  Future<void> debugPrintAllData() async {
    try {
      developer.log(
        '🔍 عرض جميع البيانات في Firebase...',
        name: 'FirebaseService',
      );
      final snapshot = await _database.get();

      if (snapshot.exists) {
        developer.log(
          '📊 البيانات الكاملة: ${snapshot.value}',
          name: 'FirebaseService',
        );
      } else {
        developer.log(
          '⚠️ قاعدة البيانات فارغة تماماً!',
          name: 'FirebaseService',
        );
      }
    } catch (e) {
      developer.log('❌ خطأ: $e', name: 'FirebaseService');
    }
  }
}
