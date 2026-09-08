import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:absensiadmin/karyawan/model/karyawan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class KaryawanAbsenPage extends StatefulWidget {
  const KaryawanAbsenPage({super.key});

  @override
  State<KaryawanAbsenPage> createState() => _KaryawanAbsenPageState();
}

class _KaryawanAbsenPageState extends State<KaryawanAbsenPage> {
  List<dynamic> dataAbsensi = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getKaryawanAbsen();
    getKaryawan();
  }

  Future<void> updatePersetujuanAbsen({
    required dynamic id,
    required String status,
  }) async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Memproses...',
        text: 'Sedang menyimpan persetujuan absen.',
        barrierDismissible: false,
      );

      final data = {'id': id, 'status': status};

      print('================================');
      print('DATA UPDATE: $data');
      print('================================');

      final response = await Network().getData_post(
        data,
        'karyawanAbsenAdmin/update',
      );

      print('================================');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');
      print('================================');

      // Tutup loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        if (!context.mounted) return;

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil',
          text: body['message'] ?? 'Data berhasil diperbarui.',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.pop(context); // tutup alert
            Navigator.pop(context); // tutup dialog detail

            getKaryawanAbsen();
          },
        );
      } else {
        if (!context.mounted) return;

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text: body['message'] ?? 'Gagal memperbarui data.',
          confirmBtnText: 'OK',
        );
      }
    } catch (e) {
      print('ERROR UPDATE PERSETUJUAN: $e');

      if (context.mounted) {
        Navigator.pop(context);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: e.toString(),
          confirmBtnText: 'OK',
        );
      }
    }
  }

  // =========================================================
  // GET DATA
  // =========================================================
  Future<void> getKaryawanAbsen() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await Network().getData('karyawanAbsenAdmin');

      // =========================
      // CEK STATUS HTTP
      // =========================
      if (response.statusCode != 200) {
        print('HTTP ERROR: ${response.statusCode}');

        if (!mounted) return;

        setState(() {
          dataAbsensi = [];
          isLoading = false;
        });

        return;
      }

      // =========================
      // DECODE JSON
      // =========================
      dynamic body;

      try {
        body = jsonDecode(response.body);
      } catch (e) {
        print('JSON DECODE ERROR: $e');

        if (!mounted) return;

        setState(() {
          dataAbsensi = [];
          isLoading = false;
        });

        return;
      }

      print('BODY TYPE: ${body.runtimeType}');
      print('BODY: $body');

      // =========================
      // PASTIKAN BODY MAP
      // =========================
      if (body is! Map<String, dynamic>) {
        print('BODY BUKAN MAP');

        if (!mounted) return;

        setState(() {
          dataAbsensi = [];
          isLoading = false;
        });

        return;
      }

      // =========================
      // CEK SUCCESS
      // =========================
      if (body['success'] != true) {
        print('SUCCESS FALSE');
        print('MESSAGE: ${body['message']}');

        if (!mounted) return;

        setState(() {
          dataAbsensi = [];
          isLoading = false;
        });

        return;
      }

      // =========================
      // AMBIL DATA
      // =========================
      dynamic data = body['data'];

      print('DATA TYPE: ${data.runtimeType}');
      print('DATA: $data');

      // =========================
      // DATA LANGSUNG LIST
      // =========================
      if (data is List) {
        dataAbsensi = List<dynamic>.from(data);
      }
      // =========================
      // KALAU DATA BERBENTUK:
      // {
      //   "data": {
      //      "data": [...]
      //   }
      // }
      // =========================
      else if (data is Map && data['data'] is List) {
        dataAbsensi = List<dynamic>.from(data['data']);
      }
      // =========================
      // DATA TIDAK SESUAI
      // =========================
      else {
        print('DATA BUKAN LIST');

        dataAbsensi = [];
      }

      // =========================
      // SELESAI
      // =========================
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      print('================================');
      print('TOTAL DATA ABSENSI: ${dataAbsensi.length}');
      print('================================');
    } catch (e, stackTrace) {
      print('================================');
      print('ERROR GET KARYAWAN ABSEN: $e');
      print(stackTrace);
      print('================================');

      if (!mounted) return;

      setState(() {
        dataAbsensi = [];
        isLoading = false;
      });

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Gagal',
        text: 'Tidak dapat mengambil data absensi.',
      );
    }
  } // =========================================================
  // HELPER
  // =========================================================

  String value(dynamic value) {
    if (value == null) return '-';

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return '-';
    }

    return text;
  }

  String namaKaryawan(dynamic item) {
    final karyawan = item['karyawan'];

    if (karyawan is Map) {
      return value(
        karyawan['nama_lengkap'] ?? karyawan['nama'] ?? karyawan['name'],
      );
    }

    return '-';
  }

  String formatTanggal(dynamic tanggal) {
    if (tanggal == null) return '-';

    final text = tanggal.toString();

    if (text.isEmpty || text == 'null') {
      return '-';
    }

    try {
      final date = DateTime.parse(text);

      const bulan = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      return '${date.day} ${bulan[date.month - 1]} ${date.year}';
    } catch (e) {
      return text;
    }
  }

  String jenisAbsen(String jenis) {
    switch (jenis.toUpperCase()) {
      case 'I':
        return 'IZIN';

      case 'S':
        return 'SAKIT';

      case 'A':
        return 'ALPHA';

      case 'C':
        return 'CUTI';

      default:
        return jenis;
    }
  }

  Color jenisColor(String jenis) {
    switch (jenis.toUpperCase()) {
      case 'I':
        return const Color(0xFF2563EB);

      case 'S':
        return const Color(0xFFDC2626);

      case 'A':
        return const Color(0xFF64748B);

      case 'C':
        return const Color(0xFF9333EA);

      default:
        return const Color(0xFF64748B);
    }
  }

  Color statusColor(String status) {
    final text = status.toUpperCase();

    if (text.contains('SETUJU') || text == 'APPROVED') {
      return const Color(0xFF16A34A);
    }

    if (text.contains('TOLAK') || text == 'REJECTED') {
      return const Color(0xFFDC2626);
    }

    if (text.contains('MENUNGGU') ||
        text.contains('PROSES') ||
        text == 'PENDING') {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF64748B);
  }

  IconData jenisIcon(String jenis) {
    switch (jenis.toUpperCase()) {
      case 'I':
        return Icons.info_outline_rounded;

      case 'S':
        return Icons.local_hospital_outlined;

      case 'A':
        return Icons.person_off_outlined;

      case 'C':
        return Icons.beach_access_outlined;

      default:
        return Icons.event_note_outlined;
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Absensi Karyawan',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Data izin, sakit, alpha dan cuti',
              style: TextStyle(color: Color(0xFF7A869A), fontSize: 12),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: isLoading ? null : getKaryawanAbsen,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1976D2)),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: getKaryawanAbsen,

        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1976D2)),
              )
            : dataAbsensi.isEmpty
            ? _emptyData()
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

                children: [
                  _summary(),

                  const SizedBox(height: 20),

                  // =========================
                  // TOMBOL TAMBAH IZIN
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // buka halaman / dialog tambah izin
                        _showTambahIzin();
                      },
                      icon: const Icon(Icons.add_rounded, size: 21),
                      label: const Text(
                        'Tambah Izin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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

                  const SizedBox(height: 20),

                  const Text(
                    'Daftar Absensi',
                    style: TextStyle(
                      color: Color(0xFF172B4D),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...List.generate(dataAbsensi.length, (index) {
                    return _absenCard(dataAbsensi[index]);
                  }),
                ],
              ),
      ),
    );
  }

  void _showTambahIzin() {
    final formKey = GlobalKey<FormState>();

    Karyawan? selectedKaryawan;
    String? selectedStatus;

    DateTime? tanggalMulai;
    DateTime? tanggalSelesai;

    final keteranganController = TextEditingController();

    final tanggalPersetujuanController = TextEditingController(
      text: DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Tambah Izin',
                      style: TextStyle(
                        color: Color(0xFF172B4D),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========================
                        // KARYAWAN
                        // =========================
                        const Text(
                          'Nama Karyawan',
                          style: TextStyle(
                            color: Color(0xFF172B4D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<dynamic>(
                          value: selectedKaryawan,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: '-- Pilih Karyawan --',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                          ),

                          items: dataKaryawan.map((item) {
                            return DropdownMenuItem<dynamic>(
                              value: item,
                              child: Text(
                                item.nama,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setDialogState(() {
                              selectedKaryawan = value;
                            });
                          },

                          validator: (value) {
                            if (value == null) {
                              return 'Karyawan wajib dipilih';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // =========================
                        // TANGGAL MULAI
                        // =========================
                        const Text(
                          'Tanggal Mulai',
                          style: TextStyle(
                            color: Color(0xFF172B4D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tanggalMulai ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (date != null) {
                              setDialogState(() {
                                tanggalMulai = date;
                              });
                            }
                          },

                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: 'Pilih tanggal mulai',
                              suffixIcon: const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF1976D2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: Text(
                              tanggalMulai == null
                                  ? 'Pilih tanggal mulai'
                                  : DateFormat('dd-MM-yyyy')
                                        .format(tanggalMulai!),
                              style: TextStyle(
                                color: tanggalMulai == null
                                    ? Colors.grey
                                    : const Color(0xFF172B4D),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =========================
                        // TANGGAL SELESAI
                        // =========================
                        const Text(
                          'Tanggal Selesai',
                          style: TextStyle(
                            color: Color(0xFF172B4D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  tanggalSelesai ??
                                  tanggalMulai ??
                                  DateTime.now(),
                              firstDate: tanggalMulai ?? DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (date != null) {
                              setDialogState(() {
                                tanggalSelesai = date;
                              });
                            }
                          },

                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: 'Pilih tanggal selesai',
                              suffixIcon: const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF1976D2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: Text(
                              tanggalSelesai == null
                                  ? 'Pilih tanggal selesai'
                                  : DateFormat('dd-MM-yyyy')
                                        .format(tanggalSelesai!),
                              style: TextStyle(
                                color: tanggalSelesai == null
                                    ? Colors.grey
                                    : const Color(0xFF172B4D),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =========================
                        // STATUS
                        // =========================
                        const Text(
                          'Status Absensi',
                          style: TextStyle(
                            color: Color(0xFF172B4D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          isExpanded: true,

                          decoration: InputDecoration(
                            hintText: '-- Pilih Status --',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                          ),

                          items: const [
                            DropdownMenuItem(value: 'I', child: Text('IZIN')),
                            DropdownMenuItem(value: 'S', child: Text('SAKIT')),
                            DropdownMenuItem(value: 'A', child: Text('ALPHA')),
                            DropdownMenuItem(value: 'C', child: Text('CUTI')),
                          ],

                          onChanged: (value) {
                            setDialogState(() {
                              selectedStatus = value;
                            });
                          },

                          validator: (value) {
                            if (value == null) {
                              return 'Status wajib dipilih';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // =========================
                        // TANGGAL PERSETUJUAN
                        // =========================
                        const Text(
                          'Tanggal Persetujuan',
                          style: TextStyle(
                            color: Color(0xFF172B4D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: tanggalPersetujuanController,
                          readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF7A869A),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =========================
                        // KETERANGAN
                        // =========================
                        const Text(
                          'Keterangan',
                          style: TextStyle(
                            color: Color(0xFF172B4D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: keteranganController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Masukkan alasan izin, sakit, alpha, atau cuti',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // =========================
              // BUTTON
              // =========================
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

              actions: [
                SizedBox(
                  width: 100,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5E6C84),
                      side: const BorderSide(color: Color(0xFFDFE1E6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        if (tanggalMulai == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tanggal mulai wajib dipilih'),
                            ),
                          );
                          return;
                        }

                        if (tanggalSelesai == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tanggal selesai wajib dipilih'),
                            ),
                          );
                          return;
                        }

                        if (tanggalSelesai!.isBefore(tanggalMulai!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tanggal selesai tidak boleh sebelum tanggal mulai',
                              ),
                            ),
                          );
                          return;
                        }

                        // Konfirmasi
                        _simpanTambahIzin(
                          karyawanId: selectedKaryawan?.id,
                          tanggalMulai: DateFormat('yyyy-MM-dd')
                              .format(tanggalMulai!),
                          tanggalSelesai: DateFormat('yyyy-MM-dd')
                              .format(tanggalSelesai!),
                          status: selectedStatus!,
                          tglPersetujuan: tanggalPersetujuanController.text,
                          keterangan: keteranganController.text,
                          dialogContext: dialogContext,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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

  Future<void> _simpanTambahIzin({
    required int? karyawanId,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String status,
    required String tglPersetujuan,
    required String keterangan,
    required BuildContext dialogContext,
  }) async {
    try {
      Navigator.pop(dialogContext);

      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Memproses...',
        text: 'Sedang menyimpan data absensi.',
        barrierDismissible: false,
      );

      final data = {
        'karyawan_id': karyawanId,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'status_absensi': status,
        'tgl_persetujuan': tglPersetujuan,
        'keterangan': keterangan,
      };

      print('================================');
      print('DATA TAMBAH IZIN');
      print(data);
      print('================================');

      final response = await Network().getData_post(
        data,
        'karyawanAbsenAdmin/updateRange',
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (context.mounted) {
        Navigator.pop(context);
      }

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        if (!context.mounted) return;

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil',
          text: body['message'] ?? 'Status absensi berhasil diperbarui.',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.pop(context);

            getKaryawanAbsen();
          },
        );
      } else {
        if (!context.mounted) return;

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text: body['message'] ?? 'Gagal menyimpan data absensi.',
          confirmBtnText: 'OK',
        );
      }
    } catch (e) {
      print('ERROR TAMBAH IZIN: $e');

      if (context.mounted) {
        Navigator.pop(context);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: e.toString(),
          confirmBtnText: 'OK',
        );
      }
    }
  }

  // =========================================================
  // SUMMARY
  // =========================================================

  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Total Data',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  '${dataAbsensi.length} Data Absensi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CARD ABSENSI
  // =========================================================

  List<String> getTanggalLks(dynamic tanggal, dynamic durasi) {
    try {
      if (tanggal == null) return [];

      final List<dynamic> dates = jsonDecode(tanggal.toString());

      final int jumlahHari = int.tryParse(durasi?.toString() ?? '0') ?? 0;

      final List<String> hasil = [];

      for (int i = 0; i < jumlahHari; i++) {
        if (i < dates.length &&
            dates[i] != null &&
            dates[i].toString().isNotEmpty) {
          hasil.add(formatTanggal(dates[i].toString()));
        }
      }

      return hasil;
    } catch (e) {
      print('Error getTanggalLks: $e');
      return [];
    }
  }

  Widget _absenCard(dynamic item) {
    final nama = namaKaryawan(item);
    final jenis = value(item['jenis_absen']);
    final jenisText = jenisAbsen(jenis);
    final status = value(item['status']);

    final durasi = value(item['durasi']);
    final keperluan = value(item['keperluan']);

    final tanggalLks = getTanggalLks(item['tanggal'], item['durasi']);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        _showDetailAbsen(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8ECF2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF1976D2),
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF172B4D),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: jenisColor(jenis).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              jenisIcon(jenis),
                              size: 14,
                              color: jenisColor(jenis),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              jenisText,
                              style: TextStyle(
                                color: jenisColor(jenis),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _statusBadge(selectedStatus: '', onChanged: (String? value) {}),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
                  if (tanggalLks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.date_range_rounded,
                                  size: 18,
                                  color: Color(0xFF1976D2),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tanggal Izin',
                                  style: TextStyle(
                                    color: Color(0xFF172B4D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(tanggalLks.length, (
                                index,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F1FF),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    'Tanggal : ${tanggalLks[index]}',
                                    style: const TextStyle(
                                      color: Color(0xFF1976D2),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 13),

                  Row(
                    children: [
                      Expanded(
                        child: _info(
                          Icons.timelapse_outlined,
                          'Durasi',
                          '$durasi Hari',
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 35,
                        color: const Color(0xFFE2E8F0),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: _info(
                            Icons.verified_outlined,
                            'Status',
                            status,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (keperluan != '-')
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes_rounded,
                      size: 18,
                      color: Color(0xFF7A869A),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        keperluan,
                        style: const TextStyle(
                          color: Color(0xFF52606D),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetailAbsen(dynamic item) {
    final nama = namaKaryawan(item);

    final jenis = value(item['jenis_absen']);
    final jenisText = jenisAbsen(jenis);

    final durasi = value(item['durasi']);
    final keperluan = value(item['keperluan']);

    // =========================
    // NORMALISASI STATUS
    // =========================
    final statusData = item['status'];

    String statusAwal;

    final statusValue = statusData?.toString().trim().toUpperCase();

    if (statusValue == '1' || statusValue == 'DISETUJUI') {
      statusAwal = 'Disetujui';
    } else if (statusValue == '2' || statusValue == 'DITOLAK') {
      statusAwal = 'Ditolak';
    } else {
      statusAwal = 'Menunggu';
    }

    // =========================
    // JABATAN
    // =========================
    final jabatan = value(item['karyawan']?['jabatan']?['nama_jabatan']);

    // =========================
    // TANGGAL
    // =========================
    final tanggalLks = getTanggalLks(item['tanggal'], item['durasi']);

    // =========================
    // BOTTOM SHEET
    // =========================
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // State khusus untuk BottomSheet
        String selectedStatus = statusAwal;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =========================
                      // HANDLE
                      // =========================
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9DEE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =========================
                      // HEADER
                      // =========================
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF1976D2),
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: const TextStyle(
                                    color: Color(0xFF172B4D),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                if (jabatan != '-')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      jabatan,
                                      style: const TextStyle(
                                        color: Color(0xFF7A869A),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // =========================
                      // JENIS ABSEN
                      // =========================
                      _detailItem(
                        Icons.category_outlined,
                        'Jenis Izin',
                        jenisText,
                      ),

                      const Divider(height: 25),

                      // =========================
                      // TANGGAL
                      // =========================
                      if (tanggalLks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.date_range_rounded,
                                      size: 18,
                                      color: Color(0xFF1976D2),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Tanggal Absensi',
                                      style: TextStyle(
                                        color: Color(0xFF172B4D),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(tanggalLks.length, (
                                    index,
                                  ) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F1FF),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Text(
                                        'Tanggal : ${tanggalLks[index]}',
                                        style: const TextStyle(
                                          color: Color(0xFF1976D2),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const Divider(height: 25),

                      // =========================
                      // DURASI
                      // =========================
                      _detailItem(
                        Icons.timelapse_outlined,
                        'Durasi',
                        '$durasi Hari',
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // STATUS
                      // =========================
                      _detailItem(
                        Icons.verified_outlined,
                        'Status Persetujuan',
                        selectedStatus,
                        valueWidget: _statusBadge(
                          selectedStatus: selectedStatus,
                          onChanged: (value) {
                            if (value == null) return;

                            // INI YANG MEMBUAT DROPDOWN REBUILD
                            setSheetState(() {
                              selectedStatus = value;
                            });

                            print('Status baru: $selectedStatus');
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // KEPERLUAN
                      // =========================
                      const Text(
                        'Keperluan',
                        style: TextStyle(
                          color: Color(0xFF7A869A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          keperluan == '-' ? 'Tidak ada keterangan' : keperluan,
                          style: const TextStyle(
                            color: Color(0xFF52606D),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =========================
                      // TOMBOL TUTUP
                      // =========================
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            //  Navigator.pop(context);

                            updatePersetujuanAbsen(
                              id: item['id'],
                              status: selectedStatus,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailItem(
    IconData icon,
    String label,
    String value, {
    Widget? valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1976D2), size: 19),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7A869A),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              valueWidget ??
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF172B4D),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // STATUS
  // =========================================================
  String _selectedStatus = 'Menunggu';
  Widget _statusBadge({
    required String selectedStatus,
    required ValueChanged<String?> onChanged,
  }) {
    // Pastikan value selalu cocok dengan DropdownMenuItem
    final safeStatus =
        const ['Menunggu', 'DISETUJUI', 'Ditolak'].contains(selectedStatus)
        ? selectedStatus
        : 'Menunggu';

    Color color;

    if (safeStatus == 'DISETUJUI') {
      color = Colors.green;
    } else if (safeStatus == 'Ditolak') {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeStatus,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: color),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          dropdownColor: Colors.white,

          items: const [
            DropdownMenuItem(
              value: 'Menunggu',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.orange),
                  SizedBox(width: 5),
                  Text('Menunggu'),
                ],
              ),
            ),

            DropdownMenuItem(
              value: 'DISETUJUI',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: Colors.green,
                  ),
                  SizedBox(width: 5),
                  Text('DISETUJUI'),
                ],
              ),
            ),

            DropdownMenuItem(
              value: 'Ditolak',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
                  SizedBox(width: 5),
                  Text('Ditolak'),
                ],
              ),
            ),
          ],

          onChanged: onChanged,
        ),
      ),
    );
  }
  // =========================================================
  // INFO
  // =========================================================

  Widget _info(IconData icon, String title, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 17, color: const Color(0xFF1976D2)),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              ),

              const SizedBox(height: 2),

              Text(
                text,

                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _emptyData() {
    return RefreshIndicator(
      onRefresh: getKaryawanAbsen,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),

          Center(
            child: Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(22),
              ),

              child: const Icon(
                Icons.event_busy_outlined,
                color: Color(0xFF1976D2),
                size: 40,
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              'Belum Ada Data',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Center(
            child: Text(
              'Data absensi karyawan belum tersedia.',
              style: TextStyle(color: Color(0xFF7A869A), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
