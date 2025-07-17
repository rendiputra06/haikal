# ASR Quran - Aplikasi Penguji Bacaan Al Quran dengan ASR (Whisper)

Aplikasi web untuk menguji dan memberikan umpan balik otomatis pada bacaan Al Quran menggunakan teknologi Automatic Speech Recognition (ASR) berbasis OpenAI Whisper. Cocok untuk latihan santri, guru, maupun pembelajaran mandiri.

## Fitur Utama

- Upload atau rekam audio bacaan Al Quran langsung dari browser
- Transkripsi otomatis bacaan menggunakan model Whisper lokal
- Perbandingan hasil transkripsi dengan ayat referensi (huruf Arab, tanpa/tanpa tanda baca)
- Highlight kesalahan bacaan (benar/salah/tambahan)
- Simpan hasil latihan, waktu, skor, dan detail perbandingan ke database
- Riwayat latihan santri (tabel, skor, detail)
- Mode basic (ayat terbatas, tanpa tanda baca) & lanjutan (seluruh surah, dengan tanda baca)

## Struktur Folder

```
haikal/
├── app.py                # Entry point Flask
├── routes/
│   └── asr.py            # Endpoint ASR, latihan, riwayat
├── services/
│   ├── whisper_service.py    # Fungsi transkripsi Whisper
│   └── compare_service.py    # Algoritma perbandingan teks
├── templates/
│   ├── index.html        # Menu utama
│   ├── asr_basic.html    # Halaman uji basic
│   ├── asr_lanjutan.html # Halaman uji lanjutan
│   ├── riwayat.html      # Riwayat latihan
│   └── layout.html       # Layout Bootstrap
├── data/
│   ├── ayat.json         # Database ayat basic (tanpa tanda baca)
│   ├── surah/            # Folder seluruh surah (JSON, Arab lengkap)
│   └── latihan.db        # Database SQLite hasil latihan
├── requirements.txt      # Daftar dependensi
└── README.md             # Dokumentasi ini
```

## Cara Instalasi

1. **Clone repo & masuk ke folder**
   ```bash
   git clone <repo-url>
   cd haikal
   ```
2. **Buat virtual environment (opsional tapi disarankan)**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   venv\Scripts\activate    # Windows
   ```
3. **Install dependensi**
   ```bash
   pip install -r requirements.txt
   ```
4. **Pastikan sudah download model Whisper (otomatis saat pertama run)**

## Cara Menjalankan

```bash
python app.py
```

Akses di browser: [http://localhost:5000](http://localhost:5000)

## Catatan Pengembangan

- Model Whisper berjalan lokal, pastikan resource cukup (RAM/CPU/GPU)
- Data latihan disimpan di `data/latihan.db` (SQLite, auto-create)
- Untuk menambah ayat di mode basic, edit `data/ayat.json` (huruf Arab tanpa tanda baca)
- Untuk mode lanjutan, data diambil dari seluruh file di `data/surah/`
- Tidak ada autentikasi/login, nama user diisi manual (opsional)

## TODO & Pengembangan Lanjutan

- Fitur latihan per surah/ayat
- Dashboard perkembangan santri/guru
- Export data latihan
- Filter riwayat per user
- Integrasi autentikasi user (opsional)

---

**Kontribusi & feedback sangat diharapkan!**

## Dokumentasi Endpoint API

Semua endpoint dapat diakses dari aplikasi web maupun mobile (CORS sudah aktif).

### 1. Uji Bacaan Basic

- **POST /asr/basic**
  - Form-data: audio (file), ayat_id (id ayat dari ayat.json), nama_user (opsional)
  - Response: Render HTML (bukan JSON, untuk API mobile perlu modifikasi)

### 2. Uji Bacaan Lanjutan

- **POST /asr/lanjutan**
  - Form-data: audio (file), ayat_id (format surah:ayat), nama_user (opsional)
  - Response: Render HTML (bukan JSON, untuk API mobile perlu modifikasi)

### 3. Riwayat Latihan

- **GET /asr/riwayat**
  - Response: Render HTML tabel riwayat latihan
  - (Untuk API mobile, bisa dibuat endpoint baru yang return JSON)

### 4. Data Surah & Ayat (Baru)

- **GET /asr/api/surah**
  - Response: JSON array daftar surah (id, nama_arab, nama_latin, jumlah_ayat)
- **GET /asr/api/ayat?surah_id=...**
  - Response: JSON array ayat untuk surah tertentu (id, nomor_ayat, teks_arab, teks_terjemah)

### Catatan

- Semua endpoint web saat ini return HTML, bukan JSON. Untuk integrasi mobile, disarankan membuat endpoint baru (misal: /api/asr, /api/riwayat) yang return JSON.
- CORS sudah aktif untuk seluruh backend (akses dari mobile/web lain diperbolehkan).
- **Data surah & ayat sekarang diambil dari database SQLite, bukan dari file JSON lagi.**

---

## Alur Pengujian Bacaan

1. User memilih surah terlebih dahulu
2. User memilih ayat dari surah yang dipilih
3. User upload atau rekam audio bacaan
4. Sistem menampilkan hasil transkripsi dan umpan balik otomatis

---

## Testing API

- Tersedia file `test_api.py` untuk menguji endpoint API utama (GET surah, GET ayat, POST upload audio). Jalankan dengan `python test_api.py` saat server aktif.

---

## Menjalankan Project dengan Ngrok (Akses dari Internet)

Agar aplikasi Flask bisa diakses dari luar (misal: untuk demo mobile, kolaborasi, dsb), gunakan [ngrok](https://ngrok.com/):

1. **Install ngrok**

   - Download dari https://ngrok.com/download
   - Ekstrak dan pastikan file `ngrok`/`ngrok.exe` bisa dijalankan dari terminal

2. **Jalankan server Flask**

   ```bash
   python app.py
   # (pastikan berjalan di http://localhost:5000)
   ```

3. **Expose port 5000 dengan ngrok**

   ```bash
   ngrok http 5000
   ```

   - Akan muncul URL publik seperti `https://xxxx.ngrok.io`
   - Akses aplikasi dari mana saja lewat URL tersebut

4. **Catatan**
   - Jika ingin akses dari device mobile di jaringan berbeda, gunakan URL ngrok
   - Untuk endpoint API, ganti `localhost:5000` dengan URL ngrok di aplikasi mobile/client

---
