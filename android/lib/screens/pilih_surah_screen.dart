import 'package:flutter/material.dart';
import '../services/latihan_service.dart';
import '../widgets/main_layout.dart';

class PilihSurahScreen extends StatefulWidget {
  const PilihSurahScreen({Key? key}) : super(key: key);

  @override
  State<PilihSurahScreen> createState() => _PilihSurahScreenState();
}

class _PilihSurahScreenState extends State<PilihSurahScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _surahList = [];

  @override
  void initState() {
    super.initState();
    _fetchSurah();
  }

  Future<void> _fetchSurah() async {
    setState(() => _loading = true);
    try {
      final data = await LatihanService.fetchSurah();
      setState(() {
        _surahList = data;
      });
    } catch (e) {
      // Error handling
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Pilih Surah',
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                itemCount: _surahList.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = _surahList[i];
                  return ListTile(
                    title: Text('${s['nama_latin']} (${s['nama_arab']})'),
                    subtitle: Text('Jumlah ayat: ${s['jumlah_ayat']}'),
                    onTap: () => Navigator.pop(context, s),
                  );
                },
              ),
    );
  }
}
