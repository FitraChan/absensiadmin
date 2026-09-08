import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class Network {
  //if you are using android studio emulator, change localhost to 10.0.2.2
  static String? token;

  //var apiUrl = 'http://192.168.34.8/absensi_api/api/';

  static const String apiUrl = 'https://absensiapi.mbcconsulting.id/api/';

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token') ?? '')['token'];
  }

  authData(data, addr) async {
    // var fullUrl = _url + apiUrl;
    var fullUrl = apiUrl + addr;
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  getData(addr) async {
    //var fullUrl = _url + apiUrl;
    var fullUrl = apiUrl + addr;

    // kalau tidak mau log out comment aja yg di bawah //await _getToken();
    await _getToken();
    return await http.get(Uri.parse(fullUrl), headers: _setHeaders());
  }

  deleteData(addr) async {
    var fullUrl = apiUrl + addr;

    await _getToken();

    return await http.delete(Uri.parse(fullUrl), headers: _setHeaders());
  }

  Future<Uri> getUriParse(String addr) async {
    final fullUrl = apiUrl + addr;

    return Uri.parse(fullUrl);
  }

  Future<http.Response> getDataUri(Uri uri) async {
    await _getToken();

    return await http.get(uri, headers: _setHeaders());
  }

  getData_post(data, addr) async {
    var fullUrl = apiUrl + addr;
    await _getToken();

    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  Future<http.StreamedResponse> getDataPostImage({
    required String addr,
    required Uint8List imageBytes,
    required dynamic id,
    required String formattedDate,
    required String jenis,
    required double latitude,
    required double longitude,
    String filename = 'foto_wajah.jpg',
  }) async {
    final Uri fullUrl = Uri.parse('$apiUrl$addr');

    await _getToken();

    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      fullUrl,
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.files.add(
      http.MultipartFile.fromBytes('gambar', imageBytes, filename: filename),
    );

    request.fields.addAll({
      'karyawan_id': id.toString(),
      'waktu': formattedDate,
      'jenis': jenis,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });

    return await request.send();
  }

  getData_postImage(
    addr,
    path,
    id,
    formattedDate,
    jenis,
    latitude,
    longitude,
  ) async {
    var fullUrl = apiUrl + addr;

    var request = http.MultipartRequest('POST', Uri.parse(fullUrl));

    request.files.add(
      await http.MultipartFile.fromPath(
        'gambar', // Field name for the API
        path,
        filename: basename(path),
      ),
    );

    await _getToken();

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token', // If required
    });

    request.fields['karyawan_id'] = id.toString();
    request.fields['waktu'] = formattedDate;
    request.fields['jenis'] = jenis;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    var response = await request.send();

    return response;
  }

  // basename(nama, gambar) async {
  //   await http.MultipartFile.fromPath(
  //     nama, // Field name for the API
  //     gambar.path,
  //     filename: basename(gambar.path),
  //   );
  // }

  getData_get(addr) async {
    var fullUrl = apiUrl + addr;
    await _getToken();

    return await http.get(Uri.parse(fullUrl), headers: _setHeaders());
  }

  _setHeaders() => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
