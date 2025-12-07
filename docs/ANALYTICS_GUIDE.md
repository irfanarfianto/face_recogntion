# Analytics Dashboard - Documentation

## 📊 Overview

Analytics Dashboard adalah fitur untuk menganalisis performa sistem face recognition dengan metrik-metrik evaluasi yang komprehensif.

---

## 🎯 Fitur Utama

### 1. **Summary Cards**
Ringkasan cepat performa sistem:
- **Total Scans**: Jumlah total percobaan absensi
- **Success Rate**: Persentase keberhasilan
- **Match Count**: Jumlah yang berhasil match
- **Fail Count**: Jumlah yang gagal

### 2. **Performance Metrics**

#### A. **Accuracy Rate**
```
Accuracy = (Total Match / Total Scans) × 100%
```
- Mengukur seberapa akurat sistem secara keseluruhan
- **Target**: > 95% untuk production

#### B. **FAR (False Acceptance Rate)**
```
FAR = (False Accepts / Total Impostors) × 100%
```
- Persentase impostor yang diterima sistem
- **Estimasi**: Score > 1.2 dianggap impostor
- **Target**: < 1% untuk high security

#### C. **FRR (False Rejection Rate)**
```
FRR = (False Rejects / Total Genuine) × 100%
```
- Persentase user asli yang ditolak sistem
- **Estimasi**: Score < 0.8 dianggap genuine
- **Target**: < 5% untuk good UX

#### D. **EER (Equal Error Rate)**
```
EER = (FAR + FRR) / 2
```
- Titik keseimbangan antara FAR dan FRR
- **Target**: < 3% untuk sistem yang baik

---

## 📈 Score Distribution

Histogram yang menunjukkan distribusi score:

```
Range       Count    Visualization
0.0-0.5     12      ████████████
0.5-0.7     45      ████████████████████████████████
0.7-0.9     38      ██████████████████████████
0.9-1.0     28      ████████████████████
1.0-1.1     15      ██████████
1.1-1.3     8       █████
1.3-1.5     3       ██
1.5-2.0     1       █
```

**Interpretasi:**
- **Green (< 0.7)**: Excellent match
- **Light Green (0.7-1.0)**: Good match
- **Orange (1.0-1.2)**: Fair match
- **Red (> 1.2)**: Poor match / Likely impostor

---

## 🎚️ Threshold Analysis

Menampilkan acceptance rate pada berbagai threshold:

```
Threshold  Acceptance Rate  Bar
0.5        15%              ███
0.6        28%              ██████
0.7        45%              █████████
0.8        62%              ████████████
0.9        78%              ████████████████
1.0        85%  ← Current   █████████████████
1.1        92%              ██████████████████
1.2        96%              ███████████████████
1.3        98%              ████████████████████
1.4        99%              ████████████████████
1.5        100%             █████████████████████
```

**Cara Membaca:**
- Threshold lebih rendah = lebih ketat = lebih sedikit yang diterima
- Threshold lebih tinggi = lebih longgar = lebih banyak yang diterima
- **Current** menunjukkan threshold yang sedang digunakan

---

## 💡 Recommendations

Sistem memberikan rekomendasi otomatis berdasarkan metrik:

### 1. **High FAR (> 10%)**
```
🔒 High False Acceptance Rate
Consider lowering threshold to 0.8-0.9 for better security
```
**Artinya:** Terlalu banyak impostor yang diterima, perlu threshold lebih ketat

### 2. **High FRR (> 10%)**
```
⚠️ High False Rejection Rate
Consider raising threshold to 1.1-1.2 for better user experience
```
**Artinya:** Terlalu banyak user asli yang ditolak, perlu threshold lebih longgar

### 3. **Excellent Performance (Accuracy > 95%)**
```
✅ Excellent Performance
Current threshold (1.00) is optimal
```
**Artinya:** Sistem sudah optimal, tidak perlu perubahan

---

## 📊 Metrik Evaluasi Detail

### 1. Accuracy
**Formula:**
```dart
accuracy = (matchCount / totalScans) * 100
```

**Interpretasi:**
- **> 95%**: Excellent
- **90-95%**: Good
- **85-90%**: Fair
- **< 85%**: Needs improvement

---

### 2. FAR (False Acceptance Rate)

**Estimasi dalam Kode:**
```dart
// Anggap score > 1.2 adalah impostor
final likelyImpostors = scores.where((s) => s > 1.2).length;

// Hitung yang diterima meskipun impostor
final falseAccepts = logs.where((log) {
  final score = log.matchScore ?? 1.0;
  return score >= 1.2 && score < threshold;
}).length;

final far = (falseAccepts / likelyImpostors) * 100;
```

**Catatan:**
- Ini adalah **estimasi** berdasarkan distribusi score
- Untuk FAR akurat, butuh **controlled testing** dengan impostor nyata
- Asumsi: Score > 1.2 = impostor

**Target FAR:**
- **High Security**: < 0.1%
- **Medium Security**: < 1%
- **Low Security**: < 5%

---

### 3. FRR (False Rejection Rate)

**Estimasi dalam Kode:**
```dart
// Anggap score < 0.8 adalah genuine user
final likelyGenuine = scores.where((s) => s < 0.8).length;

// Hitung yang ditolak meskipun genuine
final falseRejects = logs.where((log) {
  final score = log.matchScore ?? 1.0;
  return score < 0.8 && score >= threshold;
}).length;

final frr = (falseRejects / likelyGenuine) * 100;
```

**Target FRR:**
- **Excellent UX**: < 1%
- **Good UX**: < 5%
- **Acceptable**: < 10%

---

### 4. EER (Equal Error Rate)

**Formula:**
```dart
eer = (far + frr) / 2
```

**Interpretasi:**
- **< 1%**: State-of-the-art
- **1-3%**: Excellent
- **3-5%**: Good
- **5-10%**: Fair
- **> 10%**: Needs improvement

**Catatan:**
- EER yang rendah menunjukkan sistem yang balanced
- Ideal threshold adalah di titik FAR = FRR

---

## 🔍 Cara Menggunakan Analytics

### Step 1: Kumpulkan Data
```
1. Lakukan minimal 50-100 scan untuk data yang representatif
2. Pastikan ada variasi:
   - User yang berbeda
   - Kondisi pencahayaan berbeda
   - Posisi wajah berbeda
   - Waktu yang berbeda
```

### Step 2: Buka Analytics Dashboard
```
Home → Analytics
```

### Step 3: Analisis Metrik

#### A. Cek Summary
- Total scans cukup? (min 50)
- Success rate berapa? (target > 90%)

#### B. Cek Performance Metrics
- **Accuracy** tinggi? (target > 95%)
- **FAR** rendah? (target < 1%)
- **FRR** rendah? (target < 5%)
- **EER** rendah? (target < 3%)

#### C. Lihat Score Distribution
- Apakah ada pola yang jelas?
- Apakah ada outlier?
- Apakah distribusi normal?

#### D. Analisis Threshold
- Threshold saat ini di posisi mana?
- Apakah acceptance rate sesuai?
- Perlu adjustment?

### Step 4: Ikuti Recommendations
```
Sistem akan memberikan saran otomatis:
- Lower threshold jika FAR tinggi
- Raise threshold jika FRR tinggi
- Keep current jika optimal
```

### Step 5: Test & Iterate
```
1. Ubah threshold sesuai rekomendasi
2. Test lagi dengan scan baru
3. Cek apakah metrik membaik
4. Ulangi sampai optimal
```

---

## 🎓 Best Practices

### 1. Data Collection
- ✅ Minimal 100 scans untuk analisis yang valid
- ✅ Include berbagai kondisi (lighting, angle, expression)
- ✅ Test dengan user yang berbeda
- ✅ Simulate impostor attempts

### 2. Threshold Tuning
- ✅ Start dengan threshold default (1.0)
- ✅ Monitor FAR dan FRR
- ✅ Adjust gradually (±0.1 per iteration)
- ✅ Test setelah setiap adjustment

### 3. Monitoring
- ✅ Review analytics weekly
- ✅ Track trends over time
- ✅ Watch for degradation
- ✅ Re-tune jika perlu

### 4. Validation
- ✅ Controlled testing dengan impostor nyata
- ✅ Cross-validation dengan dataset berbeda
- ✅ A/B testing untuk threshold baru
- ✅ User feedback

---

## 🚨 Troubleshooting

### Problem 1: FAR Terlalu Tinggi
**Symptoms:**
- FAR > 10%
- Banyak impostor diterima

**Solutions:**
1. Lower threshold (0.8-0.9)
2. Improve liveness detection
3. Better enrollment photos
4. Re-train model

---

### Problem 2: FRR Terlalu Tinggi
**Symptoms:**
- FRR > 10%
- User asli sering ditolak

**Solutions:**
1. Raise threshold (1.1-1.2)
2. Better lighting saat scan
3. Multiple enrollment photos
4. User training (positioning)

---

### Problem 3: Low Accuracy
**Symptoms:**
- Accuracy < 85%
- Inconsistent results

**Solutions:**
1. Check data quality
2. Review enrollment process
3. Improve camera quality
4. Better preprocessing

---

### Problem 4: High EER
**Symptoms:**
- EER > 5%
- FAR dan FRR sama-sama tinggi

**Solutions:**
1. Review model quality
2. Check for data issues
3. Improve feature extraction
4. Consider model upgrade

---

## 📝 Limitations & Notes

### Current Limitations:

1. **FAR/FRR Estimation**
   - Menggunakan heuristic (score > 1.2 = impostor)
   - Tidak seakurat controlled testing
   - Butuh ground truth untuk akurasi tinggi

2. **Sample Size**
   - Butuh minimal 50-100 scans
   - Lebih banyak = lebih akurat
   - Small sample = unreliable metrics

3. **Simplified EER**
   - EER = (FAR + FRR) / 2
   - Bukan true EER dari ROC curve
   - Cukup untuk estimasi awal

### Future Improvements:

- [ ] ROC Curve visualization
- [ ] Precision-Recall curve
- [ ] Confusion matrix
- [ ] Time-series analysis
- [ ] Export to CSV/PDF
- [ ] Comparative analysis
- [ ] A/B testing framework

---

## 📚 References

### Academic Papers:
1. "Face Recognition: A Literature Survey" - Zhao et al.
2. "Deep Face Recognition" - Parkhi et al.
3. "FaceNet: A Unified Embedding" - Schroff et al.

### Industry Standards:
- NIST FRVT (Face Recognition Vendor Test)
- ISO/IEC 19795 (Biometric Performance Testing)

### Metrics Explanation:
- [Understanding FAR and FRR](https://www.biometricupdate.com)
- [ROC Curves Explained](https://developers.google.com/machine-learning/crash-course/classification/roc-and-auc)

---

**Last Updated**: 7 Desember 2024
**Version**: 1.0.0
