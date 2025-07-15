from flask import Flask, render_template
from routes.asr import asr_bp

app = Flask(__name__)
app.register_blueprint(asr_bp)

@app.route('/')
def index():
    # Menu halaman utama
    menu = [
        {'name': 'Uji Basic Whisper', 'url': '/asr/basic'}
        # Tambahkan menu lain di sini nanti
    ]
    return render_template('index.html', menu=menu)

if __name__ == '__main__':
    app.run(debug=True) 