from flask import Blueprint, render_template, request, jsonify
from services.whisper_service import transcribe_audio
from services.compare_service import compare_texts
import json
import os
import glob
from db import simpan_latihan, init_db, get_db_connection
from datetime import datetime
import re

asr_bp = Blueprint('asr', __name__, url_prefix='/asr')

# Fungsi untuk menghapus tanda baca (harakat) pada teks Arab
def remove_arabic_diacritics(text):
    return re.sub(r'[\u064B-\u0652\u0670\u06D6-\u06ED]', '', text)

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

# DB_PATH, init_db, simpan_latihan sudah di db.py

def get_ayat_list_from_db():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT s.id, s.nama_arab, s.nama_latin, a.id, a.nomor_ayat, a.teks_arab FROM surah s JOIN ayat a ON s.id = a.surah_id ORDER BY s.id, a.nomor_ayat')
    ayat_list = [
        {'surah_id': row[0], 'surah': row[1], 'surah_latin': row[2], 'id': row[3], 'ayat': row[4], 'teks': row[5]}
        for row in c.fetchall()
    ]
    conn.close()
    return ayat_list

@asr_bp.route('/basic', methods=['GET', 'POST'])
def asr_basic():
    ayat_list = get_ayat_list_from_db()
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
                    ayat_ref_clean = remove_arabic_diacritics(ayat_ref['teks'])
                    highlight = compare_texts(transcript, ayat_ref_clean)
                    skor = sum(1 for item in highlight if item['status'] == 'benar') if highlight else 0
                    simpan_latihan(
                        nama_user=nama_user,
                        surah=ayat_ref['surah_latin'],
                        ayat=str(ayat_ref['ayat']),
                        mode='basic',
                        hasil_transkripsi=transcript,
                        referensi_ayat=ayat_ref_clean,
                        skor=skor,
                        detail=json.dumps(highlight, ensure_ascii=False)
                    )
            except Exception as e:
                error = f'Gagal transkripsi: {str(e)}'
    return render_template('asr_basic.html', transcript=transcript, error=error, ayat_list=ayat_list, highlight=highlight, ayat_id=ayat_id, nama_user=nama_user)

@asr_bp.route('/lanjutan', methods=['GET', 'POST'])
def asr_lanjutan():
    ayat_list = get_ayat_list_from_db()
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
                    ayat_ref_clean = remove_arabic_diacritics(ayat_ref['teks'])
                    highlight = compare_texts(transcript, ayat_ref_clean)
                    skor = sum(1 for item in highlight if item['status'] == 'benar') if highlight else 0
                    simpan_latihan(
                        nama_user=nama_user,
                        surah=ayat_ref['surah_latin'],
                        ayat=str(ayat_ref['ayat']),
                        mode='lanjutan',
                        hasil_transkripsi=transcript,
                        referensi_ayat=ayat_ref_clean,
                        skor=skor,
                        detail=json.dumps(highlight, ensure_ascii=False)
                    )
            except Exception as e:
                error = f'Gagal transkripsi: {str(e)}'
    return render_template('asr_lanjutan.html', transcript=transcript, error=error, ayat_list=ayat_list, highlight=highlight, ayat_id=ayat_id, nama_user=nama_user)

@asr_bp.route('/riwayat')
def riwayat():
    conn = get_db_connection()
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