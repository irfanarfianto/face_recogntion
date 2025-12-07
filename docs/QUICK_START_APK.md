# Quick Start - Berbagi APK ke Teman

## 🚀 Cara Tercepat Build & Share APK

### Step 1: Build APK
```bash
# Jalankan command ini di terminal
flutter build apk --release
```

**Waktu:** ~5-10 menit (tergantung spesifikasi komputer)

### Step 2: Temukan File APK

Setelah build selesai, file APK ada di:
```
test_face_recognition/build/app/outputs/flutter-apk/app-release.apk
```

**Ukuran file:** Sekitar 40-60 MB

### Step 3: Share ke Teman

#### Opsi A: Via Google Drive
1. Upload `app-release.apk` ke Google Drive
2. Klik kanan → Get link → Copy link
3. Share link ke teman
4. Teman download & install

#### Opsi B: Via WhatsApp/Telegram
1. Kirim file `app-release.apk` langsung via chat
2. Teman download
3. Tap file untuk install

#### Opsi C: Via USB/Bluetooth
1. Copy file ke HP teman
2. Buka File Manager
3. Tap file APK
4. Install

---

## 📱 Cara Install di HP Android

### 1. Download APK
- Dari link Google Drive
- Dari WhatsApp/Telegram
- Dari file transfer

### 2. Izinkan Install dari Sumber Tidak Dikenal

**Android 8.0+:**
1. Saat tap APK, akan muncul popup
2. Tap "Settings" atau "Pengaturan"
3. Enable "Allow from this source"
4. Kembali dan tap APK lagi

**Android 7.0 dan lebih lama:**
1. Buka Settings → Security
2. Enable "Unknown Sources"
3. Tap APK untuk install

### 3. Install Aplikasi
1. Tap file APK
2. Tap "Install"
3. Tunggu proses instalasi
4. Tap "Open" untuk buka aplikasi

---

## ⚠️ Catatan Penting

### Permissions yang Diperlukan
Aplikasi akan meminta izin:
- ✅ **Camera** - Untuk face recognition
- ✅ **Internet** - Untuk koneksi ke Supabase

### Kompatibilitas
- ✅ Android 5.0 (Lollipop) atau lebih baru
- ✅ Minimal RAM 2GB
- ✅ Kamera depan (front camera)

### Troubleshooting

#### "App not installed"
**Penyebab:** APK corrupt atau tidak kompatibel
**Solusi:** 
- Download ulang APK
- Pastikan HP support Android 5.0+

#### "Parse error"
**Penyebab:** APK rusak saat download
**Solusi:**
- Download ulang dengan koneksi stabil
- Gunakan Google Drive instead of WhatsApp

#### "Installation blocked"
**Penyebab:** Google Play Protect
**Solusi:**
1. Tap "More details"
2. Tap "Install anyway"

---

## 🔄 Update Aplikasi

Jika ada versi baru:
1. Download APK versi baru
2. Install langsung (akan replace versi lama)
3. Data tetap tersimpan

---

## 📞 Support

Jika teman mengalami masalah:
1. Pastikan Android version minimal 5.0
2. Pastikan ada ruang storage (minimal 100MB)
3. Restart HP dan coba lagi
4. Hubungi developer untuk bantuan

---

## ✅ Checklist Sebelum Share

- [ ] APK sudah di-build dengan `flutter build apk --release`
- [ ] File APK sudah ditemukan di folder build
- [ ] Sudah test install di HP sendiri
- [ ] Aplikasi berfungsi normal (camera, database, dll)
- [ ] Sudah upload ke cloud storage atau siap share
- [ ] Sudah buat instruksi install untuk teman

---

**Tips:** Rename file APK menjadi lebih deskriptif sebelum share:
```
app-release.apk  →  FaceAttendance-v1.0.0.apk
```

Ini memudahkan teman untuk mengenali aplikasi dan versinya.
