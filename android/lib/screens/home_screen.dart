import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Beranda',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Icon(
              Icons.menu_book_rounded,
              size: 64,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'Selamat Datang di Quran Whisper',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi latihan dan koreksi hafalan Al-Qur’an berbasis Whisper AI. Mulai latihan, cek riwayat, dan pantau perkembangan hafalanmu secara mandiri!',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic, color: Colors.white),
              label: const Text(
                'Quick Akses: Mulai Latihan',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, '/latihan'),
            ),
            const SizedBox(height: 32),
            Card(
              color: Colors.deepPurple.shade50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Fitur Utama:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Latihan bacaan Al-Qur’an dengan rekam/upload audio',
                    ),
                    Text('• Koreksi otomatis & highlight kesalahan'),
                    Text('• Riwayat latihan & statistik perkembangan'),
                    Text('• Mode basic & lanjutan'),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.yellow.shade50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Langkah-langkah Penggunaan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Pilih surah'),
                    Text('2. Pilih ayat'),
                    Text('3. Rekam bacaan atau upload audio'),
                    Text('4. Kirim untuk dikoreksi'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
