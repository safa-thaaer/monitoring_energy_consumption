# ⚡ نظام مراقبة استهلاك الطاقة
# Energy Consumption Monitoring System

<div dir="rtl">

## 📱 نظرة عامة

تطبيق Flutter متكامل لمراقبة استهلاك الطاقة في الوقت الفعلي باستخدام ESP32 و Firebase Realtime Database.

## ✨ المميزات

- 📊 **مراقبة لحظية**: عرض القدرة والطاقة والفولتية والتيار في الوقت الفعلي
- 📈 **تحليلات متقدمة**: رسوم بيانية للاستهلاك اليومي والأسبوعي
- 🔔 **تنبيهات ذكية**: إشعارات عند تجاوز الحدود الآمنة
- 🌍 **حساب انبعاثات CO2**: تتبع الأثر البيئي للاستهلاك
- 🎨 **واجهة جميلة**: تصميم عصري بألوان متدرجة وتأثيرات حركية
- 🔄 **تحديث تلقائي**: استقبال البيانات من Firebase فوراً

## 🛠️ التقنيات المستخدمة

- **Framework**: Flutter 
- **Database**: Firebase Realtime Database
- **Hardware**: ESP32 (لقراءة بيانات الطاقة)
- **Charts**: fl_chart
- **State Management**: StatefulWidget

## 📋 المتطلبات

- Flutter SDK
- Dart SDK
- Firebase Account
- ESP32 (للجانب Hardware)

## 🚀 التثبيت والإعداد

### 1. استنساخ المشروع
```bash
git clone https://github.com/YourUsername/monitoring_energy_consumption.git
cd monitoring_energy_consumption
```

### 2. تثبيت المكتبات
```bash
flutter pub get
```

### 3. إعداد Firebase
1. أنشئ مشروع جديد في [Firebase Console](https://console.firebase.google.com/)
2. فعّل Firebase Realtime Database
3. أضف تطبيق Android/iOS إلى مشروعك
4. حمّل ملف `google-services.json` (Android) أو `GoogleService-Info.plist` (iOS)
5. أنشئ ملف `lib/firebase/firebase_options.dart` باستخدام FlutterFire CLI:
```bash
flutterfire configure
```

### 4. إعداد قواعد Firebase Database
```json
{
  "rules": {
    "readings": {
      ".read": true,
      ".write": true
    }
  }
}
```

### 5. تشغيل التطبيق
```bash
flutter run
```

## 📊 هيكل البيانات في Firebase

```json
{
  "readings": {
    "1738175234567": {
      "power_W": 1234.5,
      "energy_kWh": 12.34,
      "voltage_V": 220.0,
      "current_A": 5.6,
      "co2_kg": 4.94
    }
  }
}
```

## 📱 لقطات الشاشة

(أضف لقطات شاشة للتطبيق هنا)

## 🔧 إعداد ESP32

للحصول على كود ESP32 الذي يرسل البيانات إلى Firebase، يمكنك استخدام مكتبة Firebase ESP Client.

## 🤝 المساهمة

المساهمات مرحب بها! يرجى فتح Issue أو Pull Request.

## 📄 الترخيص

هذا المشروع مفتوح المصدر ومتاح للاستخدام الحر.

## 📧 التواصل

للأسئلة والاستفسارات، يمكنك التواصل عبر Issues في GitHub.

---

**ملاحظة هامة**: لا تنسَ إضافة ملفات Firebase الخاصة بك إلى `.gitignore` لحماية البيانات الحساسة!

</div>

---


