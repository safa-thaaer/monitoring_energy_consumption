# ⚡ Energy Consumption Monitoring System
### نظام مراقبة استهلاك الطاقة الكهربائية

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Realtime_DB-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![ESP32](https://img.shields.io/badge/ESP32-IoT_Hardware-E7352C?style=for-the-badge&logo=espressif&logoColor=white)
![License](https://img.shields.io/badge/License-Academic-green?style=for-the-badge)

**A real-time IoT-based energy monitoring mobile application built with Flutter and Firebase, designed to track electrical consumption, analyze usage patterns, and calculate environmental impact.**

</div>

---

## 📋 Table of Contents

1. [Project Overview](#1-project-overview)
2. [Research Motivation & Problem Statement](#2-research-motivation--problem-statement)
3. [System Architecture](#3-system-architecture)
4. [Technology Stack](#4-technology-stack)
5. [Features](#5-features)
6. [Project Structure](#6-project-structure)
7. [Data Models](#7-data-models)
8. [Core Modules Documentation](#8-core-modules-documentation)
9. [Firebase Database Schema](#9-firebase-database-schema)
10. [Hardware Integration (ESP32)](#10-hardware-integration-esp32)
11. [Alert & Notification System](#11-alert--notification-system)
12. [Energy Calculations & Formulas](#12-energy-calculations--formulas)
13. [Installation & Setup](#13-installation--setup)
14. [Testing & Simulation](#14-testing--simulation)
15. [Limitations & Future Work](#15-limitations--future-work)
16. [References](#16-references)

---

## 1. Project Overview

The **Energy Consumption Monitoring System** is a cross-platform mobile application developed using the **Flutter** framework. It provides real-time monitoring of electrical energy consumption by receiving sensor data from an **ESP32 microcontroller** through **Firebase Realtime Database**.

The system enables users to:
- View live electrical readings (power, energy, voltage, current)
- Analyze historical consumption over daily and weekly intervals
- Monitor CO₂ carbon emissions produced by energy use
- Receive automatic alerts when safe thresholds are exceeded
- Identify which connected devices are consuming power

This project is developed as a **graduation research project** in the field of **Internet of Things (IoT)** and **Smart Energy Management**.

---

## 2. Research Motivation & Problem Statement

### 2.1 Background

The global demand for electrical energy continues to rise, driven by increasing population, industrial growth, and smart device proliferation. Unmonitored energy consumption leads to:

- **Financial waste**: high electricity bills due to invisible daily usage
- **Environmental damage**: increased CO₂ emissions contribute to climate change
- **Infrastructure strain**: overloaded electrical systems and safety hazards

### 2.2 Problem Statement

Traditional energy meters provide only cumulative consumption data with no real-time visibility, no per-device breakdown, and no alerting mechanism. Users have no actionable insights into *when*, *how much*, and *which* devices are consuming electricity.

### 2.3 Proposed Solution

This system bridges the gap using an IoT architecture that:
1. **Measures** electrical parameters at the source using an ESP32 microcontroller and sensors
2. **Transmits** the measured data wirelessly to Firebase Realtime Database
3. **Displays** real-time and historical data on a Flutter mobile application
4. **Analyzes** trends and generates smart alerts automatically

---

## 3. System Architecture

The system follows a three-tier IoT architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│                      SYSTEM ARCHITECTURE                        │
├──────────────────┬──────────────────────┬───────────────────────┤
│   LAYER 1        │      LAYER 2          │      LAYER 3          │
│   Hardware       │      Cloud            │      Application      │
│   (Perception)   │      (Network)        │      (Presentation)   │
├──────────────────┼──────────────────────┼───────────────────────┤
│  ┌────────────┐  │  ┌────────────────┐  │  ┌─────────────────┐  │
│  │   Sensors  │  │  │    Firebase    │  │  │  Flutter App    │  │
│  │ • Voltage  │─▶│  │   Realtime     │─▶│  │                 │  │
│  │ • Current  │  │  │   Database     │  │  │ • Dashboard     │  │
│  └────────────┘  │  │                │  │  │ • Analytics     │  │
│        │         │  │  /readings/    │  │  │ • Notifications │  │
│  ┌────────────┐  │  │  {timestamp}:  │  │  └─────────────────┘  │
│  │   ESP32    │  │  │   power_W      │  │                        │
│  │ MCU + WiFi │  │  │   voltage_V    │  │                        │
│  └────────────┘  │  │   current_A    │  │                        │
│                  │  │   energy_kWh   │  │                        │
│                  │  │   co2_kg       │  │                        │
│                  │  └────────────────┘  │                        │
└──────────────────┴──────────────────────┴───────────────────────┘
```

### 3.1 Data Flow

```
ESP32 Sensor Reading
        │
        ▼
  Calculate Values
  (P = V × I, Energy, CO₂)
        │
        ▼
  Push to Firebase
  /readings/{unix_timestamp}/
        │
        ▼
  Firebase Realtime DB
  (Cloud Storage)
        │
        ▼  (onValue stream)
  Flutter App Listener
  (_setupFirebaseListener)
        │
        ▼
  Parse & Process Data
  (_updateDashboard, _storeHistoricalData)
        │
        ▼
  Anomaly Detection
  (_checkForAnomalies)
        │
        ▼
  UI State Update
  (setState → rebuild widgets)
```

---

## 4. Technology Stack

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Mobile Framework** | Flutter | ^3.x | Cross-platform UI |
| **Programming Language** | Dart | ^3.8.1 | Application logic |
| **Cloud Database** | Firebase Realtime Database | ^10.4.0 | Real-time data sync |
| **Firebase Core** | firebase_core | ^2.24.2 | Firebase initialization |
| **Charting** | fl_chart | ^0.66.0 | Line charts & graphs |
| **Gauge Widgets** | syncfusion_flutter_gauges | ^27.2.5 | Circular radial gauges |
| **Internationalization** | intl | ^0.18.1 | Date/time formatting |
| **IoT Hardware** | ESP32 | — | Sensor reading & WiFi |
| **State Management** | StatefulWidget (built-in) | — | UI state control |

### 4.1 Why Flutter?

Flutter was chosen for this project because:
- **Single codebase** targets Android, iOS, and Web simultaneously
- **Rich widget ecosystem** enables the creation of complex, animated UIs
- **Hot reload** accelerates development and testing cycles
- **Strong Dart typing** reduces runtime errors
- **Firebase SDK** is officially supported and well-maintained

### 4.2 Why Firebase Realtime Database?

- **Real-time synchronization**: data pushed from ESP32 instantly propagates to all connected clients
- **No backend server required**: eliminates the need for a custom API server
- **Offline support**: the SDK caches data locally during connectivity loss
- **Free tier**: sufficient for academic prototype usage
- **JSON tree structure**: matches the flat key-value readings format perfectly

---

## 5. Features

### 5.1 Real-Time Dashboard
- Live display of **Power (W)**, **Energy (kWh)**, **Voltage (V)**, **Current (A)**, and **CO₂ (kg)**
- Connection status indicator (green = connected, red = disconnected)
- Last update timestamp showing exact time of the most recent reading
- Multi-layered **circular radial gauge** with three concentric rings:
  - Outer ring: CO₂ emissions percentage (green gradient)
  - Middle ring: Energy consumption percentage (blue gradient)
  - Inner ring: Power consumption percentage (orange gradient)
  - Center ring: Per-device breakdown (Lighting vs. Charger)

### 5.2 Analytics View
- Toggle between **Daily (24-hour)** and **Weekly (7-day CO₂)** views
- Smooth curved **line charts** with area fill (using fl_chart)
- Statistical summary cards:
  - Average daily consumption (kWh)
  - Minimum recorded consumption
  - Maximum recorded consumption
  - Weekly total accumulation
- Data is retained for a rolling **7-day window** in memory

### 5.3 Notifications & Alerts
- Automatic alert generation when thresholds are breached
- **Danger alert** (red): Power exceeds 4,000 W (overload risk)
- **Warning alert** (orange): Voltage outside 200V–240V safe range
- Alert queue capped at **10 notifications** (most recent preserved)
- Duplicate suppression: same alert is not repeated
- Badge counter on the Notifications tab shows unread count

### 5.4 Device Breakdown (Smart Inference)
The system uses a heuristic algorithm to infer which devices are active based on total power readings:

| Power Range | Inference |
|-------------|-----------|
| 0–25 W | Charger only |
| 25–50 W | Lighting only |
| > 50 W | Both Lighting + Charger |

### 5.5 CO₂ Emissions Tracking
- CO₂ is calculated using the standard emission factor: **0.4 kg CO₂ per kWh**
- Weekly CO₂ chart tracks environmental impact day by day
- Helps users make informed decisions to reduce carbon footprint

---

## 6. Project Structure

```
monitoring_energy_consumption/
│
├── lib/
│   ├── main.dart                        # App entry point, Firebase init, MaterialApp
│   │
│   ├── firebase/
│   │   └── firebase_options.dart        # Firebase project configuration & API keys
│   │
│   ├── models/
│   │   ├── energy_data.dart             # Data model for a single energy reading
│   │   ├── device_info.dart             # Data model for a tracked device
│   │   └── notification_item.dart       # Data model for an alert notification
│   │
│   ├── services/
│   │   ├── firebase_service.dart        # Firebase CRUD operations & real-time stream
│   │   └── test_data_service.dart       # Utility to seed Firebase with test data
│   │
│   ├── screens/
│   │   ├── home_screen.dart             # Root screen: state management, navigation, data logic
│   │   ├── dashboard_view.dart          # Tab 1: Live readings display
│   │   ├── analytics_view.dart          # Tab 2: Charts and statistical analysis
│   │   └── notifications_view.dart      # Tab 3: Alert history list
│   │
│   └── widgets/
│       ├── multi_circular_gauge.dart    # Concentric radial gauge with device breakdown
│       ├── energy_card.dart             # Colored metric card with progress bar
│       ├── chart_widget.dart            # Reusable line chart component
│       ├── notification_card.dart       # Individual notification display card
│       └── stat_card.dart              # Small statistics summary card
│
├── android/                             # Android platform files
├── ios/                                 # iOS platform files
├── pubspec.yaml                         # Dart package dependencies
├── analysis_options.yaml                # Dart linting rules
├── README.md                            # This document
├── DEBUG_GUIDE_AR.md                    # Arabic debugging guide
├── QUICK_FIX_AR.md                      # Arabic quick fix reference
└── TEST_DATA_INFO.md                    # Test data seeding documentation
```

---

## 7. Data Models

### 7.1 `EnergyData`
Represents a single timestamped energy reading received from Firebase.

```dart
class EnergyData {
  final String timestamp;    // Unix timestamp (ms) as string key
  final DateTime dateTime;   // Parsed DateTime for calculations
  final double power;        // Watts (W)
  final double energy;       // Kilowatt-hours (kWh)
  final double voltage;      // Volts (V)
  final double current;      // Amperes (A)
}
```

### 7.2 `DeviceInfo`
Represents an inferred device and its energy contribution.

```dart
class DeviceInfo {
  final String name;         // Device display name (e.g., "الإضاءة")
  final String icon;         // Emoji icon for the device
  final double consumption;  // Estimated power consumption in Watts
  final bool isActive;       // Whether the device is currently on
  final Color color;         // Display color for visual differentiation
}
```

### 7.3 `NotificationItem`
Represents a system-generated alert or warning.

```dart
class NotificationItem {
  final String id;           // Unique ID (timestamp-based)
  final String type;         // 'danger' | 'warning' | 'info'
  final String title;        // Short alert headline
  final String message;      // Detailed alert description
  final String time;         // Time of alert (HH:mm:ss)
  final String date;         // Date of alert (yyyy-MM-dd)
}
```

---

## 8. Core Modules Documentation

### 8.1 `main.dart` — Application Entry Point

Initializes the Firebase SDK before running the app, ensuring the database connection is ready before any UI is rendered.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```

Key configuration:
- App title: `نظام مراقبة الطاقة`
- Text direction: **RTL** (Right-to-Left) for Arabic UI
- Theme: Material Design with blue primary color

---

### 8.2 `FirebaseService` — Cloud Data Layer

**File:** `lib/services/firebase_service.dart`

Encapsulates all Firebase Realtime Database operations.

| Method | Return Type | Description |
|--------|------------|-------------|
| `dataStream` | `Stream<DatabaseEvent>` | Continuous real-time stream from `/readings` node |
| `checkConnection()` | `Future<bool>` | Pings `/.info/connected` to verify live connection |
| `readData()` | `Future<Map?>` | One-time fetch of all readings data |
| `debugPrintAllData()` | `Future<void>` | Dumps entire database to debug console |

The `dataStream` getter uses Firebase's `.onValue` listener which fires immediately with current data, then fires again on every subsequent update — enabling true real-time behavior without polling.

---

### 8.3 `TestDataService` — Simulation & Testing

**File:** `lib/services/test_data_service.dart`

Used during development and testing when physical ESP32 hardware is unavailable. Pushes synthetically generated readings to Firebase that simulate realistic sensor behavior.

| Method | Description |
|--------|-------------|
| `addSingleTestReading()` | Pushes one random reading to Firebase |
| `addMultipleTestReadings({count})` | Pushes `count` hourly readings covering past N hours |
| `clearAllReadings()` | Removes all data from `/readings` node |

**Simulated data ranges:**
- Voltage: 215V – 225V (random offset from 220V)
- Current: 5A – 8A (random)
- Power: derived from `P = V × I`
- Energy: approximated from power
- CO₂: `energy × 0.4`

---

### 8.4 `EnergyMonitorHome` — Main State Controller

**File:** `lib/screens/home_screen.dart`

This is the central `StatefulWidget` that owns all live state and coordinates data flow across the three views.

**State variables:**

| Variable | Type | Description |
|----------|------|-------------|
| `power` | `double` | Latest power reading in Watts |
| `energy` | `double` | Latest energy reading in kWh |
| `co2` | `double` | Latest CO₂ value in kg |
| `voltage` | `double` | Latest voltage reading in Volts |
| `current` | `double` | Latest current reading in Amperes |
| `isConnected` | `bool` | Firebase connection status |
| `lastUpdate` | `String` | Formatted time of last update |
| `historicalData` | `List<EnergyData>` | Rolling 7-day history buffer |
| `notifications` | `List<NotificationItem>` | Alert history (max 10) |
| `avgDaily` | `double` | Average daily energy (kWh) |
| `minConsumption` | `double` | Minimum recorded energy value |
| `maxConsumption` | `double` | Maximum recorded energy value |
| `weeklyTotal` | `double` | Sum of all energy in 7-day window |

**Lifecycle methods:**

```
initState()
    ├── _testFirebaseConnection()    → verify & log connection status
    └── _setupFirebaseListener()     → subscribe to real-time stream

onValue event received:
    ├── parse raw Map data
    ├── sort timestamps (descending)
    ├── _updateDashboard()           → update live metrics & setState
    ├── _storeHistoricalData()       → append to history buffer & prune old records
    ├── _checkForAnomalies()         → generate alerts if thresholds breached
    └── setState(isConnected = true)
```

---

### 8.5 `DashboardView` — Live Readings Screen

**File:** `lib/screens/dashboard_view.dart`

A stateless widget that receives live data as constructor parameters and renders:
1. **Connection status bar**: green/red indicator + last update time
2. **MultiCircularGauge**: concentric ring visualization of Power, Energy, CO₂
3. **EnergyCard** widgets for Power (orange), Energy (blue), CO₂ (green)

---

### 8.6 `AnalyticsView` — Historical Analysis Screen

**File:** `lib/screens/analytics_view.dart`

A `StatefulWidget` with local toggle state (`showWeekly`). Renders:
1. **Toggle selector**: Daily (24h) / Weekly CO₂
2. **LineChart**: curved line with area fill from `fl_chart`
3. **StatCard grid**: 4 statistical metrics in a 2×2 layout

**Chart data computation (in `home_screen.dart`):**

- `_getDailyChartData()`: Groups last 24 hours of readings by hour, averages energy values per hour, returns 24 `FlSpot` points (x = hour 0–23, y = avg kWh)
- `_getWeeklyCO2ChartData()`: Groups last 7 days by weekday (Saturday to Friday order for Arabic calendar), sums CO₂ per day, returns 7 `FlSpot` points

---

### 8.7 `NotificationsView` — Alert History Screen

**File:** `lib/screens/notifications_view.dart`

Renders a scrollable list of `NotificationCard` widgets from the shared `notifications` list. Displays an empty-state message when no alerts exist.

---

### 8.8 `MultiCircularGauge` — Radial Gauge Widget

**File:** `lib/widgets/multi_circular_gauge.dart`

The most complex visual component in the application. Uses **Syncfusion Flutter Gauges** to render 5 concentric `RadialAxis` instances inside a single `SfRadialGauge`:

| Ring | Radius Factor | Color | Metric | Scale Max |
|------|--------------|-------|--------|-----------|
| Outermost | 1.0 | Green gradient | CO₂ | 100 kg |
| Middle | 0.85 | Blue gradient | Energy | 50 kWh |
| Inner | 0.70 | Orange gradient | Power | 5000 W |
| Device - Lighting | 0.50 | Amber | Lighting % | 100% |
| Device - Charger | 0.50 | Teal | Charger % | 100% |

All values are normalized to a 0–100% scale before display.

---

### 8.9 `EnergyCard` — Metric Display Card

**File:** `lib/widgets/energy_card.dart`

A reusable colored card showing:
- Icon + title + subtitle header
- Large numeric value display (48px font)
- Unit label
- Linear progress bar (value relative to defined maximum)

---

## 9. Firebase Database Schema

### 9.1 Database Structure

The application reads from the `/readings` path in Firebase Realtime Database. Each child node is keyed by a **Unix timestamp in milliseconds** (the time the reading was taken by the ESP32).

```json
{
  "readings": {
    "1738185000000": {
      "power_W": 1234.5,
      "voltage_V": 220.0,
      "current_A": 5.6,
      "energy_kWh": 1.234,
      "co2_kg": 0.494
    },
    "1738185060000": {
      "power_W": 1456.2,
      "voltage_V": 222.0,
      "current_A": 6.5,
      "energy_kWh": 1.456,
      "co2_kg": 0.582
    }
  }
}
```

### 9.2 Field Reference

| Field | Type | Unit | Description |
|-------|------|------|-------------|
| `power_W` | `float` | Watts (W) | Instantaneous electrical power |
| `voltage_V` | `float` | Volts (V) | RMS line voltage |
| `current_A` | `float` | Amperes (A) | RMS line current |
| `energy_kWh` | `float` | kWh | Accumulated energy for the interval |
| `co2_kg` | `float` | Kilograms | Estimated carbon emissions |

### 9.3 Firebase Security Rules

For the prototype, the following permissive rules are used (must be hardened before production):

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

> **Note for production:** Rules should authenticate requests and restrict write access to the ESP32 device only using Firebase Authentication tokens.

### 9.4 Firebase Project Configuration

The project is connected to Firebase project ID: `esp32-energy-monitor-acb16`
- **Database URL:** `https://esp32-energy-monitor-acb16-default-rtdb.firebaseio.com`
- **Platform:** Web/Android/iOS via unified `firebase_options.dart`

---

## 10. Hardware Integration (ESP32)

### 10.1 ESP32 Role

The ESP32 microcontroller acts as the **data acquisition layer** of the system. It:
1. Reads analog signals from electrical sensors
2. Converts raw ADC values to meaningful electrical units
3. Computes energy and CO₂ values
4. Connects to WiFi and pushes data to Firebase

### 10.2 Required Sensors

| Sensor | Measurement | Interface |
|--------|-------------|-----------|
| **ACS712** (or similar) | AC Current | Analog (ADC) |
| **ZMPT101B** (or similar) | AC Voltage | Analog (ADC) |
| ESP32 Internal | Timestamps | System Clock |

### 10.3 ESP32 Arduino Code (Reference)

```cpp
#include <WiFi.h>
#include <FirebaseESP32.h>

// WiFi credentials
const char* ssid     = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Firebase credentials
#define FIREBASE_HOST "esp32-energy-monitor-acb16-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "YOUR_DATABASE_SECRET"

// Sensor pins
#define CURRENT_PIN  34
#define VOLTAGE_PIN  35

FirebaseData fbdo;

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) delay(500);

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // --- Read sensors ---
  float voltage_raw = analogRead(VOLTAGE_PIN);
  float current_raw = analogRead(CURRENT_PIN);

  // Convert ADC values to real units
  float voltage_V = (voltage_raw / 4095.0) * 3.3 * (220.0 / 1.65); // calibrated
  float current_A = ((current_raw / 4095.0 * 3.3) - 2.5) / 0.185;  // ACS712 5A

  // Derived quantities
  float power_W    = voltage_V * current_A;
  float energy_kWh = power_W / 1000.0 * (1.0 / 3600.0); // per second → kWh
  float co2_kg     = energy_kWh * 0.4;

  // --- Push to Firebase ---
  String timestamp = String(millis()); // or use NTP-synced Unix time

  Firebase.setFloat(fbdo, "/readings/" + timestamp + "/power_W",    power_W);
  Firebase.setFloat(fbdo, "/readings/" + timestamp + "/voltage_V",  voltage_V);
  Firebase.setFloat(fbdo, "/readings/" + timestamp + "/current_A",  current_A);
  Firebase.setFloat(fbdo, "/readings/" + timestamp + "/energy_kWh", energy_kWh);
  Firebase.setFloat(fbdo, "/readings/" + timestamp + "/co2_kg",     co2_kg);

  delay(5000); // Push every 5 seconds
}
```

### 10.4 Sensor Calibration

The ACS712 current sensor requires calibration based on its variant:

| ACS712 Variant | Sensitivity | Current Range |
|----------------|-------------|---------------|
| ACS712-05B | 185 mV/A | ±5A |
| ACS712-20A | 100 mV/A | ±20A |
| ACS712-30A | 66 mV/A | ±30A |

For voltage, the ZMPT101B module provides an AC-to-DC scaled signal that must be calibrated against a known reference voltage.

---

## 11. Alert & Notification System

### 11.1 Threshold Definitions

| Alert Type | Condition | Severity |
|------------|-----------|----------|
| Overload Warning | `power_W > 4000` | 🔴 Danger |
| High Voltage | `voltage_V > 240` | 🟠 Warning |
| Low Voltage | `voltage_V < 200` | 🟠 Warning |

### 11.2 Alert Processing Logic

```dart
void _checkForAnomalies(Map<dynamic, dynamic> data) {
  final powerValue   = (data['power_W']   ?? 0.0).toDouble();
  final voltageValue = (data['voltage_V'] ?? 0.0).toDouble();

  if (powerValue > 4000) {
    _addNotification('danger', 'Overload Warning', 'Power: ${powerValue}W');
  }
  if (voltageValue > 240 || voltageValue < 200) {
    _addNotification('warning', 'Voltage Alert', 'Voltage: ${voltageValue}V');
  }
}
```

### 11.3 Deduplication

Before inserting any new notification, the system checks whether an identical alert (same title + same message) already exists in the list. If it does, the insertion is skipped — preventing alert flooding during sustained anomaly conditions.

---

## 12. Energy Calculations & Formulas

All energy and environmental calculations implemented in the system are based on standard electrical engineering formulas:

### 12.1 Ohm's Law & Power

```
Power (W) = Voltage (V) × Current (A)
P = V × I
```

### 12.2 Energy Consumption

```
Energy (kWh) = Power (kW) × Time (hours)
E = (P / 1000) × t
```

### 12.3 CO₂ Emissions

```
CO₂ (kg) = Energy (kWh) × Emission Factor
CO₂ = E × 0.4 kg/kWh
```

> The emission factor **0.4 kg CO₂ per kWh** is an average grid emission intensity used widely in energy studies. It may vary by country and energy source mix.

### 12.4 Percentage Normalization (for Gauges)

```
Power %   = (power_W   / 5000)  × 100   [max: 5000 W]
Energy %  = (energy    / 50)    × 100   [max: 50 kWh]
CO₂ %     = (co2       / 100)   × 100   [max: 100 kg]
```

---

## 13. Installation & Setup

### 13.1 Prerequisites

| Requirement | Version |
|-------------|---------|
| Flutter SDK | ≥ 3.x |
| Dart SDK | ≥ 3.8.1 |
| Android Studio / VS Code | Latest |
| Firebase Account | Free tier |
| Android device / Emulator | API 21+ |

### 13.2 Clone the Repository

```bash
git clone https://github.com/YourUsername/monitoring_energy_consumption.git
cd monitoring_energy_consumption
```

### 13.3 Install Dependencies

```bash
flutter pub get
```

### 13.4 Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create (or open) a project
3. Enable **Realtime Database** and set rules to allow read/write
4. Register your Android app (`com.example.monitoring_energy_consumption`)
5. Download `google-services.json` and place it in `android/app/`
6. Update `lib/firebase/firebase_options.dart` with your project credentials:

```dart
static FirebaseOptions get currentPlatform {
  return const FirebaseOptions(
    apiKey:            "YOUR_API_KEY",
    authDomain:        "YOUR_PROJECT.firebaseapp.com",
    databaseURL:       "https://YOUR_PROJECT-default-rtdb.firebaseio.com",
    projectId:         "YOUR_PROJECT",
    storageBucket:     "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId:             "YOUR_APP_ID",
  );
}
```

### 13.5 Run the Application

```bash
flutter run
```

For release build:
```bash
flutter build apk --release
```

---

## 14. Testing & Simulation

### 14.1 Built-in Test Data Generator

When ESP32 hardware is unavailable, the app includes a **TestDataService** that can seed Firebase with realistic simulated data. The `🧪` (science flask) button in the app header triggers this:

```dart
await _testDataService.addMultipleTestReadings(count: 24);
```

This writes 24 hourly readings simulating the past 24 hours of consumption directly to Firebase, immediately populating the charts and statistics.

### 14.2 Manual Firebase Data Entry

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Navigate to **Realtime Database → readings**
3. Click **+** to add a new child
4. Use a current Unix timestamp (ms) as the key
5. Add child fields: `power_W`, `voltage_V`, `current_A`, `energy_kWh`, `co2_kg`

### 14.3 Debug Logging

The application uses Dart's `dart:developer` logging throughout. Filter by tag in the debug console:

| Log Tag | Source |
|---------|--------|
| `FirebaseService` | Connection checks, data reads |
| `HomeScreen` | Firebase listener events |
| `UpdateDashboard` | Raw field parsing and final values |
| `TestDataService` | Test data insertion operations |

---

## 15. Limitations & Future Work

### 15.1 Current Limitations

| Limitation | Description |
|------------|-------------|
| **No authentication** | App has no login; any device can read/write the database |
| **Single-device monitoring** | Only one ESP32 node is supported per Firebase path |
| **Heuristic device detection** | Device type inference is rule-based, not sensor-based |
| **No local persistence** | Historical data is lost when the app is killed |
| **No push notifications** | Alerts only appear within the app; no background OS notifications |
| **Hardcoded thresholds** | Alert limits (4000W, 200–240V) are not configurable by the user |
| **Emission factor fixed** | CO₂ emission factor is constant at 0.4 kg/kWh |

### 15.2 Future Enhancements

1. **Firebase Authentication** — Secure access with user login
2. **Multi-device support** — Monitor multiple ESP32 nodes across different rooms/buildings
3. **Machine Learning anomaly detection** — Replace rule-based alerts with ML models trained on historical data
4. **Local SQLite persistence** — Cache historical data on device for offline access
5. **Push notifications** — Firebase Cloud Messaging (FCM) for background alerts
6. **User-configurable thresholds** — Settings screen to customize alert limits
7. **Energy cost calculation** — Input electricity tariff rate to calculate monthly bill estimates
8. **Export functionality** — Export readings as CSV or PDF for reporting
9. **Multi-language support** — Full internationalization (Arabic + English toggle)
10. **Web dashboard** — Flutter Web companion portal for desktop monitoring

---

## 16. References

1. **Flutter Documentation** — https://docs.flutter.dev
2. **Firebase Realtime Database** — https://firebase.google.com/docs/database
3. **ESP32 Arduino Core** — https://github.com/espressif/arduino-esp32
4. **Firebase ESP32 Client Library** — https://github.com/mobizt/Firebase-ESP32
5. **fl_chart Package** — https://pub.dev/packages/fl_chart
6. **Syncfusion Flutter Gauges** — https://pub.dev/packages/syncfusion_flutter_gauges
7. **ACS712 Current Sensor Datasheet** — Allegro MicroSystems
8. **ZMPT101B Voltage Sensor** — Zhongmao Electronic
9. **IEA Emission Factors** — International Energy Agency, 2023
10. **Dart Language Tour** — https://dart.dev/language

---

<div align="center">

**Developed as a Graduation Research Project**
**IoT-Based Real-Time Energy Monitoring System**

*Flutter · Firebase · ESP32 · Dart*

</div>
