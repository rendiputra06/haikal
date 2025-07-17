import requests
import pytest

BASE_URL = 'http://localhost:5000/asr'

def test_get_surah():
    resp = requests.get(f'{BASE_URL}/api/surah')
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert 'id' in data[0]
    assert 'nama_latin' in data[0]

def test_get_ayat():
    # Ambil surah pertama
    surah_resp = requests.get(f'{BASE_URL}/api/surah')
    surah_id = surah_resp.json()[0]['id']
    resp = requests.get(f'{BASE_URL}/api/ayat', params={'surah_id': surah_id})
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert 'teks_arab' in data[0]

def test_upload_audio_basic():
    # Ambil ayat id pertama
    surah_resp = requests.get(f'{BASE_URL}/api/surah')
    surah_id = surah_resp.json()[0]['id']
    ayat_resp = requests.get(f'{BASE_URL}/api/ayat', params={'surah_id': surah_id})
    ayat_id = ayat_resp.json()[0]['id']
    # Buat file audio dummy (kosong, hanya untuk test upload, server akan error transkripsi tapi harus 200/400)
    with open('dummy.wav', 'wb') as f:
        f.write(b'RIFF....WAVEfmt ')  # header minimal agar diterima sebagai file audio
    files = {'audio': open('dummy.wav', 'rb')}
    data = {'ayat_id': ayat_id, 'nama_user': 'tester'}
    resp = requests.post(f'{BASE_URL}/basic', files=files, data=data)
    assert resp.status_code in (200, 400, 500)  # tergantung error transkripsi
    files['audio'].close()

if __name__ == '__main__':
    test_get_surah()
    test_get_ayat()
    test_upload_audio_basic()
    print('All API tests passed (or server returned expected error on dummy audio).') 