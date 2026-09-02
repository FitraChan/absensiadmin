import 'dart:convert';

import 'package:absensiadmin/absensi/controllers/absensi_controller.dart';
import 'package:absensiadmin/api/api.dart';
import 'package:absensiadmin/karyawan/model/karyawan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class Absensi extends StatefulWidget {
  const Absensi({super.key});

  @override
  State<Absensi> createState() => _AbsensiState();
}

class _AbsensiState extends State<Absensi> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController tanggalController = TextEditingController();

  String? selectedKaryawan;
  String? selectedJenis;

  late AbsensiController controller;
  final List<String> karyawan = [
    'Fitra Anggara Yudha',
    'Budi Santoso',
    'Andi Saputra',
    'Siti Aminah',
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    controller = AbsensiController();

    tanggalController.text = DateTime.now().toString().substring(0, 10);

    getKaryawan();

    // Ambil data setelah widget selesai dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAbsensi(tanggal: tanggalController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,

        title: const Text(
          'Absensi Karyawan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,

          tabs: const [
            Tab(
              icon: const Icon(Icons.people_outline, color: Colors.white),
              child: const Text(
                'Data Absensi',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Tab(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              child: const Text(
                'Tambah Absensi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,

        children: [_dataAbsensi(), _tambahAbsensi()],
      ),
    );
  }

  // ==========================================================
  // DATA ABSENSI
  // ==========================================================

  Widget _dataAbsensi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // HEADER

          const Text(
            'Data Absensi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Kelola dan pantau absensi seluruh karyawan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // BUTTON DOWNLOAD
          // ==================================================
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _downloadAbsensi();
                },

                icon: const Icon(Icons.download_outlined),

                label: const Text('Download Absensi'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {});
                },

                icon: const Icon(Icons.refresh),

                label: const Text('Refresh'),

                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==================================================
          // SEARCH
          // ==================================================
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari karyawan...',

              prefixIcon: const Icon(Icons.search),

              filled: true,
              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // TABLE
          // ==================================================
          _buildAbsensiTable(),
        ],
      ),
    );
  }

  // ==========================================================
  // TABLE DATA ABSENSI
  // ==========================================================

  Widget _buildAbsensiTable() {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: dataKaryawan.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'Tidak ada data karyawan.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF0F5FF),
                ),

                columns: const [
                  DataColumn(
                    label: Text(
                      'No',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      'Nama',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      'Departemen',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      'Jabatan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      'Action',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],

                rows: List.generate(dataKaryawan.length, (index) {
                  final item = dataKaryawan[index];

                  return DataRow(
                    cells: [
                      // NO
                      DataCell(Text('${index + 1}')),

                      // NAMA
                      DataCell(Text(item.nama)),

                      // EMAIL
                      DataCell(Text(item.email)),

                      // DEPARTEMEN
                      DataCell(Text(item.departemen)),

                      // JABATAN
                      DataCell(Text(item.jabatan)),

                      // ACTION
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Detail',
                              onPressed: () {
                                _detailAbsensi(item.nama);
                              },
                              icon: const Icon(
                                Icons.visibility_outlined,
                                color: Color(0xFF1976D2),
                              ),
                            ),

                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () {
                                // edit karyawan
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
    );
  }
  // ==========================================================
  // TAMBAH ABSENSI
  // ==========================================================

  Widget _tambahAbsensi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Tambah Absensi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Tambahkan absensi karyawan secara manual.',
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth > 700;

                return Wrap(
                  spacing: 20,
                  runSpacing: 20,

                  children: [
                    SizedBox(
                      width: desktop
                          ? (constraints.maxWidth - 20) / 2
                          : constraints.maxWidth,

                      child: _dateField(),
                    ),

                    SizedBox(
                      width: desktop
                          ? (constraints.maxWidth - 20) / 2
                          : constraints.maxWidth,

                      child: _karyawanField(),
                    ),

                    SizedBox(
                      width: desktop
                          ? (constraints.maxWidth - 20) / 2
                          : constraints.maxWidth,

                      child: _waktuField(),
                    ),

                    SizedBox(
                      width: desktop
                          ? (constraints.maxWidth - 20) / 2
                          : constraints.maxWidth,

                      child: _jenisAbsensiField(),
                    ),

                    SizedBox(
                      width: constraints.maxWidth,

                      child: ElevatedButton.icon(
                        onPressed: _simpanAbsensi,

                        icon: const Icon(Icons.save_outlined),

                        label: const Text('Simpan Absensi'),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,

                          padding: const EdgeInsets.symmetric(vertical: 16),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Riwayat Absensi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 15),

          _buildRiwayatTable(),
        ],
      ),
    );
  }

  // ==========================================================
  // TANGGAL
  // ==========================================================

  Widget _dateField() {
    return TextField(
      controller: tanggalController,
      readOnly: true,

      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: tanggalController.text.isNotEmpty
              ? DateTime.tryParse(tanggalController.text) ?? DateTime.now()
              : DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (date != null) {
          final tanggal =
              '${date.year}-'
              '${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}';

          setState(() {
            tanggalController.text = tanggal;
          });

          // LANGSUNG AMBIL DATA ABSENSI
          await controller.getAbsensi(tanggal: tanggal);
        }
      },

      decoration: InputDecoration(
        labelText: 'Tanggal Absensi',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==========================================================
  // KARYAWAN
  // ==========================================================

  Widget _karyawanField() {
    return DropdownButtonFormField<int>(
      value: karyawanId,

      decoration: InputDecoration(
        labelText: 'Karyawan',
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      hint: const Text('Pilih Karyawan'),

      items: dataKaryawan.map((karyawan) {
        return DropdownMenuItem<int>(
          value: karyawan.id,
          child: Text(karyawan.nama),
        );
      }).toList(),

      onChanged: (value) async {
        setState(() {
          karyawanId = value;
          selectedKaryawan = value.toString();
        });

        // Langsung filter absensi
        await controller.getAbsensi(
          tanggal: tanggalController.text,
          karyawanId: value.toString(),
        );
      },
    );
  }

  List<Karyawan> dataKaryawan = [];

  int? karyawanId;

  Future<void> getKaryawan() async {
    try {
      final response = await Network().getData('getKaryawan');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final List data = body['data'] ?? [];

          setState(() {
            dataKaryawan = data.map((item) => Karyawan.fromJson(item)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error getKaryawan: $e');
    }
  }

  // ==========================================================
  // WAKTU
  // ==========================================================
  final TextEditingController waktuController = TextEditingController();
  Widget _waktuField() {
    return TextField(
      controller: waktuController,
      readOnly: true,

      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (time != null) {
          final jam = time.hour.toString().padLeft(2, '0');
          final menit = time.minute.toString().padLeft(2, '0');

          setState(() {
            waktuController.text = '$jam:$menit:00';
          });
        }
      },

      decoration: InputDecoration(
        labelText: 'Waktu',
        prefixIcon: const Icon(Icons.access_time_outlined),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  // ==========================================================
  // JENIS ABSENSI
  // ==========================================================

  Widget _jenisAbsensiField() {
    return DropdownButtonFormField<String>(
      value: selectedJenis,

      decoration: InputDecoration(
        labelText: 'Jenis Absensi',

        prefixIcon: const Icon(Icons.login_outlined),

        filled: true,
        fillColor: const Color(0xFFF8FAFD),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      items: const [
        DropdownMenuItem(value: 'in', child: Text('Masuk')),

        DropdownMenuItem(value: 'out', child: Text('Pulang')),
      ],

      onChanged: (value) {
        setState(() {
          selectedJenis = value;
        });
      },
    );
  }

  // ==========================================================
  // RIWAYAT TABLE
  // ==========================================================

  Widget _buildRiwayatTable() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // =========================
        // LOADING
        // =========================

        if (controller.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // =========================
        // ERROR
        // =========================

        if (controller.errorMessage != null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),

                const SizedBox(height: 10),

                Text(controller.errorMessage!, textAlign: TextAlign.center),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: () {
                    controller.getAbsensi(tanggal: tanggalController.text);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        // =========================
        // DATA KOSONG
        // =========================

        final data = controller.dataAbsensi;

        if (data.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            child: const Column(
              children: [
                Icon(Icons.event_busy, size: 45, color: Colors.grey),

                SizedBox(height: 10),

                Text(
                  'Belum ada data absensi.',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        // =========================
        // TABLE
        // =========================

        return Container(
          width: double.infinity,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F5FF)),

              columns: const [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Jam Masuk')),
                DataColumn(label: Text('Jam Pulang')),
              ],

              rows: List.generate(data.length, (index) {
                final absensi = data[index];

                final nama = absensi['karyawan']?['nama_lengkap'] ?? '-';

                final tanggal = absensi['tanggal'] != null
                    ? DateFormat('dd-MM-yyyy')
                          .format(DateTime.parse(absensi['tanggal']))
                    : '-';

                final jamMasuk = absensi['jam_masuk'] != null
                    ? absensi['jam_masuk'].toString().substring(11, 16)
                    : '-';

                final jamPulang = absensi['jam_pulang'] != null
                    ? absensi['jam_pulang'].toString().substring(11, 16)
                    : '-';

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),

                    DataCell(Text(nama)),

                    DataCell(Text(tanggal)),

                    DataCell(Text(jamMasuk)),

                    DataCell(Text(jamPulang)),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // SIMPAN
  // ==========================================================

  Future<void> _simpanAbsensi() async {
    if (selectedKaryawan == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Perhatian',
        text: 'Silakan pilih karyawan.',
      );
      return;
    }

    if (selectedJenis == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Perhatian',
        text: 'Silakan pilih jenis absensi.',
      );
      return;
    }

    if (tanggalController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Perhatian',
        text: 'Silakan pilih tanggal.',
      );
      return;
    }

    if (waktuController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Perhatian',
        text: 'Silakan pilih waktu.',
      );
      return;
    }

    // Gabungkan tanggal + waktu
    final waktu = '${tanggalController.text} ${waktuController.text}';

    debugPrint('Karyawan ID : $selectedKaryawan');
    debugPrint('Jenis       : $selectedJenis');
    debugPrint('Waktu       : $waktu');

    // =========================
    // LOADING
    // =========================

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Menyimpan Absensi',
      text: 'Mohon tunggu...',
      barrierDismissible: false,
    );

    Map data = {
      'karyawan_id': selectedKaryawan,
      'kt': selectedJenis,
      'waktu': waktu,
      'tanggal': tanggalController.text,
    };

    try {
      final response = await Network().getData_post(data, 'simpanAbsensiAdmin');

      // Tutup loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      final body = jsonDecode(response.body);

      debugPrint('Status Code : ${response.statusCode}');
      debugPrint('Response    : ${response.body}');

      // =========================
      // BERHASIL
      // =========================

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil',
          text: body['message'] ?? 'Absensi berhasil disimpan.',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
          },
        );

        await controller.getAbsensi(
          tanggal: tanggalController.text,
          karyawanId: selectedKaryawan,
        );

        // Kosongkan form
        setState(() {
          selectedKaryawan = null;
          selectedJenis = null;
          tanggalController.clear();
          waktuController.clear();
        });
      } else {
        // =========================
        // GAGAL DARI SERVER
        // =========================

        print(response.body);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text: body['message'] ?? 'Gagal menyimpan absensi.',
          confirmBtnText: 'OK',
        );
      }
    } catch (e) {
      // Pastikan loading ditutup jika terjadi error
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      debugPrint('Error simpan absensi: $e');

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Terjadi Kesalahan',
        text: 'Tidak dapat terhubung ke server.\n$e',
        confirmBtnText: 'OK',
      );
    }
  } // ==========================================================
  // DOWNLOAD
  // ==========================================================

  void _downloadAbsensi() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Download Absensi'),

          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Periode',
              border: OutlineInputBorder(),
            ),

            items: const [
              DropdownMenuItem(value: '1', child: Text('Januari 2026')),

              DropdownMenuItem(value: '2', child: Text('Februari 2026')),

              DropdownMenuItem(value: '3', child: Text('Maret 2026')),
            ],

            onChanged: (value) {},
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Batal'),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);

                _showMessage('Proses download dimulai.', true);
              },

              icon: const Icon(Icons.download),

              label: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // DETAIL
  // ==========================================================

  void _detailAbsensi(String nama) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text('Absensi $nama'),

          content: const Text(
            'Detail absensi karyawan akan ditampilkan di sini.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
