import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'data/latihan.db')

def get_db_connection():
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS latihan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_user TEXT,
        waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        surah TEXT,
        ayat TEXT,
        mode TEXT,
        hasil_transkripsi TEXT,
        referensi_ayat TEXT,
        skor INTEGER,
        detail TEXT
    )''')
    conn.commit()
    conn.close()

def simpan_latihan(nama_user, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail):
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('''INSERT INTO latihan (nama_user, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
              (nama_user, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail))
    conn.commit()
    conn.close() 