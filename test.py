import whisper

import os

if not os.path.exists("audio.mp3"):
    print("File audio tidak ditemukan.")
else:
    print("File ditemukan.")
    
model = whisper.load_model("base")
result = model.transcribe("audio.mp3")
print(result["text"])