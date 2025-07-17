import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class LatihanScreen extends StatefulWidget {
  const LatihanScreen({Key? key}) : super(key: key);

  @override
  State<LatihanScreen> createState() => _LatihanScreenState();
}

class _LatihanScreenState extends State<LatihanScreen> {
  String _mode = 'basic';
  String? _selectedAyat;
  String _namaUser = '';
  bool _isRecording = false;
  bool _isUploading = false;

  // Dummy data ayat
  final List<String> _dummyAyat = [
    'Al-Fatihah:1',
    'Al-Fatihah:2',
    'Al-Fatihah:3',
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Latihan Mandiri Al-Qur’an',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mode Latihan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'basic',
                  groupValue: _mode,
                  onChanged: (val) => setState(() => _mode = val!),
                ),
                const Text('Basic'),
                Radio<String>(
                  value: 'lanjutan',
                  groupValue: _mode,
                  onChanged: (val) => setState(() => _mode = val!),
                ),
                const Text('Lanjutan'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Ayat/Surah:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedAyat,
              hint: const Text('Pilih ayat'),
              items:
                  _dummyAyat
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (val) => setState(() => _selectedAyat = val),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nama User (opsional)',
              ),
              onChanged: (val) => setState(() => _namaUser = val),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Stop Rekam' : 'Rekam Audio'),
                  onPressed: () {
                    setState(() => _isRecording = !_isRecording);
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Audio'),
                  onPressed:
                      _isUploading
                          ? null
                          : () {
                            setState(() => _isUploading = true);
                            // Simulasi upload
                            Future.delayed(const Duration(seconds: 2), () {
                              setState(() => _isUploading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Audio berhasil diupload (dummy)!',
                                  ),
                                ),
                              );
                            });
                          },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
