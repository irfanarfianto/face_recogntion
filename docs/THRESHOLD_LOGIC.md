# Threshold Logic - Match/Fail Badge

## 📊 Ringkasan

Badge "MATCH" atau "FAIL" di halaman Logs **sekarang menggunakan threshold yang tersimpan di database** (threshold yang digunakan saat absensi), bukan threshold lokal saat ini.

---

## 🔍 Sebelum Perbaikan (Masalah)

### Kode Lama:
```dart
// Badge menggunakan state.threshold (lokal)
(log.matchScore ?? 1.0) < state.threshold
    ? "MATCH"
    : "FAIL"
```

### Masalah:
1. User absen dengan threshold **1.0** → Score: **0.85** → **MATCH** ✅
2. Database menyimpan: `match_score: 0.85`, `val_threshold: 1.0`
3. User ubah threshold jadi **0.7**
4. Buka halaman logs → Badge jadi **FAIL** ❌ (karena 0.85 > 0.7)

**Hasil:** Badge tidak konsisten dengan hasil absensi asli!

---

## ✅ Setelah Perbaikan (Solusi)

### Kode Baru:
```dart
// Badge menggunakan log.threshold (database) dengan fallback ke state.threshold
(log.matchScore ?? 1.0) < (log.threshold ?? state.threshold)
    ? "MATCH"
    : "FAIL"
```

### Keuntungan:
1. ✅ **Akurasi Historis**: Badge selalu menunjukkan hasil sebenarnya saat absensi
2. ✅ **Konsistensi**: Tidak berubah meskipun threshold lokal diubah
3. ✅ **Backward Compatible**: Fallback ke `state.threshold` untuk log lama yang tidak punya `val_threshold`

---

## 📦 Struktur Data

### Database Schema
```sql
CREATE TABLE attendance_logs (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  scan_time TIMESTAMPTZ,
  match_score FLOAT,           -- Euclidean distance
  val_threshold FLOAT,         -- Threshold yang digunakan saat absensi
  image_url TEXT,
  face_attributes JSONB
);
```

### Model
```dart
class AttendanceLogEntity {
  final String id;
  final String userName;
  final DateTime scanTime;
  final double? matchScore;      // Score dari face matching
  final double? threshold;       // Threshold yang digunakan saat absensi
  final String? imageUrl;
  // ...
}
```

---

## 🎯 Logic Flow

### Saat Absensi (Menyimpan)
```dart
// 1. User scan wajah
final matchScore = 0.85;

// 2. Load threshold lokal
final currentThreshold = await getThreshold(); // 1.0

// 3. Cek apakah match
final isMatch = matchScore < currentThreshold; // true

// 4. Simpan ke database
await saveAttendanceLog(
  userId: userId,
  matchScore: 0.85,
  threshold: 1.0,  // ← Simpan threshold yang digunakan
);
```

### Saat Menampilkan Logs (Membaca)
```dart
// 1. Load logs dari database
final logs = await getAttendanceLogs();

// 2. Untuk setiap log, tentukan badge
for (final log in logs) {
  // Gunakan threshold dari database (saat absensi)
  final thresholdUsed = log.threshold ?? currentLocalThreshold;
  
  final badge = (log.matchScore ?? 1.0) < thresholdUsed
      ? "MATCH"
      : "FAIL";
}
```

---

## 🔄 Skenario Penggunaan

### Skenario 1: Normal Flow
```
1. Threshold lokal: 1.0
2. User absen → Score: 0.85 → MATCH ✅
3. Database: {score: 0.85, threshold: 1.0}
4. Tampil di logs → Badge: MATCH ✅ (0.85 < 1.0)
```

### Skenario 2: Threshold Berubah
```
1. Threshold lokal: 1.0
2. User absen → Score: 0.85 → MATCH ✅
3. Database: {score: 0.85, threshold: 1.0}
4. User ubah threshold → 0.7
5. Tampil di logs → Badge: MATCH ✅ (0.85 < 1.0 dari database)
   ✅ Tetap MATCH karena pakai threshold saat absensi!
```

### Skenario 3: Log Lama (Backward Compatibility)
```
1. Log lama tidak punya val_threshold (NULL)
2. Fallback ke threshold lokal saat ini
3. Badge: (score < currentThreshold) ? MATCH : FAIL
```

---

## 📊 Perbandingan

| Aspek | Sebelum | Sesudah |
|-------|---------|---------|
| **Sumber Threshold** | Lokal (SharedPreferences) | Database (val_threshold) |
| **Konsistensi** | ❌ Berubah jika threshold diubah | ✅ Tetap konsisten |
| **Akurasi Historis** | ❌ Tidak akurat | ✅ Akurat |
| **Backward Compatibility** | ✅ Ya | ✅ Ya (dengan fallback) |

---

## 🛠️ Implementasi Detail

### Di Logs Page
```dart
// File: lib/features/attendance/presentation/pages/logs_page.dart

trailing: Container(
  decoration: BoxDecoration(
    // Gunakan log.threshold (database) jika ada, fallback ke state.threshold
    color: (log.matchScore ?? 1.0) < (log.threshold ?? state.threshold)
        ? Colors.green[50]
        : Colors.red[50],
  ),
  child: Text(
    (log.matchScore ?? 1.0) < (log.threshold ?? state.threshold)
        ? "MATCH"
        : "FAIL",
    style: TextStyle(
      color: (log.matchScore ?? 1.0) < (log.threshold ?? state.threshold)
          ? Colors.green
          : Colors.red,
    ),
  ),
),
```

### Di Detail Expansion
```dart
// Menampilkan threshold yang digunakan
if (log.threshold != null) ...[
  _buildDetailRow(
    'Threshold Used',
    log.threshold!.toStringAsFixed(6),
  ),
],
```

---

## 🎓 Best Practices

### 1. Selalu Simpan Context
Saat menyimpan data historis, simpan juga parameter yang digunakan:
- ✅ Threshold yang digunakan
- ✅ Model version
- ✅ Timestamp
- ✅ Face attributes

### 2. Fallback Strategy
Untuk backward compatibility:
```dart
final effectiveThreshold = log.threshold ?? defaultThreshold;
```

### 3. Display Transparency
Tampilkan threshold yang digunakan di detail:
```
Distance Score: 0.850000
Threshold Used: 1.000000  ← User tahu threshold saat itu
Result: MATCH ✅
```

---

## 🔍 Debugging

### Cek Threshold di Database
```sql
SELECT 
  id,
  match_score,
  val_threshold,
  scan_time
FROM attendance_logs
ORDER BY scan_time DESC
LIMIT 10;
```

### Cek Threshold Lokal
```dart
final threshold = await SharedPreferences.getInstance()
    .then((prefs) => prefs.getDouble('face_threshold') ?? 1.0);
print('Current local threshold: $threshold');
```

---

## 📝 Kesimpulan

**Jawaban untuk pertanyaan Anda:**

> Badge match atau fail pada tampilan log berdasarkan threshold yang di lokal atau di database?

**Jawaban:** Sekarang **berdasarkan threshold di DATABASE** (yang tersimpan saat absensi).

**Alasan:**
- ✅ Lebih akurat secara historis
- ✅ Konsisten meskipun setting berubah
- ✅ Mencerminkan keputusan sistem saat absensi terjadi

**Fallback:** Jika log lama tidak punya threshold di database, akan menggunakan threshold lokal saat ini.

---

**Last Updated**: 7 Desember 2024
