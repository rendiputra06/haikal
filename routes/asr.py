from flask import Blueprint, render_template, request, jsonify
from services.whisper_service import transcribe_audio

asr_bp = Blueprint('asr', __name__, url_prefix='/asr')

@asr_bp.route('/basic', methods=['GET', 'POST'])
def asr_basic():
    transcript = None
    error = None
    if request.method == 'POST':
        if 'audio' not in request.files:
            error = 'Tidak ada file audio yang diupload.'
        else:
            audio_file = request.files['audio']
            try:
                transcript = transcribe_audio(audio_file)
            except Exception as e:
                error = f'Gagal transkripsi: {str(e)}'
    return render_template('asr_basic.html', transcript=transcript, error=error) 