# Build & Release Guide - Face Recognition Attendance

## 📦 Build APK untuk Testing/Sharing

### Quick Build (Debug APK)

Untuk berbagi dengan teman untuk testing:

```bash
# Build debug APK (paling cepat, untuk testing)
flutter build apk --debug

# Lokasi file: build/app/outputs/flutter-apk/app-debug.apk
```

### Production Build (Release APK)

Untuk distribusi yang lebih optimal:

```bash
# Build release APK (optimized, lebih kecil)
flutter build apk --release

# Lokasi file: build/app/outputs/flutter-apk/app-release.apk
```

### Build dengan Split APK (Recommended untuk Production)

Membuat APK terpisah per arsitektur (ukuran lebih kecil):

```bash
# Build split APK
flutter build apk --split-per-abi

# Menghasilkan 3 file:
# - app-armeabi-v7a-release.apk (untuk device 32-bit lama)
# - app-arm64-v8a-release.apk (untuk device 64-bit modern)
# - app-x86_64-release.apk (untuk emulator/tablet Intel)
```

---

## 🔧 Persiapan Sebelum Build

### 1. Update App Name & Icon (Optional)

#### Ubah Nama Aplikasi

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<application
    android:label="Face Attendance"  <!-- Ubah ini -->
    ...>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleName</key>
<string>Face Attendance</string>  <!-- Ubah ini -->
```

#### Ubah App Icon

1. Siapkan icon 1024x1024 px
2. Generate icon dengan tools:
   - [App Icon Generator](https://appicon.co/)
   - Atau gunakan package: `flutter pub add flutter_launcher_icons`

### 2. Update Version Number

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: major.minor.patch+buildNumber
# Contoh update:
# version: 1.0.1+2  (untuk bug fix)
# version: 1.1.0+3  (untuk fitur baru)
```

### 3. Bersihkan Build Cache (Jika Ada Error)

```bash
flutter clean
flutter pub get
```

---

## 📱 Install APK ke Device

### Via USB (ADB)

```bash
# Pastikan USB debugging aktif di HP
# Hubungkan HP ke komputer

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Atau langsung run
flutter install
```

### Via File Transfer

1. Copy APK dari `build/app/outputs/flutter-apk/` ke HP
2. Buka File Manager di HP
3. Tap file APK
4. Izinkan "Install from Unknown Sources" jika diminta
5. Tap "Install"

### Via Cloud/Link Sharing

1. Upload APK ke:
   - Google Drive
   - Dropbox
   - Firebase App Distribution
   - TestFlight (iOS)

2. Share link ke teman
3. Teman download & install

---

## 🔐 Code Signing (untuk Production)

### Generate Keystore

```bash
# Windows
keytool -genkey -v -keystore c:\Users\YOUR_NAME\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# macOS/Linux
keytool -genkey -v -keystore ~/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Simpan informasi:**
- Keystore password
- Key password
- Alias name

### Configure Signing

1. **Buat file `android/key.properties`:**
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:/Users/YOUR_NAME/upload-keystore.jks
```

2. **Update `android/app/build.gradle.kts`:**

```kotlin
// Tambahkan di atas android block
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config
    
    // Tambahkan signing configs
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Tambahkan optimizations
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

3. **Build signed APK:**
```bash
flutter build apk --release
```

---

## 📊 Optimize APK Size

### 1. Enable Obfuscation

```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

**Benefits:**
- Code lebih sulit di-reverse engineer
- Ukuran APK lebih kecil
- Performa sedikit lebih baik

### 2. Remove Unused Resources

Edit `android/app/build.gradle.kts`:
```kotlin
android {
    buildTypes {
        release {
            isShrinkResources = true
            isMinifyEnabled = true
        }
    }
}
```

### 3. Compress Images

- Gunakan WebP format untuk images
- Compress PNG/JPG sebelum add ke assets
- Tools: TinyPNG, ImageOptim

### 4. Analyze APK Size

```bash
# Build dengan size analysis
flutter build apk --analyze-size

# Atau gunakan Android Studio APK Analyzer
```

---

## 🚀 Build App Bundle (untuk Google Play)

### Generate AAB

```bash
flutter build appbundle --release
```

**Lokasi:** `build/app/outputs/bundle/release/app-release.aab`

### Upload ke Play Console

1. Login ke [Google Play Console](https://play.google.com/console)
2. Create new app
3. Upload AAB file
4. Fill app details
5. Submit for review

---

## ✅ Pre-Release Checklist

Sebelum share APK, pastikan:

- [ ] App name sudah benar
- [ ] App icon sudah custom
- [ ] Version number sudah update
- [ ] Semua fitur berfungsi di release mode
- [ ] Tidak ada debug code/logs
- [ ] Permissions sudah minimal & necessary
- [ ] Tested di berbagai device
- [ ] APK size reasonable (<50MB ideal)
- [ ] Supabase credentials sudah production
- [ ] Model TFLite sudah included di assets

---

## 🐛 Troubleshooting Build Issues

### Error: "Execution failed for task ':app:lintVitalRelease'"

**Solusi:**
```kotlin
// android/app/build.gradle.kts
android {
    lintOptions {
        checkReleaseBuilds = false
        abortOnError = false
    }
}
```

### Error: "Insufficient storage"

**Solusi:**
```bash
flutter clean
# Hapus folder build/
# Free up disk space
flutter build apk --release
```

### Error: "AAPT: error: resource android:attr/lStar not found"

**Solusi:**
```kotlin
// android/app/build.gradle.kts
android {
    compileSdk = 34  // Update ke SDK terbaru
}
```

### APK Crash saat Dibuka

**Debug:**
```bash
# Connect device via USB
adb logcat | grep flutter

# Atau build debug APK untuk testing
flutter build apk --debug
```

---

## 📋 Build Commands Reference

```bash
# Debug builds (untuk development)
flutter build apk --debug
flutter build apk --profile

# Release builds (untuk production)
flutter build apk --release
flutter build apk --release --split-per-abi
flutter build appbundle --release

# Dengan optimizations
flutter build apk --release --obfuscate --split-debug-info=build/symbols

# Install langsung ke device
flutter install
flutter run --release

# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📤 Distribution Options

### 1. Direct APK Sharing
- **Pros:** Mudah, cepat
- **Cons:** Harus enable "Unknown Sources"
- **Best for:** Testing dengan teman

### 2. Firebase App Distribution
- **Pros:** Tracking, analytics, auto-update
- **Cons:** Perlu setup Firebase
- **Best for:** Beta testing team

### 3. Google Play Store
- **Pros:** Official, trusted, auto-update
- **Cons:** Review process, $25 one-time fee
- **Best for:** Public release

### 4. Third-party Stores
- APKPure
- Amazon Appstore
- Samsung Galaxy Store

---

## 🔄 Update Flow

Saat ada update aplikasi:

1. **Update version di `pubspec.yaml`:**
   ```yaml
   version: 1.0.1+2  # Increment build number
   ```

2. **Build new APK:**
   ```bash
   flutter build apk --release
   ```

3. **Distribute:**
   - Share APK baru ke users
   - Atau upload ke Play Store

4. **Users install:**
   - Android akan otomatis replace versi lama
   - Data tetap tersimpan (jika applicationId sama)

---

**Last Updated**: 7 Desember 2024
