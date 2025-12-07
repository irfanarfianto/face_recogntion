# Face Recognition Attendance System - Dokumentasi Lengkap

## 📋 Daftar Isi
1. [Ringkasan Proyek](#ringkasan-proyek)
2. [Fitur Utama](#fitur-utama)
3. [Arsitektur Aplikasi](#arsitektur-aplikasi)
4. [Tech Stack](#tech-stack)
5. [Struktur Database](#struktur-database)
6. [Instalasi & Setup](#instalasi--setup)
7. [Panduan Penggunaan](#panduan-penggunaan)
8. [Fitur Keamanan](#fitur-keamanan)
9. [Konfigurasi & Pengaturan](#konfigurasi--pengaturan)
10. [Troubleshooting](#troubleshooting)
11. [Roadmap & Pengembangan](#roadmap--pengembangan)

---

## 🎯 Ringkasan Proyek

**Face Recognition Attendance System** adalah aplikasi mobile berbasis Flutter yang menggunakan teknologi pengenalan wajah untuk sistem presensi/absensi. Aplikasi ini memanfaatkan AI/ML untuk mendeteksi dan mengenali wajah pengguna secara real-time dengan akurasi tinggi.

### Tujuan Aplikasi
- ✅ Menyediakan sistem absensi yang cepat dan contactless
- ✅ Meningkatkan keamanan dengan liveness detection (anti-spoofing)
- ✅ Memberikan pengalaman pengguna yang seamless dan intuitif
- ✅ Menyediakan data analitik untuk monitoring kehadiran

---

## ✨ Fitur Utama

### 1. **Registrasi Wajah**
- Input nama pengguna
- Capture foto wajah menggunakan kamera depan
- Ekstraksi face embedding menggunakan MobileFaceNet
- Penyimpanan data ke Supabase

### 2. **Presensi dengan Face Recognition**
- **Real-time Face Detection**: Deteksi wajah secara langsung dari kamera
- **Face Centering Guide**: Panduan visual untuk memposisikan wajah di tengah
- **Liveness Detection**: Verifikasi kedipan mata untuk mencegah spoofing
- **Auto Brightness**: Layar otomatis terang saat scanning untuk pencahayaan optimal
- **Match Score Display**: Menampilkan skor kemiripan secara real-time
- **Instant Feedback**: Notifikasi sukses/gagal dengan animasi

### 3. **Keamanan Anti-Spoofing**
- **Blink Detection**: Sistem meminta pengguna berkedip untuk memastikan wajah asli (bukan foto)
- **Eye Open Probability**: Menggunakan ML Kit untuk mendeteksi mata terbuka/tertutup
- **Multi-stage Verification**: 
  1. Deteksi wajah di tengah
  2. Verifikasi liveness (kedip)
  3. Pencocokan embedding

### 4. **Pengaturan Threshold**
- Slider untuk mengatur sensitivitas pengenalan (0.5 - 1.5)
- Nilai default: 1.0
- Semakin kecil = lebih ketat (akurat tapi strict)
- Semakin besar = lebih longgar (mudah tapi risiko false positive)

### 5. **Riwayat & Logs**
- Daftar presensi dengan timestamp
- Detail match score untuk setiap absensi
- Filter dan pencarian data

### 6. **Manajemen User**
- Lihat daftar user terdaftar
- Hapus user (cascade delete dengan attendance logs)
- Update data user

---

## 🏗️ Arsitektur Aplikasi

Aplikasi ini menggunakan **Clean Architecture** dengan **BLoC Pattern** untuk state management.

```
lib/
├── core/
│   ├── error/
│   │   └── failures.dart          # Error handling abstraction
│   ├── theme/
│   │   └── app_theme.dart         # Tema aplikasi
│   └── utils/
│       └── ml_kit_utils.dart      # Helper untuk ML Kit
│
├── features/
│   └── attendance/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── attendance_remote_data_source.dart
│       │   │   └── face_local_data_source.dart
│       │   ├── models/
│       │   │   ├── attendance_log_model.dart
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── attendance_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── attendance_log_entity.dart
│       │   │   └── user_entity.dart
│       │   ├── repositories/
│       │   │   └── attendance_repository.dart
│       │   └── usecases/
│       │       ├── authenticate_user.dart
│       │       ├── register_user.dart
│       │       ├── get_attendance_logs.dart
│       │       └── ...
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── attendance_bloc.dart
│           │   ├── attendance_event.dart
│           │   └── attendance_state.dart
│           ├── pages/
│           │   ├── attendance_page.dart
│           │   ├── loading_analysis_page.dart
│           │   ├── register_page.dart
│           │   ├── settings_page.dart
│           │   ├── logs_page.dart
│           │   └── manage_users_page.dart
│           └── widgets/
│               ├── face_painter.dart
│               ├── camera_preview_widget.dart
│               └── camera_header_overlay.dart
│
├── injection_container.dart       # Dependency Injection (GetIt)
└── main.dart                       # Entry point
```

### Layer Responsibilities

#### 1. **Presentation Layer**
- **BLoC**: Mengelola state dan business logic UI
- **Pages**: Halaman-halaman aplikasi
- **Widgets**: Komponen UI reusable

#### 2. **Domain Layer**
- **Entities**: Model data murni (business objects)
- **Repositories**: Interface/contract untuk data operations
- **Use Cases**: Business logic yang spesifik (single responsibility)

#### 3. **Data Layer**
- **Data Sources**: 
  - Remote (Supabase API)
  - Local (TFLite, SharedPreferences)
- **Models**: Data models dengan serialization
- **Repository Implementation**: Implementasi konkret dari domain repository

---

## 🛠️ Tech Stack

### Frontend
- **Flutter SDK**: ^3.10.1
- **Dart**: ^3.10.1

### State Management & Architecture
- **flutter_bloc**: ^9.1.1 - State management
- **get_it**: ^9.2.0 - Dependency injection
- **dartz**: ^0.10.1 - Functional programming (Either)
- **equatable**: ^2.0.7 - Value equality

### Backend & Database
- **supabase_flutter**: ^2.10.3 - Backend as a Service

### AI/ML & Computer Vision
- **google_mlkit_face_detection**: ^0.13.1 - Face detection
- **tflite_flutter**: ^0.12.1 - TensorFlow Lite runtime
- **camera**: ^0.11.3 - Camera access
- **image**: ^4.5.4 - Image processing

### Storage & Utilities
- **shared_preferences**: ^2.5.3 - Local key-value storage
- **path_provider**: ^2.1.5 - File system paths
- **screen_brightness**: ^2.1.7 - Screen brightness control

### UI/UX
- **lottie**: ^3.3.2 - Animations
- **intl**: ^0.20.2 - Internationalization & formatting

---

## 🗄️ Struktur Database

### Tabel: `users`
Menyimpan data pengguna dan face embedding mereka.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  face_embedding JSONB NOT NULL,  -- Array of 192 float values
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk performa
CREATE INDEX idx_users_name ON users(name);
```

**Kolom:**
- `id`: UUID unik untuk setiap user
- `name`: Nama lengkap user
- `face_embedding`: Vector 192 dimensi dari MobileFaceNet (disimpan sebagai JSON array)
- `created_at`: Timestamp pendaftaran

### Tabel: `attendance_logs`
Menyimpan riwayat presensi.

```sql
CREATE TABLE attendance_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  scan_time TIMESTAMPTZ DEFAULT NOW(),
  match_score FLOAT NOT NULL,  -- Euclidean distance score
  status TEXT DEFAULT 'present'
);

-- Indexes untuk query performa
CREATE INDEX idx_attendance_user_id ON attendance_logs(user_id);
CREATE INDEX idx_attendance_scan_time ON attendance_logs(scan_time DESC);
```

**Kolom:**
- `id`: UUID unik untuk setiap log
- `user_id`: Foreign key ke tabel users
- `scan_time`: Waktu presensi
- `match_score`: Skor kemiripan (Euclidean distance)
- `status`: Status kehadiran (present, late, dll)

### Row Level Security (RLS)
```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_logs ENABLE ROW LEVEL SECURITY;

-- Policy untuk public access (sesuaikan dengan kebutuhan)
CREATE POLICY "Enable read access for all users" ON users
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable read access for all users" ON attendance_logs
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON attendance_logs
  FOR INSERT WITH CHECK (true);
```

---

## 📦 Instalasi & Setup

### Prerequisites
- Flutter SDK (3.10.1 atau lebih baru)
- Dart SDK (3.10.1 atau lebih baru)
- Android Studio / VS Code
- Akun Supabase

### Langkah Instalasi

#### 1. Clone Repository
```bash
git clone <repository-url>
cd test_face_recognition
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Setup Supabase

**a. Buat Project Baru di Supabase**
- Kunjungi [supabase.com](https://supabase.com)
- Buat project baru
- Catat `URL` dan `anon key`

**b. Buat Database Schema**
Jalankan SQL berikut di Supabase SQL Editor:

```sql
-- Lihat file schema.sql untuk script lengkap
```

**c. Konfigurasi Supabase di Aplikasi**
Buat file `lib/core/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

#### 4. Setup Model TFLite

**a. Download Model MobileFaceNet**
- Download model dari repository atau sumber terpercaya
- Pastikan format: `.tflite`

**b. Tambahkan ke Assets**
```
assets/
└── model/
    └── tflite/
        └── mobilefacenet.tflite
```

**c. Update pubspec.yaml**
```yaml
flutter:
  assets:
    - assets/model/tflite/
```

#### 5. Konfigurasi Platform

**Android (android/app/build.gradle)**
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

**Android Permissions (android/app/src/main/AndroidManifest.xml)**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

**iOS (ios/Runner/Info.plist)**
```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan akses kamera untuk face recognition</string>
```

#### 6. Run Aplikasi
```bash
# Debug mode
flutter run

# Release mode (Android)
flutter build apk --release

# Release mode (iOS)
flutter build ios --release
```

---

## 📱 Panduan Penggunaan

### 1. Registrasi User Baru

1. Buka aplikasi
2. Tap tombol **"Daftar Wajah Baru"**
3. Masukkan nama lengkap
4. Posisikan wajah di depan kamera
5. Pastikan pencahayaan cukup
6. Tap **"Simpan Wajah"**
7. Tunggu proses ekstraksi embedding
8. Selesai! User terdaftar

**Tips:**
- Pastikan wajah terlihat jelas
- Hindari backlight
- Lepas kacamata/masker untuk akurasi optimal
- Ekspresi netral

### 2. Melakukan Presensi

1. Tap tombol **"Absen"** di home page
2. Kamera akan terbuka dengan layar terang otomatis
3. Posisikan wajah di dalam lingkaran panduan
4. **Instruksi akan muncul**: "Silakan kedipkan mata untuk verifikasi"
5. Kedipkan mata Anda
6. Instruksi berubah: "Buka mata Anda..."
7. Setelah mata terbuka, instruksi: "Tahan posisi..."
8. Sistem akan otomatis mengambil foto dan mencocokkan
9. Navigasi ke halaman loading dengan animasi
10. Hasil ditampilkan:
    - **Sukses**: "Selamat datang, [Nama]!"
    - **Gagal**: "Wajah tidak dikenali" atau "Kemiripan rendah"

**Alur Liveness Detection:**
```
Wajah Terdeteksi → Posisi Tengah → Kedip Mata → Mata Terbuka → Capture → Matching
```

### 3. Mengatur Threshold

1. Tap **"Pengaturan"** di home page
2. Geser slider **"Threshold Kemiripan"**
3. Nilai ditampilkan secara real-time
4. Tap **"Simpan"**
5. Threshold baru akan digunakan untuk presensi berikutnya

**Rekomendasi Nilai:**
- **0.5 - 0.7**: Sangat ketat (untuk keamanan tinggi)
- **0.8 - 1.0**: Seimbang (recommended)
- **1.1 - 1.5**: Longgar (untuk kemudahan)

### 4. Melihat Riwayat

1. Tap **"Riwayat Presensi"**
2. Lihat daftar presensi dengan:
   - Nama user
   - Waktu scan
   - Match score
3. Scroll untuk melihat lebih banyak

### 5. Manajemen User

1. Tap **"Kelola User"**
2. Lihat daftar semua user terdaftar
3. Tap user untuk melihat detail
4. Opsi:
   - **Hapus**: Menghapus user dan semua log presensinya
   - **Edit**: Update nama (coming soon)

---

## 🔒 Fitur Keamanan

### 1. Liveness Detection (Anti-Spoofing)

Sistem menggunakan **Blink Detection** untuk memastikan wajah yang di-scan adalah wajah manusia hidup, bukan foto atau video.

**Cara Kerja:**
1. **Eye Open Probability Detection**
   - Menggunakan `google_mlkit_face_detection`
   - Mendeteksi nilai `leftEyeOpenProbability` dan `rightEyeOpenProbability`
   
2. **State Machine**
   ```
   State 1: Mata Terbuka (probability > 0.5)
   State 2: Mata Tertutup (probability < 0.2) → _isBlinking = true
   State 3: Mata Terbuka Lagi (probability > 0.5) → _livenessVerified = true
   ```

3. **Threshold Values**
   - Mata tertutup: `< 0.2`
   - Mata terbuka: `> 0.5`
   - Range ini mencegah false positive dari gerakan kecil

**Keuntungan:**
- ✅ Mencegah penggunaan foto cetak
- ✅ Mencegah penggunaan foto digital di layar HP/tablet
- ✅ Mencegah video playback
- ✅ User-friendly (hanya perlu kedip sekali)

### 2. Face Embedding Security

- **Dimensi**: 192-dimensional vector
- **Normalisasi**: L2 normalization untuk konsistensi
- **Enkripsi**: Data disimpan di Supabase dengan enkripsi at-rest
- **Tidak Reversible**: Embedding tidak bisa di-reverse menjadi foto asli

### 3. Threshold-based Matching

Menggunakan **Euclidean Distance** untuk menghitung kemiripan:

```dart
double calculateDistance(List<double> embedding1, List<double> embedding2) {
  double sum = 0.0;
  for (int i = 0; i < embedding1.length; i++) {
    sum += pow(embedding1[i] - embedding2[i], 2);
  }
  return sqrt(sum);
}
```

**Interpretasi:**
- Distance = 0.0: Identik (kemungkinan foto yang sama)
- Distance < 0.8: Sangat mirip (orang yang sama)
- Distance 0.8 - 1.2: Mirip (perlu verifikasi)
- Distance > 1.2: Berbeda (orang lain)

---

## ⚙️ Konfigurasi & Pengaturan

### 1. Threshold Configuration

**Lokasi**: `SettingsPage` → Slider

**Cara Kerja:**
```dart
// Simpan ke SharedPreferences
await prefs.setDouble('face_threshold', newValue);

// Load saat startup
final threshold = prefs.getDouble('face_threshold') ?? 1.0;

// Gunakan saat matching
if (distance < threshold) {
  // Match!
}
```

### 2. Camera Configuration

**Resolution**: `ResolutionPreset.medium`
- Balance antara kualitas dan performa
- Cukup untuk face detection

**Image Format**: `ImageFormatGroup.nv21`
- Format optimal untuk ML Kit di Android
- Performa lebih baik daripada YUV420

### 3. Face Detection Options

```dart
final options = FaceDetectorOptions(
  performanceMode: FaceDetectorMode.fast,  // Fast vs Accurate
  enableClassification: true,              // Enable eye/smile detection
  minFaceSize: 0.15,                       // Min 15% of screen
);
```

### 4. Brightness Control

```dart
// Set max brightness saat scan
await ScreenBrightness().setScreenBrightness(1.0);

// Reset ke system brightness
await ScreenBrightness().resetScreenBrightness();
```

---

## 🐛 Troubleshooting

### 1. Kamera Tidak Muncul

**Penyebab:**
- Permission tidak diberikan
- Kamera sedang digunakan aplikasi lain

**Solusi:**
```bash
# Check permissions di AndroidManifest.xml
# Restart aplikasi
# Pastikan tidak ada aplikasi lain yang menggunakan kamera
```

### 2. Face Detection Lambat

**Penyebab:**
- Device low-end
- Resolution terlalu tinggi

**Solusi:**
```dart
// Turunkan resolution
ResolutionPreset.low  // dari medium
```

### 3. Liveness Detection Tidak Bekerja

**Penyebab:**
- `enableClassification` tidak aktif
- Pencahayaan terlalu gelap

**Solusi:**
- Pastikan `enableClassification: true`
- Gunakan auto brightness
- Tambahkan pencahayaan

### 4. Match Score Selalu Tinggi

**Penyebab:**
- Threshold terlalu besar
- Model tidak ter-load dengan benar

**Solusi:**
```dart
// Cek model path
final modelPath = 'assets/model/tflite/mobilefacenet.tflite';

// Verifikasi model loaded
print('Model loaded: ${interpreter != null}');

// Turunkan threshold
```

### 5. Supabase Connection Error

**Penyebab:**
- URL/Key salah
- Internet tidak stabil
- RLS policy terlalu ketat

**Solusi:**
```dart
// Verifikasi config
print(SupabaseConfig.supabaseUrl);

// Test connection
final response = await supabase.from('users').select().limit(1);

// Check RLS policies di Supabase dashboard
```

---

## 🚀 Roadmap & Pengembangan

### Phase 1: Core Features ✅
- [x] Face registration
- [x] Face recognition attendance
- [x] Threshold configuration
- [x] Attendance logs
- [x] User management

### Phase 2: Security & UX ✅
- [x] Liveness detection (blink)
- [x] Auto brightness
- [x] Loading states
- [x] Error handling
- [x] Modular widgets

### Phase 3: Advanced Features (Planned)
- [ ] Multi-face detection (group attendance)
- [ ] Face mask detection
- [ ] Emotion recognition
- [ ] Voice confirmation
- [ ] QR code fallback
- [ ] Offline mode dengan sync
- [ ] Export data (CSV/PDF)
- [ ] Dashboard analytics
- [ ] Push notifications
- [ ] Admin panel

### Phase 4: Enterprise Features (Future)
- [ ] Multi-tenant support
- [ ] Role-based access control
- [ ] Integration dengan HR systems
- [ ] Geofencing (location-based attendance)
- [ ] Shift management
- [ ] Leave management
- [ ] Payroll integration

---

## 📄 Lisensi

Proyek ini adalah prototype untuk tujuan pembelajaran dan demonstrasi.

---

## 👥 Kontributor

Dikembangkan dengan ❤️ menggunakan Flutter & Supabase

---

## 📞 Support

Untuk pertanyaan atau issue, silakan buat issue di repository atau hubungi tim development.

---

**Last Updated**: 7 Desember 2024
**Version**: 1.0.0
