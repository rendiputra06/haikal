from flask import Blueprint, render_template, request, jsonify
from services.whisper_service import transcribe_audio
from services.compare_service import compare_texts
import json
import os
import glob
import sqlite3
from datetime import datetime

asr_bp = Blueprint('asr', __name__, url_prefix='/asr')

# Load ayat referensi dari semua file surah di folder data/surah/ (untuk halaman lanjutan)
SURAH_DIR = os.path.join(os.path.dirname(__file__), '../data/surah')
AYAT_LIST_LANJUTAN = []
for surah_file in glob.glob(os.path.join(SURAH_DIR, '*.json')):
    with open(surah_file, encoding='utf-8') as f:
        surah_data = json.load(f)
        for surah_num, surah in surah_data.items():
            surah_name = surah.get('name', '')
            surah_name_latin = surah.get('name_latin', '')
            ayat_texts = surah.get('text', {})
            for ayat_no, ayat_arab in ayat_texts.items():
                AYAT_LIST_LANJUTAN.append({
                    'id': f"{surah_num}:{ayat_no}",
                    'surah': surah_name,
                    'surah_latin': surah_name_latin,
                    'ayat': ayat_no,
                    'teks': ayat_arab
                })

# Load ayat referensi dari data/ayat.json (untuk halaman basic)
AYAT_PATH = os.path.join(os.path.dirname(__file__), '../data/ayat.json')
with open(AYAT_PATH, encoding='utf-8') as f:
    AYAT_LIST_BASIC = json.load(f)

DB_PATH = os.path.join(os.path.dirname(__file__), '../data/latihan.db')

def init_db():
    conn = sqlite3.connect(DB_PATH)
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

init_db()

def simpan_latihan(nama_user, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('''INSERT INTO latihan (nama_user, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
              (nama_user, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail))
    conn.commit()
    conn.close()

@asr_bp.route('/api/surah')
def api_surah():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT id, nama_arab, nama_latin, jumlah_ayat FROM surah ORDER BY id')
    surah_list = [
        {'id': row[0], 'nama_arab': row[1], 'nama_latin': row[2], 'jumlah_ayat': row[3]}
        for row in c.fetchall()
    ]
    conn.close()
    return jsonify(surah_list)

@asr_bp.route('/api/ayat')
def api_ayat():
    surah_id = request.args.get('surah_id')
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT id, nomor_ayat, teks_arab, teks_terjemah FROM ayat WHERE surah_id = ? ORDER BY nomor_ayat', (surah_id,))
    ayat_list = [
        {'id': row[0], 'nomor_ayat': row[1], 'teks_arab': row[2], 'teks_terjemah': row[3]}
        for row in c.fetchall()
    ]
    conn.close()
    return jsonify(ayat_list)

# Untuk halaman asr_basic dan asr_lanjutan, ambil data surah/ayat dari database
@asr_bp.route('/basic', methods=['GET', 'POST'])
def asr_basic():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT s.id, s.nama_arab, s.nama_latin, a.id, a.nomor_ayat, a.teks_arab FROM surah s JOIN ayat a ON s.id = a.surah_id ORDER BY s.id, a.nomor_ayat')
    ayat_list = [
        {'surah_id': row[0], 'surah': row[1], 'surah_latin': row[2], 'id': row[3], 'ayat': row[4], 'teks': row[5]}
        for row in c.fetchall()
    ]
    conn.close()
    transcript = None
    error = None
    highlight = None
    ayat_id = request.form.get('ayat_id') if request.method == 'POST' else None
    nama_user = request.form.get('nama_user', 'anonim') if request.method == 'POST' else ''
    if request.method == 'POST':
        if 'audio' not in request.files:
            error = 'Tidak ada file audio yang diupload.'
        elif not ayat_id:
            error = 'Silakan pilih ayat referensi.'
        else:
            audio_file = request.files['audio']
            try:
                transcript = transcribe_audio(audio_file)
                ayat_ref = next((a for a in ayat_list if str(a['id']) == ayat_id or str(a['id']) == str(ayat_id)), None)
                if ayat_ref:
                    highlight = compare_texts(transcript, ayat_ref['teks'])
                    skor = sum(1 for item in highlight if item['status'] == 'benar') if highlight else 0
                    simpan_latihan(
                        nama_user=nama_user,
                        surah=ayat_ref['surah_latin'],
                        ayat=str(ayat_ref['ayat']),
                        mode='basic',
                        hasil_transkripsi=transcript,
                        referensi_ayat=ayat_ref['teks'],
                        skor=skor,
                        detail=json.dumps(highlight, ensure_ascii=False)
                    )
            except Exception as e:
                error = f'Gagal transkripsi: {str(e)}'
    return render_template('asr_basic.html', transcript=transcript, error=error, ayat_list=ayat_list, highlight=highlight, ayat_id=ayat_id, nama_user=nama_user)

@asr_bp.route('/lanjutan', methods=['GET', 'POST'])
def asr_lanjutan():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT s.id, s.nama_arab, s.nama_latin, a.id, a.nomor_ayat, a.teks_arab FROM surah s JOIN ayat a ON s.id = a.surah_id ORDER BY s.id, a.nomor_ayat')
    ayat_list = [
        {'surah_id': row[0], 'surah': row[1], 'surah_latin': row[2], 'id': row[3], 'ayat': row[4], 'teks': row[5]}
        for row in c.fetchall()
    ]
    conn.close()
    transcript = None
    error = None
    highlight = None
    ayat_id = request.form.get('ayat_id') if request.method == 'POST' else None
    nama_user = request.form.get('nama_user', 'anonim') if request.method == 'POST' else ''
    if request.method == 'POST':
        if 'audio' not in request.files:
            error = 'Tidak ada file audio yang diupload.'
        elif not ayat_id:
            error = 'Silakan pilih ayat referensi.'
        else:
            audio_file = request.files['audio']
            try:
                transcript = transcribe_audio(audio_file)
                ayat_ref = next((a for a in ayat_list if str(a['id']) == ayat_id or str(a['id']) == str(ayat_id)), None)
                if ayat_ref:
                    highlight = compare_texts(transcript, ayat_ref['teks'])
                    skor = sum(1 for item in highlight if item['status'] == 'benar') if highlight else 0
                    simpan_latihan(
                        nama_user=nama_user,
                        surah=ayat_ref['surah_latin'],
                        ayat=str(ayat_ref['ayat']),
                        mode='lanjutan',
                        hasil_transkripsi=transcript,
                        referensi_ayat=ayat_ref['teks'],
                        skor=skor,
                        detail=json.dumps(highlight, ensure_ascii=False)
                    )
            except Exception as e:
                error = f'Gagal transkripsi: {str(e)}'
    return render_template('asr_lanjutan.html', transcript=transcript, error=error, ayat_list=ayat_list, highlight=highlight, ayat_id=ayat_id, nama_user=nama_user)

@asr_bp.route('/riwayat')
def riwayat():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT id, nama_user, waktu, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail FROM latihan ORDER BY waktu DESC')
    rows = c.fetchall()
    conn.close()
    latihan_list = [
        {
            'id': row[0],
            'nama_user': row[1],
            'waktu': row[2],
            'surah': row[3],
            'ayat': row[4],
            'mode': row[5],
            'hasil_transkripsi': row[6],
            'referensi_ayat': row[7],
            'skor': row[8],
            'detail': json.loads(row[9]) if row[9] else []
        }
        for row in rows
    ]
    return render_template('riwayat.html', latihan_list=latihan_list) 