import whisper
import tempfile
import os

model = whisper.load_model('base')

def transcribe_audio(audio_file):
    temp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as temp:
            temp_path = temp.name
            audio_file.save(temp_path)
        result = model.transcribe(temp_path, fp16=False)
        return result['text']
    finally:
        if temp_path and os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except Exception:
                pass 