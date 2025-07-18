# Dokumentasi API ASR Quran

Dokumen ini menjelaskan endpoint API yang tersedia pada project ASR Quran.

---

## 1. GET /api/surah

Mengambil daftar surah dari database.

- **Endpoint:** `/api/surah`
- **Method:** GET
- **Response:**

```json
[
  {
    "id": 1,
    "nama_arab": "الفاتحة",
    "nama_latin": "Al-Fatihah",
    "jumlah_ayat": 7
  },
  ...
]
```

### Contoh Request

```
curl http://localhost:5000/api/surah
```

---

## 2. GET /api/ayat?surah_id=<id>

Mengambil daftar ayat dari surah tertentu.

- **Endpoint:** `/api/ayat?surah_id=<id>`
- **Method:** GET
- **Parameter:**
  - `surah_id` (wajib): ID surah yang ingin diambil ayatnya
- **Response:**

```json
[
  {
    "id": 1,
    "nomor_ayat": 1,
    "teks_arab": "بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ",
    "teks_terjemah": "Dengan nama Allah Yang Maha Pengasih, Maha Penyayang."
  },
  ...
]
```

### Contoh Request

```
curl "http://localhost:5000/api/ayat?surah_id=1"
```

---

## 3. GET /api/riwayat

Mengambil seluruh data riwayat latihan dari database.

- **Endpoint:** `/api/riwayat`
- **Method:** GET
- **Response:**

```json
[
  {
    "id": 1,
    "nama_user": "user1",
    "waktu": "2024-06-01 10:00:00",
    "surah": "Al-Fatihah",
    "ayat": "1",
    "mode": "basic",
    "hasil_transkripsi": "bismillah ...",
    "referensi_ayat": "بسم الله الرحمن الرحيم",
    "skor": 5,
    "detail": [
      {"kata": "بسم", "status": "benar"},
      {"kata": "الله", "status": "benar"},
      ...
    ]
  },
  ...
]
```

### Contoh Request

```
curl http://localhost:5000/api/riwayat
```

---

## 4. GET /api/riwayat/<id>

Mengambil detail riwayat latihan berdasarkan id. Response juga menyertakan data surah dan ayat yang lebih lengkap.

- **Endpoint:** `/api/riwayat/<id>`
- **Method:** GET
- **Parameter:**
  - `id` (wajib): ID riwayat latihan
- **Response:**

```json
{
  "id": 1,
  "nama_user": "user1",
  "waktu": "2024-06-01 10:00:00",
  "surah": "Al-Fatihah",
  "ayat": "1",
  "mode": "basic",
  "hasil_transkripsi": "bismillah ...",
  "referensi_ayat": "بسم الله الرحمن الرحيم",
  "skor": 5,
  "detail": [
    {"kata": "بسم", "status": "benar"},
    {"kata": "الله", "status": "benar"},
    ...
  ],
  "surah_data": {
    "id": 1,
    "nama_arab": "الفاتحة",
    "nama_latin": "Al-Fatihah",
    "jumlah_ayat": 7
  },
  "ayat_data": {
    "id": 1,
    "nomor_ayat": 1,
    "teks_arab": "بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ",
    "teks_terjemah": "Dengan nama Allah Yang Maha Pengasih, Maha Penyayang."
  }
}
```

### Contoh Request

```
curl http://localhost:5000/api/riwayat/1
```

Jika data tidak ditemukan:

```json
{ "error": "Data riwayat tidak ditemukan" }
```

---

## 5. POST /api/asr/upload

Upload audio bacaan untuk proses ASR dan penilaian otomatis.

- **Endpoint:** `/api/asr/upload`
- **Method:** POST
- **Content-Type:** multipart/form-data
- **Parameter:**
  - `audio` (file, wajib): File audio bacaan (format .wav/.mp3, dsb)
  - `ayat_id` (wajib): ID ayat referensi
  - `nama_user` (opsional): Nama user
- **Response:**

```json
{
  "transcript": "bismillah ...",
  "skor": 5,
  "highlight": [
    {"kata": "بسم", "status": "benar"},
    {"kata": "الله", "status": "benar"},
    ...
  ],
  "ayat_referensi": "بسم الله الرحمن الرحيم",
  "ayat_data": {
    "surah_id": 1,
    "surah": "الفاتحة",
    "surah_latin": "Al-Fatihah",
    "id": 1,
    "ayat": 1,
    "teks": "بسم الله الرحمن الرحيم"
  }
}
```

### Contoh Request (curl)

```
curl -X POST -F "audio=@/path/to/audio.wav" -F "ayat_id=1" -F "nama_user=nama" http://localhost:5000/api/asr/upload
```

Jika terjadi error:

```json
{ "error": "File audio tidak ditemukan" }
```

---

## Catatan Penting

- Endpoint API hanya untuk mengambil data surah dan ayat, serta upload audio untuk penilaian otomatis.
- Untuk fitur ASR (upload audio, perbandingan bacaan via web), gunakan halaman web yang sudah disediakan.
- Semua response API dalam format JSON.
- Untuk integrasi mobile/web lain, pastikan CORS diaktifkan jika akses lintas domain.

---

## Testing

- Tersedia file `test_api.py` untuk menguji endpoint API utama.
- Jalankan dengan `python test_api.py` saat server aktif.
