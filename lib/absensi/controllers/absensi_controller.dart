import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AbsensiController extends ChangeNotifier {
  List<dynamic> dataAbsensi = [];

  bool loading = false;

  String? errorMessage;

  Future<void> getAbsensi({
    String? tanggal,

    String? karyawanId,
    String? search,
  }) async {
    loading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final network = Network();

      // =========================
      // AMBIL URI
      // =========================

      final uri = await network.getUriParse('absensiAdmin');

      // =========================
      // TAMBAHKAN QUERY PARAMETER
      // =========================

      final finalUri = uri.replace(
        queryParameters: {
          if (tanggal != null && tanggal.isNotEmpty) 'tanggal': tanggal,

          if (karyawanId != null && karyawanId.isNotEmpty)
            'karyawan_id': karyawanId,

          if (search != null && search.isNotEmpty) 'search': search,

          'per_page': '20',
        },
      );

      debugPrint('GET ABSENSI: $finalUri');

      // =========================
      // REQUEST
      // =========================

      final response = await network.getDataUri(finalUri);

      // debugPrint('STATUS: ${response.statusCode}');
      // debugPrint('BODY: ${response.body}');

      // =========================
      // JSON
      // =========================

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];

        if (data is List) {
          dataAbsensi = data;
        } else if (data is Map && data['data'] is List) {
          dataAbsensi = data['data'];
        } else {
          dataAbsensi = [];
        }

        debugPrint('JUMLAH ABSENSI: ${dataAbsensi.length}');
      } else {
        errorMessage = body['message'] ?? 'Gagal mengambil data absensi.';

        print('ERROR ABSENSI: $response.body');
      }
    } catch (e) {
      errorMessage = e.toString();

      debugPrint('ERROR ABSENSI: $e');
    } finally {
      loading = false;

      notifyListeners();
    }
  }
}
