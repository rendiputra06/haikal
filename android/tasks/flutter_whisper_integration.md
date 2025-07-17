# Task List Integrasi Flutter Android dengan Backend ASR Whisper

## 1. Persiapan & Analisis

- [x] Review endpoint API pada backend Flask (ASR, riwayat, data ayat/surah)
- [x] Pastikan backend sudah mengaktifkan CORS untuk akses dari mobile
- [x] Dokumentasikan endpoint yang akan digunakan
- [ ] Modifikasi endpoint /asr/basic dan /asr/lanjutan agar bisa return JSON (bukan HTML) untuk kebutuhan aplikasi mobile
- [ ] Tambahkan endpoint baru /asr/riwayat_json yang mengembalikan data riwayat latihan dalam format JSON

## 2. Setup Project Flutter

- [ ] Pastikan project Flutter berjalan di Android device/emulator
- [x] Tambahkan package http, audio recorder, dan file picker (jika perlu)
- [x] Buat struktur folder Flutter sesuai best practice (models, services, screens, widgets, utils, constants)

## 3. Fitur Latihan Mandiri (Uji Bacaan)

- [ ] Implementasi fitur rekam audio di Flutter
- [ ] Simpan file audio dalam format yang didukung backend (.wav/.mp3)
- [ ] Implementasi upload audio ke endpoint /asr/basic dan /asr/lanjutan via HTTP Multipart
- [ ] Tampilkan notifikasi/progress saat upload audio
- [ ] Implementasi pemilihan mode latihan (basic/lanjutan)
- [ ] Implementasi pemilihan ayat/surah (fetch dari /data/ayat.json dan /data/surah/{nomor}.json)
- [ ] Kirim parameter ayat_id dan nama_user saat upload audio

> Catatan: Struktur dasar fitur latihan mandiri (rekam audio, pemilihan mode, ayat, nama user, upload dummy) sudah diimplementasikan di latihan_screen.dart

## 4. Koreksi & Umpan Balik Otomatis

- [ ] Parse response JSON dari backend (transkripsi, skor, highlight, dsb)
- [ ] Tampilkan hasil transkripsi di UI Flutter
- [ ] Implementasi highlight kesalahan bacaan (benar/salah/tambahan) di UI
- [ ] Tampilkan skor/penilaian dan umpan balik

## 5. Fitur Riwayat Latihan & Statistik

- [ ] Implementasi halaman riwayat latihan di Flutter
- [ ] Fetch data riwayat dari endpoint /asr/riwayat_json
- [ ] Tampilkan tabel/list skor, waktu, detail latihan
- [ ] Implementasi halaman statistik perkembangan hafalan (grafik, rangkuman per surah/ayat)

## 6. Pengalaman Pengguna & Pengaturan

- [ ] Implementasi halaman Home, Splash/Welcome, dan Navigasi utama
- [ ] Implementasi halaman Profile/User (opsional, jika ingin autentikasi)
- [ ] Implementasi halaman Pengaturan (mode, bahasa, info aplikasi)
- [ ] Tampilkan loading/progress dan error handling di seluruh fitur

## 7. Pengujian & Error Handling

- [ ] Uji upload audio dari Android ke backend (gunakan IP LAN)
- [ ] Implementasi error handling untuk upload/response gagal
- [ ] Tampilkan pesan error yang informatif di aplikasi

## 8. Dokumentasi & Finalisasi

- [ ] Dokumentasikan cara setup & penggunaan fitur baru
- [ ] Review dan refactor kode jika diperlukan
- [ ] Siapkan catatan pengujian dan feedback

---

**Catatan:**

- Untuk produksi, pertimbangkan penambahan autentikasi dan penggunaan HTTPS.
- Task dapat dipecah lebih detail sesuai kebutuhan tim.
- Endpoint backend perlu dimodifikasi agar respons JSON, bukan HTML, untuk integrasi mobile.
