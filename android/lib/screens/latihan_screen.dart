import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import 'pilih_surah_screen.dart';
import 'pilih_ayat_screen.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:html/parser.dart' as html_parser;
import '../services/latihan_service.dart';
import '../constants/app_constants.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class LatihanScreen extends StatefulWidget {
  const LatihanScreen({Key? key}) : super(key: key);

  @override
  State<LatihanScreen> createState() => _LatihanScreenState();
}

class _LatihanScreenState extends State<LatihanScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _selectedSurah;
  Map<String, dynamic>? _selectedAyat;
  String _namaUser = '';
  bool _isRecording = false;
  bool _isUploading = false;
  bool _hasRecorded = false;
  bool? _uploadSuccess;
  String? _audioPath;
  late AnimationController _animController;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  String? _koreksiResult;
  String? _pickedFileName;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (!kIsWeb) {
      _recorder.openRecorder();
      _player.openPlayer();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    if (!kIsWeb) {
      _recorder.closeRecorder();
      _player.closePlayer();
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (kIsWeb) return;
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Izin mikrofon diperlukan')));
      return;
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/latihan_audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
    setState(() {
      _isRecording = true;
      _uploadSuccess = null;
      _audioPath = path;
      _hasRecorded = false;
      _pickedFileName = null;
    });
  }

  Future<void> _stopRecording() async {
    if (kIsWeb) return;
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rekaman selesai!')));
  }

  Future<void> _playAudio() async {
    if (kIsWeb || _audioPath == null) return;
    setState(() => _isPlaying = true);
    await _player.startPlayer(
      fromURI: _audioPath,
      codec: Codec.aacADTS,
      whenFinished: () => setState(() => _isPlaying = false),
    );
  }

  Future<void> _stopAudio() async {
    if (kIsWeb) return;
    await _player.stopPlayer();
    setState(() => _isPlaying = false);
  }

  void _reset() {
    setState(() {
      _audioPath = null;
      _hasRecorded = false;
      _uploadSuccess = null;
      _koreksiResult = null;
      _pickedFileName = null;
    });
  }

  Future<void> _uploadAudio() async {
    if (_audioPath == null || _selectedSurah == null || _selectedAyat == null)
      return;
    setState(() {
      _isUploading = true;
      _uploadSuccess = null;
      _koreksiResult = null;
    });
    _animController.repeat(reverse: true);
    try {
      final result = await LatihanService.uploadAudio(
        audioPath: _audioPath!,
        ayatId: _selectedAyat!['id'].toString(),
        namaUser: _namaUser,
      );
      setState(() {
        _isUploading = false;
        _uploadSuccess = result['error'] == null;
        _hasRecorded = false;
        _koreksiResult = null;
      });
      _animController.stop();
      if (_uploadSuccess == true) {
        // Tampilkan hasil koreksi dengan format baru
        showDialog(
          context: context,
          builder: (context) {
            final ayatData = result['ayat_data'] ?? {};
            final highlight = (result['highlight'] as List?) ?? [];
            return AlertDialog(
              title: const Text('Hasil Koreksi'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transkripsi:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(result['transcript'] ?? '-'),
                    const SizedBox(height: 12),
                    Text('Skor: ${result['skor'] ?? '-'}'),
                    const SizedBox(height: 12),
                    Text(
                      'Ayat Referensi:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(result['ayat_referensi'] ?? '-'),
                    const SizedBox(height: 12),
                    if (ayatData.isNotEmpty) ...[
                      Text(
                        'Surah: ${ayatData['surah_latin'] ?? '-'} (${ayatData['surah'] ?? '-'})',
                      ),
                      Text('Ayat: ${ayatData['ayat'] ?? '-'}'),
                      Text('Teks: ${ayatData['teks'] ?? '-'}'),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'Highlight:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    highlight.isEmpty
                        ? const Text('-')
                        : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          textDirection: TextDirection.rtl,
                          children:
                              highlight.map<Widget>((d) {
                                final kata = d['kata']?.toString() ?? '-';
                                final status = d['status']?.toString() ?? '-';
                                final isBenar = status == 'benar';
                                return Chip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        kata,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        isBenar
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            isBenar ? Colors.green : Colors.red,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  backgroundColor:
                                      isBenar
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color:
                                          isBenar ? Colors.green : Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload gagal! ${result['error'] ?? ''}')),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadSuccess = false;
        _koreksiResult = null;
      });
      _animController.stop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload gagal!')));
    }
  }

  String? _parseKoreksiHtml(String html) {
    try {
      final doc = html_parser.parse(html);
      final body = doc.body;
      if (body != null && body.text != null) {
        return body.text!.trim();
      }
      return doc.text?.trim();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return MainLayout(
        title: 'Latihan Mandiri Al-Qur’an',
        child: const Center(
          child: Text(
            'Fitur rekam dan upload audio hanya tersedia di Android/iOS.',
          ),
        ),
      );
    }
    return MainLayout(
      title: 'Latihan Mandiri Al-Qur’an',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Langkah-langkah
            // (Bagian ini dihapus, dipindahkan ke HomeScreen)
            // Info surah & ayat terpilih
            if (_selectedSurah != null && _selectedAyat != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.green.shade50,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${_selectedSurah!['nama_latin']} (${_selectedSurah!['nama_arab']})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ayat ${_selectedAyat!['nomor_ayat']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          // Ayat Arab besar
                          Text(
                            _selectedAyat!['teks_arab'] ?? '',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Amiri', // jika ada font arab khusus
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedAyat!['teks_terjemah'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                _selectedAyat!['teks_terjemah'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            // Pilih surah & ayat
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final surah = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PilihSurahScreen()),
                  );
                  if (surah != null) {
                    setState(() {
                      _selectedSurah = Map<String, dynamic>.from(surah);
                      _selectedAyat = null;
                      _hasRecorded = false;
                      _uploadSuccess = null;
                      _audioPath = null;
                      _koreksiResult = null;
                      _pickedFileName = null;
                    });
                  }
                },
                child: Text(
                  _selectedSurah == null
                      ? 'Pilih Surah'
                      : 'Surah: ${_selectedSurah!['nama_latin']} (${_selectedSurah!['nama_arab']})',
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedSurah != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final ayat = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PilihAyatScreen(
                              surahId: _selectedSurah!['id'].toString(),
                            ),
                      ),
                    );
                    if (ayat != null) {
                      setState(() {
                        _selectedAyat = Map<String, dynamic>.from(ayat);
                        _hasRecorded = false;
                        _uploadSuccess = null;
                        _audioPath = null;
                        _koreksiResult = null;
                        _pickedFileName = null;
                      });
                    }
                  },
                  child: Text(
                    _selectedAyat == null
                        ? 'Pilih Ayat'
                        : 'Ayat ${_selectedAyat!['nomor_ayat']}: ${_selectedAyat!['teks_arab']}',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nama User (opsional)',
              ),
              onChanged: (val) => setState(() => _namaUser = val),
            ),
            const SizedBox(height: 32),
            if (_selectedAyat != null)
              Center(
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child:
                          _isRecording
                              ? Column(
                                key: const ValueKey('rec'),
                                children: const [
                                  Icon(Icons.mic, color: Colors.red, size: 40),
                                  SizedBox(height: 8),
                                  Text('Sedang merekam...'),
                                ],
                              )
                              : _hasRecorded
                              ? Column(
                                key: const ValueKey('done'),
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _pickedFileName != null
                                        ? 'File: $_pickedFileName'
                                        : 'Rekaman siap diupload',
                                  ),
                                ],
                              )
                              : const SizedBox.shrink(),
                    ),
                    // Ganti Row menjadi Wrap agar responsif
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                          label: Text(
                            _isRecording ? 'Stop Rekam' : 'Rekam Audio',
                          ),
                          onPressed:
                              _isRecording ? _stopRecording : _startRecording,
                        ),
                        ElevatedButton.icon(
                          icon: Icon(
                            _isPlaying ? Icons.stop : Icons.play_arrow,
                          ),
                          label: Text(_isPlaying ? 'Stop' : 'Preview'),
                          onPressed:
                              (_audioPath == null || !_hasRecorded)
                                  ? null
                                  : _isPlaying
                                  ? _stopAudio
                                  : _playAudio,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                          onPressed:
                              (_audioPath == null && !_hasRecorded)
                                  ? null
                                  : _reset,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            _isUploading ? 'Uploading...' : 'Upload Audio',
                          ),
                          onPressed:
                              (!_hasRecorded || _isUploading)
                                  ? null
                                  : _uploadAudio,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_isUploading)
                      FadeTransition(
                        opacity: _animController,
                        child: const Icon(
                          Icons.cloud_upload,
                          color: Colors.deepPurple,
                          size: 40,
                        ),
                      ),
                    if (_uploadSuccess == true)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 40,
                      ),
                    if (_uploadSuccess == false)
                      const Icon(Icons.error, color: Colors.red, size: 40),
                  ],
                ),
              ),
            if (_koreksiResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Card(
                  color: Colors.yellow.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hasil Koreksi:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_koreksiResult!),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
