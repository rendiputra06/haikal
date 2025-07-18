import 'package:flutter/material.dart';
import '../services/latihan_service.dart';
import '../widgets/main_layout.dart';

class PilihAyatScreen extends StatefulWidget {
  final String surahId;
  const PilihAyatScreen({Key? key, required this.surahId}) : super(key: key);

  @override
  State<PilihAyatScreen> createState() => _PilihAyatScreenState();
}

class _PilihAyatScreenState extends State<PilihAyatScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _ayatList = [];

  @override
  void initState() {
    super.initState();
    _fetchAyat();
  }

  Future<void> _fetchAyat() async {
    setState(() => _loading = true);
    try {
      final data = await LatihanService.fetchAyat(widget.surahId);
      setState(() {
        _ayatList = data;
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
      title: 'Pilih Ayat',
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                itemCount: _ayatList.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final a = _ayatList[i];
                  return ListTile(
                    title: Text('Ayat ${a['nomor_ayat']}'),
                    subtitle: Text(a['teks_arab']),
                    onTap: () => Navigator.pop(context, a),
                  );
                },
              ),
    );
  }
}
