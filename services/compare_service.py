import difflib
import os
import glob
import json
import sqlite3

DB_PATH = os.path.join(os.path.dirname(__file__), '../data/latihan.db')
SURAH_DIR = os.path.join(os.path.dirname(__file__), '../data/surah')

def compare_texts(transkrip, referensi):
    # Split per kata
    trans_words = transkrip.strip().split()
    ref_words = referensi.strip().split()
    matcher = difflib.SequenceMatcher(None, ref_words, trans_words)
    result = []
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == 'equal':
            result.extend([{'word': w, 'status': 'benar'} for w in ref_words[i1:i2]])
        elif tag == 'replace' or tag == 'delete':
            result.extend([{'word': w, 'status': 'salah'} for w in ref_words[i1:i2]])
        elif tag == 'insert':
            # Kata tambahan di transkrip
            result.extend([{'word': w, 'status': 'tambahan'} for w in trans_words[j1:j2]])
    return result

def migrate_surah_ayat_to_sqlite():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    # Buat tabel surah
    c.execute('''CREATE TABLE IF NOT EXISTS surah (
        id INTEGER PRIMARY KEY,
        nama_arab TEXT,
        nama_latin TEXT,
        jumlah_ayat INTEGER
    )''')
    # Buat tabel ayat
    c.execute('''CREATE TABLE IF NOT EXISTS ayat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER,
        nomor_ayat INTEGER,
        teks_arab TEXT,
        teks_terjemah TEXT,
        FOREIGN KEY(surah_id) REFERENCES surah(id)
    )''')
    conn.commit()
    # Hapus data lama
    c.execute('DELETE FROM surah')
    c.execute('DELETE FROM ayat')
    conn.commit()
    # Proses semua file surah
    for surah_file in glob.glob(os.path.join(SURAH_DIR, '*.json')):
        with open(surah_file, encoding='utf-8') as f:
            surah_data = json.load(f)
            for surah_num, surah in surah_data.items():
                surah_id = int(surah_num)
                nama_arab = surah.get('name', '')
                nama_latin = surah.get('name_latin', '')
                jumlah_ayat = int(surah.get('number_of_ayah', 0))
                c.execute('INSERT INTO surah (id, nama_arab, nama_latin, jumlah_ayat) VALUES (?, ?, ?, ?)',
                          (surah_id, nama_arab, nama_latin, jumlah_ayat))
                ayat_texts = surah.get('text', {})
                terjemah = surah.get('translations', {}).get('id', {}).get('text', {})
                for ayat_no, ayat_arab in ayat_texts.items():
                    teks_terjemah = terjemah.get(ayat_no, '')
                    c.execute('INSERT INTO ayat (surah_id, nomor_ayat, teks_arab, teks_terjemah) VALUES (?, ?, ?, ?)',
                              (surah_id, int(ayat_no), ayat_arab, teks_terjemah))
    conn.commit()
    conn.close()

# Untuk menjalankan migrasi secara manual:
if __name__ == '__main__':
    migrate_surah_ayat_to_sqlite()
    print('Migrasi data surah & ayat ke SQLite selesai.') 