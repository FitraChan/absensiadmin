import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:absensiadmin/karyawan/model/karyawan_model.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {
  bool loading = true;

  List<Lembur> dataLembur = [];

  String keyword = '';

  @override
  void initState() {
    super.initState();
    getLembur();
    getKaryawan();
  }

  // =========================================================
  // GET DATA LEMBUR
  // =========================================================

  Future<void> getLembur() async {
    try {
      setState(() {
        loading = true;
      });

      final response = await Network().getData('lembur');

      debugPrint('STATUS LEMBUR: ${response.statusCode}');
      debugPrint('BODY LEMBUR: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        dynamic data;

        if (body is List) {
          data = body;
        } else if (body is Map) {
          data = body['data'];
        }

        if (data is List) {
          dataLembur = data
              .map((e) => Lembur.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          dataLembur = [];
        }
      } else {
        throw Exception('Gagal mengambil data. Status ${response.body}');
      }
    } catch (e) {
      debugPrint('ERROR GET LEMBUR: $e');

      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text: 'Gagal mengambil data lembur.',
          confirmBtnText: 'OK',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // =========================================================
  // FILTER
  // =========================================================

  List<Lembur> get filteredLembur {
    if (keyword.trim().isEmpty) {
      return dataLembur;
    }

    final key = keyword.toLowerCase();

    return dataLembur.where((item) {
      return item.namaKaryawan.toLowerCase().contains(key) ||
          item.keterangan.toLowerCase().contains(key) ||
          item.statusText.toLowerCase().contains(key);
    }).toList();
  }

  // =========================================================
  // TAMBAH LEMBUR
  // =========================================================

  void showTambahLembur() {
    final formKey = GlobalKey<FormState>();

    int? selectedKaryawan;

    final durasiController = TextEditingController();
    final keteranganController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.more_time_rounded,
                              color: Color(0xFF1976D2),
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Text(
                              'Tambah Data Lembur',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF172033),
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              // Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // KARYAWAN
                      const Text(
                        'Nama Karyawan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<int>(
                        value: selectedKaryawan,
                        isExpanded: true,

                        decoration: InputDecoration(
                          hintText: '-- Pilih Karyawan --',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),

                        items: dataKaryawan.map((e) => e.id).toSet().map((id) {
                          final item = dataKaryawan.firstWhere(
                            (e) => e.id == id,
                          );

                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(item.nama),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setModalState(() {
                            selectedKaryawan = value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Pilih karyawan terlebih dahulu';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // DURASI
                      const Text(
                        'Durasi (Jam)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: durasiController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: 2',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          suffixText: 'Jam',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Durasi wajib diisi';
                          }

                          if (double.tryParse(value) == null) {
                            return 'Durasi tidak valid';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // KETERANGAN
                      const Text(
                        'Keterangan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: keteranganController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Masukkan keterangan lembur',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Keterangan wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // SIMPAN
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            // TODO:
                            // Panggil API store lembur di sini.

                            // Navigator.pop(context);

                            tambahLembur(
                              karyawanId: selectedKaryawan ?? 0,
                              durasi: durasiController.text.isNotEmpty
                                  ? double.tryParse(durasiController.text) ?? 0
                                  : 0,
                              keterangan: keteranganController.text.trim(),
                            );

                            QuickAlert.show(
                              context: this.context,
                              type: QuickAlertType.success,
                              title: 'Berhasil',
                              text: 'Data lembur berhasil disimpan.',
                              confirmBtnText: 'OK',
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          child: const Text(
                            'Simpan Data Lembur',
                            style: TextStyle(fontWeight: FontWeight.bold),
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

  List<Karyawan> dataKaryawan = [];

  int? selectedKaryawan;

  Future<void> getKaryawan() async {
    try {
      final response = await Network().getData('getKaryawan');

      print('STATUS KARYAWAN: ${response.statusCode}');
      print('RESPONSE KARYAWAN: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final List data = body['data'] ?? [];

          setState(() {
            dataKaryawan = data.map((e) => Karyawan.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      print('ERROR GET KARYAWAN: $e');
    }
  }

  // =========================================================
  // DETAIL / APPROVAL
  // =========================================================

  void showDetailLembur(Lembur item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.more_time_rounded,
                        color: Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'Detail Lembur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172033),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _detailItem('Nama Karyawan', item.namaKaryawan),

                _detailItem('Jabatan', item.jabatan),

                _detailItem('Durasi', '${item.durasi} Jam'),

                _detailItem('Tanggal Pengajuan', item.tanggalPengajuan),

                _detailItem('Keterangan', item.keterangan),

                const SizedBox(height: 12),

                _statusBadge(item),

                const SizedBox(height: 20),

                if (item.stsPengajuan == 0)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            updateStatusLembur(item, 2);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Tolak',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            updateStatusLembur(item, 1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Setujui',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> tambahLembur({
    required int karyawanId,
    required double durasi,
    required String keterangan,
  }) async {
    Map<String, dynamic> data = {
      'karyawan_id': karyawanId,
      'durasi': durasi,
      'keterangan': keterangan,
    };

    try {
      // =========================
      // LOADING
      // =========================
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Menyimpan...',
        text: 'Sedang menyimpan pengajuan lembur.',
        barrierDismissible: false,
      );

      final response = await Network().getData_post(data, 'lembur/store');

      print('STATUS TAMBAH LEMBUR: ${response.statusCode}');
      print('RESPONSE TAMBAH LEMBUR: ${response.body}');

      final body = jsonDecode(response.body);

      print(response.body);

      // =========================
      // TUTUP LOADING
      // =========================
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // =========================
      // BERHASIL
      // =========================
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body['success'] == true) {
          if (!context.mounted) return true;

          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Berhasil',
            text: body['message'] ?? 'Pengajuan lembur berhasil ditambahkan.',
          );

          return true;
        }
      }

      // =========================
      // GAGAL
      // =========================
      if (context.mounted) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text: body['message'] ?? 'Pengajuan lembur gagal ditambahkan.',
        );
      }

      return false;
    } catch (e) {
      print('ERROR TAMBAH LEMBUR: $e');

      // Tutup loading jika masih terbuka
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Tampilkan error
      if (context.mounted) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Terjadi kesalahan: $e',
        );
      }

      return false;
    }
  }

  // =========================================================
  // UPDATE STATUS
  // =========================================================

  Future<void> updateStatusLembur(Lembur item, int status) async {
    // TODO:
    //
    // status = 1 => DISETUJUI
    // status = 2 => DITOLAK
    //
    // Panggil API Laravel:
    //
    // lembur/${item.id}
    //
    // method PUT

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Memproses...',
      text: 'Sedang mengubah status lembur.',
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.pop(context);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Berhasil',
      text: status == 1
          ? 'Pengajuan lembur disetujui.'
          : 'Pengajuan lembur ditolak.',
      confirmBtnText: 'OK',
    );

    getLembur();
  }

  // =========================================================
  // DETAIL ITEM
  // =========================================================

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),

          const SizedBox(height: 4),

          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF172033),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS
  // =========================================================

  Widget _statusBadge(Lembur item) {
    Color background;
    Color text;
    IconData icon;

    if (item.stsPengajuan == 0) {
      background = const Color(0xFFFFF7ED);
      text = const Color(0xFFC2410C);
      icon = Icons.access_time_rounded;
    } else if (item.stsPengajuan == 1) {
      background = const Color(0xFFECFDF3);
      text = const Color(0xFF15803D);
      icon = Icons.check_circle_outline_rounded;
    } else {
      background = const Color(0xFFFEF2F2);
      text = const Color(0xFFDC2626);
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: text),

          const SizedBox(width: 7),

          Text(
            item.statusText,
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CARD
  // =========================================================

  Widget _buildLemburCard(Lembur item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDetailLembur(item);
        },
        borderRadius: BorderRadius.circular(16),

        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAF2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172033).withOpacity(0.035),
                blurRadius: 12,
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
                child: const Icon(
                  Icons.more_time_rounded,
                  color: Color(0xFF1976D2),
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaKaryawan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${item.durasi} Jam • ${item.tanggalPengajuan}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 7),

                    _statusBadge(item),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final list = filteredLembur;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: const Color(0xFF172033),

        title: const Text(
          'Data Lembur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: getLembur,
            icon: const Icon(Icons.refresh_rounded),
          ),

          const SizedBox(width: 6),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showTambahLembur,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: getLembur,

        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1976D2)),
              )
            : Column(
                children: [
                  // SEARCH
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          keyword = value;
                        });
                      },

                      decoration: InputDecoration(
                        hintText: 'Cari nama karyawan...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                        ),

                        suffixIcon: keyword.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    keyword = '';
                                  });
                                },
                                icon: const Icon(Icons.close_rounded),
                              )
                            : null,

                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5EAF2),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // LIST
                  Expanded(
                    child: list.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),

                              Center(
                                child: Icon(
                                  Icons.more_time_rounded,
                                  size: 60,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),

                              SizedBox(height: 12),

                              Center(
                                child: Text(
                                  'Belum ada data lembur',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),

                            physics: const AlwaysScrollableScrollPhysics(),

                            itemCount: list.length,

                            separatorBuilder: (_, __) {
                              return const SizedBox(height: 10);
                            },

                            itemBuilder: (context, index) {
                              return _buildLemburCard(list[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

// =============================================================
// MODEL
// =============================================================

class Lembur {
  final int id;
  final int karyawanId;

  final String namaKaryawan;
  final String jabatan;

  final double durasi;

  final String tanggalPengajuan;
  final String keterangan;

  final int stsPengajuan;

  Lembur({
    required this.id,
    required this.karyawanId,
    required this.namaKaryawan,
    required this.jabatan,
    required this.durasi,
    required this.tanggalPengajuan,
    required this.keterangan,
    required this.stsPengajuan,
  });

  factory Lembur.fromJson(Map<String, dynamic> json) {
    final karyawan = json['karyawan'] is Map
        ? Map<String, dynamic>.from(json['karyawan'])
        : <String, dynamic>{};

    final jabatan = karyawan['jabatan'] is Map
        ? Map<String, dynamic>.from(karyawan['jabatan'])
        : <String, dynamic>{};

    return Lembur(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,

      karyawanId:
          int.tryParse('${json['karyawan_id'] ?? karyawan['id'] ?? 0}') ?? 0,

      namaKaryawan: karyawan['nama_lengkap'] ?? json['nama_lengkap'] ?? '-',

      jabatan: jabatan['nama_jabatan'] ?? json['nama_jabatan'] ?? '-',

      durasi: double.tryParse('${json['durasi'] ?? 0}') ?? 0,

      tanggalPengajuan: json['tgl_pengajuan'] ?? '-',

      keterangan: json['keterangan'] ?? '-',

      stsPengajuan: int.tryParse('${json['sts_pengajuan'] ?? 0}') ?? 0,
    );
  }

  String get statusText {
    if (stsPengajuan == 0) {
      return 'Menunggu Konfirmasi';
    }

    if (stsPengajuan == 1) {
      return 'Diterima';
    }

    return 'Ditolak';
  }
}
