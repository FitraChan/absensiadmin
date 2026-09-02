import 'dart:convert';
import 'dart:typed_data';

import 'package:absensiadmin/api/api.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

//import '../network/network.dart';

class Payroll extends StatefulWidget {
  const Payroll({super.key});

  @override
  State<Payroll> createState() => _PayrollState();
}

class _PayrollState extends State<Payroll> {
  // ============================================================
  // DATA
  // ============================================================

  List<Karyawan> dataKaryawan = [];

  bool loadingKaryawan = false;

  String searchKaryawan = '';

  final TextEditingController searchController = TextEditingController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    getKaryawan();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // GET KARYAWAN
  // ============================================================

  Future<void> getKaryawan() async {
    if (mounted) {
      setState(() {
        loadingKaryawan = true;
      });
    }

    try {
      final response = await Network().getData('getKaryawan');

      debugPrint('STATUS GET KARYAWAN : ${response.statusCode}');
      debugPrint('BODY GET KARYAWAN   : ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final List data = body['data'] ?? [];

          final List<Karyawan> result = data
              .map((item) => Karyawan.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          if (mounted) {
            setState(() {
              dataKaryawan = result;
            });
          }
        } else {
          debugPrint(
            'API ERROR : ${body['message'] ?? 'Gagal mengambil data'}',
          );
        }
      } else {
        debugPrint('HTTP ERROR : ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR GET KARYAWAN : $e');
      debugPrint('$stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          loadingKaryawan = false;
        });
      }
    }
  }

  // ============================================================
  // FILTER DATA
  // ============================================================

  List<Karyawan> get filteredKaryawan {
    if (searchKaryawan.trim().isEmpty) {
      return dataKaryawan;
    }

    final keyword = searchKaryawan.trim().toLowerCase();

    return dataKaryawan.where((item) {
      return item.nama.toLowerCase().contains(keyword) ||
          item.email.toLowerCase().contains(keyword) ||
          item.departemen.toLowerCase().contains(keyword) ||
          item.jabatan.toLowerCase().contains(keyword);
    }).toList();
  }

  // ============================================================
  // PAYROLL
  // ============================================================

  Future<void> _gaji(int id) async {
    /*
      SESUAIKAN URL INI DENGAN DOMAIN WEB LARAVEL KAMU.

      Contoh:
      https://domainkamu.com/gaji/7

      Jangan menggunakan endpoint /api jika halaman gaji
      merupakan halaman web Laravel.
    */

    final uri = Uri.parse('https://domainkamu.com/gaji/$id');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Tidak dapat membuka URL: $uri');
      }
    } catch (e) {
      debugPrint('Error buka payroll: $e');
    }
  }

  // ============================================================
  // DETAIL
  // ============================================================

  void _detailKaryawan(Karyawan item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildDetailSheet(item);
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        title: const Text(
          'Data Karyawan',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(color: Color(0xFF172033)),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadingKaryawan ? null : getKaryawan,
            icon: const Icon(Icons.refresh),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: getKaryawan,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: _buildContent(),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // HEADER
        // ======================================================

        _buildHeader(),

        const SizedBox(height: 20),

        // ======================================================
        // ACTION BUTTON
        // ======================================================
        _buildActionButtons(),

        const SizedBox(height: 25),

        // ======================================================
        // SEARCH
        // ======================================================
        _buildSearch(),

        const SizedBox(height: 20),

        // ======================================================
        // DATA
        // ======================================================
        if (loadingKaryawan)
          _buildLoadingKaryawan()
        else if (filteredKaryawan.isEmpty)
          _buildEmptyKaryawan()
        else
          _buildKaryawanList(),
      ],
    );
  }
  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Karyawan',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Kelola data karyawan dan payroll',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        // TOTAL KARYAWAN
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Row(
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 20,
                color: Color(0xFF1976D2),
              ),

              const SizedBox(width: 7),

              Text(
                '${dataKaryawan.length}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return TextField(
      controller: searchController,

      onChanged: (value) {
        setState(() {
          searchKaryawan = value;
        });
      },

      decoration: InputDecoration(
        hintText: 'Cari nama, email, departemen, jabatan...',

        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),

        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),

        suffixIcon: searchKaryawan.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    searchKaryawan = '';
                  });
                },

                icon: const Icon(Icons.close),
              )
            : null,

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
        ),
      ),
    );
  }

  // ============================================================
  // KARYAWAN LIST
  // ============================================================

  Widget _buildKaryawanList() {
    return Column(
      children: List.generate(filteredKaryawan.length, (index) {
        final item = filteredKaryawan[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 13),

          child: _buildKaryawanCard(item, index),
        );
      }),
    );
  }

  // ============================================================
  // KARYAWAN CARD
  // ============================================================

  Widget _buildKaryawanCard(Karyawan item, int index) {
    final initial = _getInitial(item.nama);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.grey.shade200),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),

            blurRadius: 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // AVATAR
          // ====================================================

          Container(
            width: 55,
            height: 55,

            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),

              borderRadius: BorderRadius.circular(16),
            ),

            alignment: Alignment.center,

            child: Text(
              initial,

              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ),

          const SizedBox(width: 15),

          // ====================================================
          // DATA KARYAWAN
          // ====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // NAMA
                Text(
                  item.nama,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 5),

                // EMAIL
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        item.email,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 11),

                // BADGES
                Wrap(
                  spacing: 7,
                  runSpacing: 6,

                  children: [
                    _buildInfoBadge(Icons.business_outlined, item.departemen),

                    _buildInfoBadge(Icons.work_outline, item.jabatan),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ====================================================
          // ACTION
          // ====================================================
          PopupMenuButton<String>(
            tooltip: 'Menu',

            onSelected: (value) {
              if (value == 'payroll') {
                _gaji(item.id);
              }

              if (value == 'detail') {
                _detailKaryawan(item);
              }
            },

            itemBuilder: (context) {
              return [
                const PopupMenuItem<String>(
                  value: 'payroll',

                  child: Row(
                    children: [
                      Icon(Icons.payments_outlined, size: 20),

                      SizedBox(width: 10),

                      Text('Payroll'),
                    ],
                  ),
                ),

                const PopupMenuItem<String>(
                  value: 'detail',

                  child: Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 20),

                      SizedBox(width: 10),

                      Text('Detail'),
                    ],
                  ),
                ),
              ];
            },

            child: Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),

                borderRadius: BorderRadius.circular(10),
              ),

              child: const Icon(
                Icons.more_vert,
                size: 20,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BADGE
  // ============================================================

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),

        borderRadius: BorderRadius.circular(8),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),

          const SizedBox(width: 5),

          Text(
            text,

            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingKaryawan() {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          height: 120,

          margin: const EdgeInsets.only(bottom: 13),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(18),
          ),

          child: const Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyKaryawan() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,

            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.people_outline,
              size: 38,
              color: Color(0xFF94A3B8),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            searchKaryawan.isNotEmpty
                ? 'Karyawan tidak ditemukan'
                : 'Belum ada data karyawan',

            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            searchKaryawan.isNotEmpty
                ? 'Coba gunakan kata kunci lain.'
                : 'Data karyawan belum tersedia.',

            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL SHEET
  // ============================================================

  Widget _buildDetailSheet(Karyawan item) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),

      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // HANDLE
            Container(
              width: 45,
              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,

                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 22),

            // AVATAR
            Container(
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),

                borderRadius: BorderRadius.circular(20),
              ),

              alignment: Alignment.center,

              child: Text(
                _getInitial(item.nama),

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              item.nama,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              item.email,

              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 25),

            _buildDetailItem(
              Icons.badge_outlined,
              'ID Karyawan',
              item.id.toString(),
            ),

            _buildDetailItem(
              Icons.business_outlined,
              'Departemen',
              item.departemen,
            ),

            _buildDetailItem(Icons.work_outline, 'Jabatan', item.jabatan),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);

                  _gaji(item.id);
                },

                icon: const Icon(Icons.payments_outlined),

                label: const Text(
                  'Buka Payroll',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ITEM
  // ============================================================

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),

        borderRadius: BorderRadius.circular(13),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, size: 20, color: const Color(0xFF1976D2)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INITIAL
  // ============================================================

  String _getInitial(String nama) {
    final cleanName = nama.trim();

    if (cleanName.isEmpty) {
      return 'K';
    }

    final words = cleanName.split(RegExp(r'\s+'));

    if (words.length >= 2) {
      return ('${words[0][0]}'
              '${words[1][0]}')
          .toUpperCase();
    }

    return words[0][0].toUpperCase();
  }

  // ============================================================
  // FETCH GAJI
  // ============================================================

  Future<void> _fetchGaji() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Memproses...',
      text: 'Sedang mengambil data gaji.',
      barrierDismissible: false,
    );

    try {
      final response = await Network().getData('fetchGaji');
      if (!mounted) return;

      Navigator.of(context).pop(); // tutup loading

      if (response.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil',
          text: 'Data gaji berhasil di-fetch.',
          confirmBtnText: 'OK',
        );
      } else {
        print('Gagal fetch gaji. Status: ${response.body}');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text:
              'Gagal mengambil data gaji.\n'
              'Status: ${response.statusCode}',
          confirmBtnText: 'OK',
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop(); // tutup loading

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'Gagal memproses data gaji.',
        confirmBtnText: 'OK',
      );

      debugPrint('Error fetch gaji: $e');
    }
  }

  // ============================================================
  // PDF PAYROLL
  // ============================================================

  Future<void> _pdfPayroll() async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Memproses...',
        text: 'Sedang mengambil PDF payroll.',
        barrierDismissible: false,
      );

      final response = await Network().getData('downloadMultipleGaji');

      print('STATUS PDF PAYROLL: ${response.statusCode}');

      if (!mounted) return;

      Navigator.of(context).pop();

      if (response.statusCode != 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text:
              'Gagal mengambil PDF payroll.\n'
              'Status: ${response.statusCode}',
          confirmBtnText: 'OK',
        );
        return;
      }

      final Uint8List zipBytes = response.bodyBytes;

      final archive = ZipDecoder().decodeBytes(zipBytes);

      final List<PdfFileData> pdfFiles = [];

      for (final file in archive) {
        if (!file.isFile) continue;

        final fileName = file.name;

        if (fileName.toLowerCase().endsWith('.pdf')) {
          final bytes = Uint8List.fromList(file.content as List<int>);

          pdfFiles.add(
            PdfFileData(name: fileName.split('/').last, bytes: bytes),
          );
        }
      }

      if (pdfFiles.isEmpty) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'PDF Tidak Ditemukan',
          text: 'File ZIP tidak berisi PDF payroll.',
          confirmBtnText: 'OK',
        );
        return;
      }

      _showPdfList(title: 'PDF Payroll', pdfFiles: pdfFiles);
    } catch (e, stackTrace) {
      if (!mounted) return;

      Navigator.of(context).pop();

      debugPrint('ERROR PDF PAYROLL: $e');
      debugPrint('$stackTrace');

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'Gagal membuka ZIP payroll.',
        confirmBtnText: 'OK',
      );
    }
  }

  // ============================================================
  // PDF ABSENSI
  // ============================================================

  Future<void> _pdfAbsensi() async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Memproses...',
        text: 'Sedang mengambil PDF absensi.',
        barrierDismissible: false,
      );

      final response = await Network().getData('downloadMultipleAbsen');

      if (!mounted) return;

      Navigator.of(context).pop();

      if (response.statusCode != 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text:
              'Gagal mengambil PDF absensi.\n'
              'Status: ${response.statusCode}',
          confirmBtnText: 'OK',
        );
        return;
      }

      final Uint8List zipBytes = response.bodyBytes;

      final archive = ZipDecoder().decodeBytes(zipBytes);

      final List<PdfFileData> pdfFiles = [];

      for (final file in archive) {
        if (!file.isFile) continue;

        final fileName = file.name;

        if (fileName.toLowerCase().endsWith('.pdf')) {
          final bytes = Uint8List.fromList(file.content as List<int>);

          pdfFiles.add(
            PdfFileData(name: fileName.split('/').last, bytes: bytes),
          );
        }
      }

      if (pdfFiles.isEmpty) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'PDF Tidak Ditemukan',
          text: 'File ZIP tidak berisi PDF absensi.',
          confirmBtnText: 'OK',
        );
        return;
      }

      _showPdfList(title: 'PDF Absensi', pdfFiles: pdfFiles);
    } catch (e, stackTrace) {
      if (!mounted) return;

      Navigator.of(context).pop();

      debugPrint('ERROR PDF ABSENSI: $e');
      debugPrint('$stackTrace');

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'Gagal membuka ZIP absensi.',
        confirmBtnText: 'OK',
      );
    }
  }

  void _showPdfList({
    required String title,
    required List<PdfFileData> pdfFiles,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${pdfFiles.length} file PDF',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Divider(height: 1),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: pdfFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pdf = pdfFiles[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        debugPrint('PDF NAME : ${pdf.name}');
                        debugPrint('PDF SIZE : ${pdf.bytes.length} bytes');

                        if (pdf.bytes.isEmpty) {
                          debugPrint('PDF KOSONG!');
                          return;
                        }

                        debugPrint(
                          'PDF HEADER : ${String.fromCharCodes(pdf.bytes.take(5))}',
                        );
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PDFViewerScreen(
                              pdfBytes: pdf.bytes,
                              title: pdf.name,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf,
                                color: Color(0xFFDC2626),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                pdf.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        if (isMobile) {
          return Column(
            children: [
              _buildActionButton(
                title: 'Fetch Gaji',
                subtitle: 'Ambil data payroll terbaru',
                icon: Icons.sync_alt_rounded,
                onTap: _fetchGaji,
              ),

              const SizedBox(height: 12),

              _buildActionButton(
                title: 'PDF Payroll',
                subtitle: 'Download laporan payroll',
                icon: Icons.picture_as_pdf_outlined,
                onTap: _pdfPayroll,
              ),

              const SizedBox(height: 12),

              _buildActionButton(
                title: 'PDF Absensi',
                subtitle: 'Download laporan absensi',
                icon: Icons.fact_check_outlined,
                onTap: _pdfAbsensi,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'Fetch Gaji',
                subtitle: 'Ambil data payroll terbaru',
                icon: Icons.sync_alt_rounded,
                onTap: _fetchGaji,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildActionButton(
                title: 'PDF Payroll',
                subtitle: 'Download laporan payroll',
                icon: Icons.picture_as_pdf_outlined,
                onTap: _pdfPayroll,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildActionButton(
                title: 'PDF Absensi',
                subtitle: 'Download laporan absensi',
                icon: Icons.fact_check_outlined,
                onTap: _pdfAbsensi,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: Colors.grey.shade200),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),

                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, color: const Color(0xFF1976D2), size: 23),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    debugPrint('================================');
    debugPrint('PDF VIEWER');
    debugPrint('NAME : ${widget.title}');
    debugPrint('SIZE : ${widget.pdfBytes.length}');
    debugPrint('HEADER : ${String.fromCharCodes(widget.pdfBytes.take(5))}');
    debugPrint('================================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: widget.pdfBytes.isEmpty
          ? const Center(child: Text('PDF kosong'))
          : SfPdfViewer.memory(
              widget.pdfBytes,
              onDocumentLoaded: (details) {
                debugPrint(
                  'PDF BERHASIL DIBUKA: ${details.document.pages.count} halaman',
                );

                if (mounted) {
                  setState(() {
                    loading = false;
                  });
                }
              },
              onDocumentLoadFailed: (details) {
                debugPrint('PDF ERROR: ${details.error}');
                debugPrint('PDF DESCRIPTION: ${details.description}');

                if (mounted) {
                  setState(() {
                    loading = false;
                    error = details.description;
                  });
                }
              },
            ),
    );
  }
}

class PdfFileData {
  final String name;
  final Uint8List bytes;

  PdfFileData({required this.name, required this.bytes});
}

// ================================================================
// MODEL KARYAWAN
// ================================================================

class Karyawan {
  final int id;
  final String nama;
  final String email;
  final String jabatan;
  final String departemen;

  Karyawan({
    required this.id,
    required this.nama,
    required this.email,
    required this.jabatan,
    required this.departemen,
  });

  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      id: json['id'] ?? 0,

      nama: json['nama_karyawan'] ?? json['nama_lengkap'] ?? '-',

      email: json['email'] ?? '-',

      jabatan: json['nama_jabatan'] ?? '-',

      departemen: json['nama_departement'] ?? '-',
    );
  }
}
