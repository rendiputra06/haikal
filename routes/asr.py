from flask import Blueprint, render_template, request, jsonify
from services.whisper_service import transcribe_audio
from services.compare_service import compare_texts
import json
import os
import glob

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

@asr_bp.route('/basic', methods=['GET', 'POST'])
def asr_basic():
    transcript = None
    error = None
    highlight = None
    ayat_id = request.form.get('ayat_id') if request.method == 'POST' else None
    if request.method == 'POST':
        if 'audio' not in request.files:
            error = 'Tidak ada file audio yang diupload.'
        elif not ayat_id:
            error = 'Silakan pilih ayat referensi.'
        else:
            audio_file = request.files['audio']
            try:
                transcript = transcribe_audio(audio_file)
                # Ambil referensi ayat
                ayat_ref = next((a for a in AYAT_LIST_BASIC if str(a['id']) == ayat_id or str(a['id']) == str(ayat_id)), None)
                if ayat_ref:
                    highlight = compare_texts(transcript, ayat_ref['teks'])
            except Exception as e:
                error = f'Gagal transkripsi: {str(e)}'
    return render_template('asr_basic.html', transcript=transcript, error=error, ayat_list=AYAT_LIST_BASIC, highlight=highlight, ayat_id=ayat_id)

@asr_bp.route('/lanjutan', methods=['GET', 'POST'])
def asr_lanjutan():
    transcript = None
    error = None
    highlight = None
    ayat_id = request.form.get('ayat_id') if request.method == 'POST' else None
    if request.method == 'POST':
        if 'audio' not in request.files:
            error = 'Tidak ada file audio yang diupload.'
        elif not ayat_id:
            error = 'Silakan pilih ayat referensi.'
        else:
            audio_file = request.files['audio']
            try:
                transcript = transcribe_audio(audio_file)
                # Ambil referensi ayat
                ayat_ref = next((a for a in AYAT_LIST_LANJUTAN if a['id'] == ayat_id), None)
                if ayat_ref:
                    highlight = compare_texts(transcript, ayat_ref['teks'])
            except Exception as e:
                error = f'Gagal transkripsi: {str(e)}'
    return render_template('asr_lanjutan.html', transcript=transcript, error=error, ayat_list=AYAT_LIST_LANJUTAN, highlight=highlight, ayat_id=ayat_id) 