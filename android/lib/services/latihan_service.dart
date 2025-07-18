import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

class LatihanService {
  static Future<List<Map<String, dynamic>>> fetchSurah() async {
    final res = await http.get(Uri.parse('${AppConstants.apiUrl}/surah'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Gagal mengambil data surah');
  }

  static Future<List<Map<String, dynamic>>> fetchAyat(String surahId) async {
    final res = await http.get(
      Uri.parse('${AppConstants.apiUrl}/ayat?surah_id=$surahId'),
    );
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Gagal mengambil data ayat');
  }

  static Future<Map<String, dynamic>> uploadAudio({
    required String audioPath,
    required String ayatId,
    String namaUser = '',
  }) async {
    final req =
        http.MultipartRequest(
            'POST',
            Uri.parse('${AppConstants.apiUrl}/asr/upload'),
          )
          ..fields['ayat_id'] = ayatId
          ..fields['nama_user'] = namaUser
          ..files.add(await http.MultipartFile.fromPath('audio', audioPath));
    final res = await req.send();
    final responseBody = await res.stream.bytesToString();
    if (res.statusCode == 200) {
      return json.decode(responseBody) as Map<String, dynamic>;
    }
    // Jika error, kembalikan error message
    return {'status': res.statusCode, 'error': responseBody};
  }
}
