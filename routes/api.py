from flask import Blueprint, request, jsonify
from db import get_db_connection, simpan_latihan
import json
from services.whisper_service import transcribe_audio
from services.compare_service import compare_texts
import os
import re

def remove_arabic_diacritics(text):
    return re.sub(r'[\u064B-\u0652\u0670\u06D6-\u06ED]', '', text)

api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/surah')
def api_surah():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT id, nama_arab, nama_latin, jumlah_ayat FROM surah ORDER BY id')
    surah_list = [
        {'id': row[0], 'nama_arab': row[1], 'nama_latin': row[2], 'jumlah_ayat': row[3]}
        for row in c.fetchall()
    ]
    conn.close()
    return jsonify(surah_list)

@api_bp.route('/ayat')
def api_ayat():
    surah_id = request.args.get('surah_id')
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT id, nomor_ayat, teks_arab, teks_terjemah FROM ayat WHERE surah_id = ? ORDER BY nomor_ayat', (surah_id,))
    ayat_list = [
        {'id': row[0], 'nomor_ayat': row[1], 'teks_arab': row[2], 'teks_terjemah': row[3]}
        for row in c.fetchall()
    ]
    conn.close()
    return jsonify(ayat_list)

@api_bp.route('/riwayat')
def api_riwayat():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT id, nama_user, waktu, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail FROM latihan ORDER BY waktu DESC')
    rows = c.fetchall()
    conn.close()
    riwayat_list = [
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
    return jsonify(riwayat_list)

@api_bp.route('/riwayat/<int:riwayat_id>')
def api_riwayat_detail(riwayat_id):
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT id, nama_user, waktu, surah, ayat, mode, hasil_transkripsi, referensi_ayat, skor, detail FROM latihan WHERE id = ?', (riwayat_id,))
    row = c.fetchone()
    if not row:
        conn.close()
        return jsonify({'error': 'Data riwayat tidak ditemukan'}), 404

    # Ambil data surah
    surah_latin = row[3]
    c.execute('SELECT id, nama_arab, nama_latin, jumlah_ayat FROM surah WHERE nama_latin = ?', (surah_latin,))
    surah_row = c.fetchone()
    surah_data = None
    if surah_row:
        surah_data = {
            'id': surah_row[0],
            'nama_arab': surah_row[1],
            'nama_latin': surah_row[2],
            'jumlah_ayat': surah_row[3]
        }

    # Ambil data ayat (jika surah ditemukan dan nomor ayat valid)
    ayat_data = None
    if surah_data:
        try:
            ayat_no = int(row[4])
            c.execute('SELECT id, nomor_ayat, teks_arab, teks_terjemah FROM ayat WHERE surah_id = ? AND nomor_ayat = ?', (surah_data['id'], ayat_no))
            ayat_row = c.fetchone()
            if ayat_row:
                ayat_data = {
                    'id': ayat_row[0],
                    'nomor_ayat': ayat_row[1],
                    'teks_arab': ayat_row[2],
                    'teks_terjemah': ayat_row[3]
                }
        except Exception:
            pass

    conn.close()
    riwayat_detail = {
        'id': row[0],
        'nama_user': row[1],
        'waktu': row[2],
        'surah': row[3],
        'ayat': row[4],
        'mode': row[5],
        'hasil_transkripsi': row[6],
        'referensi_ayat': row[7],
        'skor': row[8],
        'detail': json.loads(row[9]) if row[9] else [],
        'surah_data': surah_data,
        'ayat_data': ayat_data
    }
    return jsonify(riwayat_detail)

@api_bp.route('/asr/upload', methods=['POST'])
def api_asr_upload():
    if 'audio' not in request.files:
        return jsonify({'error': 'File audio tidak ditemukan'}), 400
    ayat_id = request.form.get('ayat_id')
    nama_user = request.form.get('nama_user', 'anonim')
    if not ayat_id:
        return jsonify({'error': 'ayat_id wajib diisi'}), 400
    audio_file = request.files['audio']

    # Ambil data ayat referensi dari DB
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT s.id, s.nama_arab, s.nama_latin, a.id, a.nomor_ayat, a.teks_arab FROM surah s JOIN ayat a ON s.id = a.surah_id WHERE a.id = ?', (ayat_id,))
    row = c.fetchone()
    conn.close()
    if not row:
        return jsonify({'error': 'Ayat referensi tidak ditemukan'}), 404
    ayat_ref = {
        'surah_id': row[0],
        'surah': row[1],
        'surah_latin': row[2],
        'id': row[3],
        'ayat': row[4],
        'teks': row[5]
    }
    try:
        transcript = transcribe_audio(audio_file)
        ayat_ref_clean = remove_arabic_diacritics(ayat_ref['teks'])
        highlight = compare_texts(transcript, ayat_ref_clean)
        skor = sum(1 for item in highlight if item['status'] == 'benar') if highlight else 0
        simpan_latihan(
            nama_user=nama_user,
            surah=ayat_ref['surah_latin'],
            ayat=str(ayat_ref['ayat']),
            mode='api',
            hasil_transkripsi=transcript,
            referensi_ayat=ayat_ref_clean,
            skor=skor,
            detail=json.dumps(highlight, ensure_ascii=False)
        )
        return jsonify({
            'transcript': transcript,
            'skor': skor,
            'highlight': highlight,
            'ayat_referensi': ayat_ref_clean,
            'ayat_data': ayat_ref
        })
    except Exception as e:
        return jsonify({'error': f'Gagal transkripsi: {str(e)}'}), 500 