# Project Brief: Aplikasi Presensi Face Recognition (Prototype)

## 1. Informasi Proyek
*   **Nama Proyek**: FaceAttendance (Prototype)
*   **Platform**: Mobile (Flutter)
*   **Backend**: Supabase
*   **Deskripsi**: Prototipe aplikasi presensi sederhana tanpa login, fokus pada pendaftaran wajah, verifikasi presensi, dan eksperimen akurasi.

## 2. Tujuan Prototipe
*   Mendemonstrasikan kemampuan aplikasi mencatat dan mengenali wajah pengguna.
*   Melakukan presensi *seamless* menggunakan pengenalan wajah.
*   **Eksperimen Akurasi**: Memberikan kontrol kepada pengguna untuk mengatur sensitivitas pengenalan wajah.

## 3. Fitur Utama
1.  **Registrasi User (Sederhana)**:
    *   Input **Nama**.
    *   Scan wajah -> Simpan Nama & *Embedding* ke database.
2.  **Presensi (Check-in)**:
    *   Deteksi wajah secara real-time.
    *   Menampilkan **Skor Kemiripan (Distance)** secara langsung di layar saat memindai.
    *   Jika `Distance < Threshold`, anggap cocok.
3.  **Pengaturan & Debug (Fitur Baru)**:
    *   **Slider Threshold**: Mengatur batas toleransi kemiripan (misal: 0.5 - 1.5). Semakin kecil nilainya, semakin ketat/akurat (tapi mungkin sulit mengenali). Semakin besar, semakin mudah mengenali (tapi risiko salah orang).
    *   **View Logs**: Melihat detail angka teknis dari setiap percobaan presensi.
4.  **Riwayat Presensi**:
    *   List sederhana menampilkan siapa saja yang berhasil absen.

## 4. Arsitektur Teknis

### A. Tech Stack
*   **Frontend**: Flutter
*   **Backend**: Supabase (Database Only)
*   **Local Storage**: `shared_preferences` (Untuk menyimpan setting threshold user).
*   **Face Recognition**:
    *   **Deteksi**: `google_mlkit_face_detection`
    *   **Pengenalan**: Model MobileFaceNet (TFLite).

### B. Desain Database (Supabase)

#### Tabel: `users`
*   `id` (uuid, PK)
*   `name` (text)
*   `face_embedding` (vector/json)
*   `created_at` (timestamp)

#### Tabel: `attendance_logs`
*   `id` (uuid, PK)
*   `user_id` (uuid, FK users.id)
*   `scan_time` (timestamp)
*   `match_score` (float) - Menyimpan nilai distance saat absen berhasil untuk analisis.

## 5. Flow Aplikasi
1.  **Home**: Menu "Daftar", "Absen", "Setting".
2.  **Setting**: User menggeser slider "Threshold" (Default: misal 1.0).
3.  **Absen**: 
    *   Kamera terbuka.
    *   Overlay menampilkan teks: "Jarak Wajah: 0.85" (Berubah real-time).
    *   Jika 0.85 < Threshold (1.0) -> SUKSES "Halo Budi!".

## 6. Roadmap Pengembangan
1.  **Setup**: Project & Dependencies (termasuk `shared_preferences`).
2.  **Core AI**: Implementasi TFLite & Logika Jarak (Euclidean Distance).
3.  **UI Settings**: Halaman untuk ubah variabel threshold.
4.  **Integration**: Gabungkan logika AI dengan nilai threshold dinamis dari setting.
