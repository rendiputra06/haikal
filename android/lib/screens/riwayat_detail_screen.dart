import 'package:flutter/material.dart';
import '../services/riwayat_service.dart';
import '../widgets/main_layout.dart';

class RiwayatDetailScreen extends StatefulWidget {
  final int id;
  const RiwayatDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<RiwayatDetailScreen> createState() => _RiwayatDetailScreenState();
}

class _RiwayatDetailScreenState extends State<RiwayatDetailScreen> {
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = RiwayatService.fetchRiwayatDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Detail Riwayat',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat detail: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.containsKey('error')) {
            return const Center(child: Text('Data riwayat tidak ditemukan'));
          }
          final data = snapshot.data!;
          final surahData = data['surah_data'] ?? {};
          final ayatData = data['ayat_data'] ?? {};
          final detailList = (data['detail'] as List?) ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Surah & Ayat
                Card(
                  color: Colors.deepPurple.shade50,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${surahData['nama_latin'] ?? data['surah']} ( ${surahData['nama_arab'] ?? ''} )',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ayat ${ayatData['nomor_ayat'] ?? data['ayat']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ayatData['teks_arab'] ?? '-',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ayatData['teks_terjemah'] ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Info User & Skor
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      'Nama: ${data['nama_user']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(Icons.score, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Skor: ${data['skor']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text('Waktu: ${data['waktu']}'),
                    const Spacer(),
                    const Icon(Icons.mic, color: Colors.deepPurple),
                    const SizedBox(width: 4),
                    Text('Mode: ${data['mode']}'),
                  ],
                ),
                const Divider(height: 24),
                // Transkripsi & Referensi
                Text(
                  'Transkripsi:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data['hasil_transkripsi'] ?? '-',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Referensi:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data['referensi_ayat'] ?? '-',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Divider(height: 32),
                // Detail Kata
                Text(
                  'Detail Kata:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                detailList.isEmpty
                    ? const Text('-')
                    : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      textDirection: TextDirection.rtl,
                      children:
                          detailList.map<Widget>((d) {
                            final kata = d['word']?.toString() ?? '-';
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
                                    isBenar ? Icons.check_circle : Icons.cancel,
                                    color: isBenar ? Colors.green : Colors.red,
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
                                  color: isBenar ? Colors.green : Colors.red,
                                  width: 1,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
