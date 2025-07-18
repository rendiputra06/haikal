from flask import Flask, render_template
from db import init_db
from routes.api import api_bp
from routes.asr import asr_bp

app = Flask(__name__)
init_db()

app.register_blueprint(api_bp)
app.register_blueprint(asr_bp)

@app.route('/')
def index():
    menu = [
        {'name': 'Uji Basic Whisper', 'url': '/asr/basic'},
        {'name': 'Uji Lanjutan Whisper', 'url': '/asr/lanjutan'},
        {'name': 'Riwayat Latihan', 'url': '/asr/riwayat'}
    ]
    return render_template('index.html', menu=menu)

if __name__ == '__main__':
    app.run(debug=True) 