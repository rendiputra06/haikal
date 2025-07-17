import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final res = await http.get(
        Uri.parse(
          'http://localhost:5000/asr/api/ayat?surah_id=${widget.surahId}',
        ),
      );
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          _ayatList = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      // Error handling
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Ayat')),
      body:
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
