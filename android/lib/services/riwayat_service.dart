import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

class RiwayatService {
  static Future<List<Map<String, dynamic>>> fetchRiwayat() async {
    final res = await http.get(Uri.parse('${AppConstants.apiUrl}/riwayat'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Gagal mengambil data riwayat');
  }

  static Future<Map<String, dynamic>> fetchRiwayatDetail(int id) async {
    final res = await http.get(Uri.parse('${AppConstants.apiUrl}/riwayat/$id'));
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Gagal mengambil detail riwayat');
  }
}
