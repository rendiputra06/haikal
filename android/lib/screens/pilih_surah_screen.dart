import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final res = await http.get(
        Uri.parse('http://localhost:5000/asr/api/surah'),
      );
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          _surahList = data.cast<Map<String, dynamic>>();
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
      appBar: AppBar(title: const Text('Pilih Surah')),
      body:
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
