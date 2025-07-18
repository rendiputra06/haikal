import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../services/riwayat_service.dart';
import 'riwayat_detail_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late Future<List<Map<String, dynamic>>> _riwayatFuture;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = RiwayatService.fetchRiwayat();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Riwayat Latihan',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _riwayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat riwayat: \\${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada riwayat.'));
          }
          final riwayat = snapshot.data!;
          return ListView.builder(
            itemCount: riwayat.length,
            itemBuilder: (context, index) {
              final item = riwayat[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    '${item['surah']} : ${item['ayat']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${item['nama_user']}'),
                      Text('Waktu: ${item['waktu']}'),
                      Text('Mode: ${item['mode']}'),
                      Text('Skor: ${item['skor']}'),
                      const SizedBox(height: 4),
                      Text('Transkripsi: ${item['hasil_transkripsi']}'),
                      const SizedBox(height: 2),
                      Text('Referensi: ${item['referensi_ayat']}'),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RiwayatDetailScreen(id: item['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
