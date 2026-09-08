import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodeGajiPage extends StatefulWidget {
  const PeriodeGajiPage({super.key});

  @override
  State<PeriodeGajiPage> createState() => _PeriodeGajiPageState();
}

class _PeriodeGajiPageState extends State<PeriodeGajiPage> {
  final Network network = Network();

  List<dynamic> dataPeriodeGaji = [];

  bool isLoading = false;
  bool isSaving = false;

  final TextEditingController searchController = TextEditingController();

  // ============================================================
  // FORMAT TANGGAL
  // ============================================================

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String formatDateDisplay(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value.toString());

      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return value.toString();
    }
  }

  // ============================================================
  // GET DATA
  // ============================================================

  Future<void> getPeriodeGaji() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      String url = 'periode-gaji';

      final search = searchController.text.trim();

      if (search.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(search)}';
      }

      print('================================');
      print('GET PERIODE GAJI');
      print('URL: $url');
      print('================================');

      final response = await network.getData(url);

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final data = body['data'];

          // Laravel paginate()
          if (data is Map && data['data'] is List) {
            setState(() {
              dataPeriodeGaji = List<dynamic>.from(data['data']);
            });
          }
          // Kalau API mengembalikan List langsung
          else if (data is List) {
            setState(() {
              dataPeriodeGaji = List<dynamic>.from(data);
            });
          } else {
            setState(() {
              dataPeriodeGaji = [];
            });
          }
        } else {
          setState(() {
            dataPeriodeGaji = [];
          });

          _showMessage(
            body['message']?.toString() ?? 'Gagal mengambil data periode gaji.',
            Colors.red,
          );
        }
      } else {
        setState(() {
          dataPeriodeGaji = [];
        });

        _showMessage(
          'Gagal mengambil data periode gaji. '
          'Status: ${response.statusCode}',
          Colors.red,
        );
      }
    } catch (e) {
      print('ERROR GET PERIODE GAJI: $e');

      if (mounted) {
        _showMessage('Terjadi kesalahan: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // TAMBAH DATA
  // ============================================================

  Future<void> tambahPeriodeGaji({
    required String namaPeriode,
    required String mulai,
    required String selesai,
    String? tglCetak,
  }) async {
    setState(() {
      isSaving = true;
    });

    try {
      final data = {
        'nama_periode': namaPeriode,
        'mulai': mulai,
        'selesai': selesai,
        'tgl_cetak': tglCetak,
      };

      print('================================');
      print('POST PERIODE GAJI');
      print('DATA: $data');
      print('================================');

      final response = await network.getData_post(data, 'periode-gaji');

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        if (mounted) {
          Navigator.pop(context);

          _showMessage(
            body['message']?.toString() ?? 'Periode gaji berhasil ditambahkan.',
            Colors.green,
          );
        }

        await getPeriodeGaji();
      } else {
        if (mounted) {
          _showMessage(
            body['message']?.toString() ?? 'Gagal menambahkan periode gaji.',
            Colors.red,
          );
        }
      }
    } catch (e) {
      print('ERROR TAMBAH PERIODE GAJI: $e');

      if (mounted) {
        _showMessage('Terjadi kesalahan: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // UPDATE DATA
  // ============================================================

  Future<void> updatePeriodeGaji({
    required dynamic id,
    required String namaPeriode,
    required String mulai,
    required String selesai,
    String? tglCetak,
  }) async {
    setState(() {
      isSaving = true;
    });

    try {
      final data = {
        'nama_periode': namaPeriode,
        'mulai': mulai,
        'selesai': selesai,
        'tgl_cetak': tglCetak,
      };

      print('================================');
      print('PUT PERIODE GAJI');
      print('ID: $id');
      print('DATA: $data');
      print('================================');

      final response = await network.putData(data, 'periode-gaji/$id');

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        if (mounted) {
          Navigator.pop(context);

          _showMessage(
            body['message']?.toString() ?? 'Periode gaji berhasil diperbarui.',
            Colors.green,
          );
        }

        await getPeriodeGaji();
      } else {
        if (mounted) {
          _showMessage(
            body['message']?.toString() ?? 'Gagal memperbarui periode gaji.',
            Colors.red,
          );
        }
      }
    } catch (e) {
      print('ERROR UPDATE PERIODE GAJI: $e');

      if (mounted) {
        _showMessage('Terjadi kesalahan: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // DELETE DATA
  // ============================================================

  Future<void> deletePeriodeGaji(dynamic id) async {
    try {
      final response = await network.deleteData('periode-gaji/$id');

      print('================================');
      print('DELETE PERIODE GAJI');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('================================');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        // ==========================================
        // HAPUS DARI LIST SEMENTARA
        // ==========================================

        setState(() {
          dataPeriodeGaji.removeWhere(
            (item) => item['id'].toString() == id.toString(),
          );
        });

        _showMessage(
          body['message']?.toString() ?? 'Periode gaji berhasil dihapus.',
          Colors.green,
        );

        // ==========================================
        // RELOAD DATA DARI SERVER
        // ==========================================

        await getPeriodeGaji();
      } else {
        _showMessage(
          body['message']?.toString() ?? 'Gagal menghapus periode gaji.',
          Colors.red,
        );
      }
    } catch (e) {
      print('ERROR DELETE PERIODE GAJI: $e');

      _showMessage('Terjadi kesalahan: $e', Colors.red);
    }
  }

  // ============================================================
  // FORM TAMBAH / EDIT
  // ============================================================

  void showFormPeriodeGaji({dynamic data}) {
    final bool isEdit = data != null;

    final TextEditingController namaController = TextEditingController(
      text: isEdit ? data['nama_periode']?.toString() ?? '' : '',
    );

    DateTime? tanggalMulai;
    DateTime? tanggalSelesai;
    DateTime? tanggalCetak;

    if (isEdit) {
      try {
        if (data['mulai'] != null) {
          tanggalMulai = DateTime.parse(data['mulai'].toString());
        }

        if (data['selesai'] != null) {
          tanggalSelesai = DateTime.parse(data['selesai'].toString());
        }

        if (data['tgl_cetak'] != null &&
            data['tgl_cetak'].toString().isNotEmpty) {
          tanggalCetak = DateTime.parse(data['tgl_cetak'].toString());
        }
      } catch (e) {
        print('ERROR PARSE DATE: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pilihTanggal({
              required DateTime? tanggal,
              required Function(DateTime) onSelected,
            }) async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: tanggal ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setModalState(() {
                  onSelected(picked);
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 700),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // HEADER
                      // ==================================================

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.payments_outlined,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              isEdit
                                  ? 'Edit Periode Gaji'
                                  : 'Tambah Periode Gaji',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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

                      // ==================================================
                      // NAMA PERIODE
                      // ==================================================
                      TextField(
                        controller: namaController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Nama Periode',
                          hintText: 'Contoh: September 2026',
                          prefixIcon: const Icon(Icons.title_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // TANGGAL MULAI
                      // ==================================================
                      _dateField(
                        label: 'Tanggal Mulai',
                        value: tanggalMulai,
                        onTap: () {
                          pilihTanggal(
                            tanggal: tanggalMulai,
                            onSelected: (date) {
                              tanggalMulai = date;
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // TANGGAL SELESAI
                      // ==================================================
                      _dateField(
                        label: 'Tanggal Selesai',
                        value: tanggalSelesai,
                        onTap: () {
                          pilihTanggal(
                            tanggal: tanggalSelesai,
                            onSelected: (date) {
                              tanggalSelesai = date;
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // TANGGAL CETAK
                      // ==================================================
                      _dateField(
                        label: 'Tanggal Cetak (Opsional)',
                        value: tanggalCetak,
                        onTap: () {
                          pilihTanggal(
                            tanggal: tanggalCetak,
                            onSelected: (date) {
                              tanggalCetak = date;
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // BUTTON
                      // ==================================================
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final nama = namaController.text.trim();

                                  if (nama.isEmpty) {
                                    _showMessage(
                                      'Nama periode wajib diisi.',
                                      Colors.red,
                                    );
                                    return;
                                  }

                                  if (tanggalMulai == null) {
                                    _showMessage(
                                      'Tanggal mulai wajib dipilih.',
                                      Colors.red,
                                    );
                                    return;
                                  }

                                  if (tanggalSelesai == null) {
                                    _showMessage(
                                      'Tanggal selesai wajib dipilih.',
                                      Colors.red,
                                    );
                                    return;
                                  }

                                  // Validasi tanggal
                                  if (tanggalSelesai!.isBefore(tanggalMulai!)) {
                                    _showMessage(
                                      'Tanggal selesai tidak boleh sebelum tanggal mulai.',
                                      Colors.red,
                                    );
                                    return;
                                  }

                                  final mulai = formatDate(tanggalMulai!);

                                  final selesai = formatDate(tanggalSelesai!);

                                  final tglCetak = tanggalCetak != null
                                      ? formatDate(tanggalCetak!)
                                      : null;

                                  if (isEdit) {
                                    await updatePeriodeGaji(
                                      id: data['id'],
                                      namaPeriode: nama,
                                      mulai: mulai,
                                      selesai: selesai,
                                      tglCetak: tglCetak,
                                    );
                                  } else {
                                    await tambahPeriodeGaji(
                                      namaPeriode: nama,
                                      mulai: mulai,
                                      selesai: selesai,
                                      tglCetak: tglCetak,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isEdit ? 'Simpan Perubahan' : 'Simpan',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          value != null
              ? DateFormat('dd/MM/yyyy').format(value)
              : 'Pilih tanggal',
          style: TextStyle(
            fontSize: 15,
            color: value != null ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  void confirmDelete(dynamic data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Periode Gaji?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus '
            'periode "${data['nama_periode']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await deletePeriodeGaji(data['id']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    getPeriodeGaji();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Periode Gaji',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : getPeriodeGaji,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // ==========================================================
      // FAB
      // ==========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showFormPeriodeGaji();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: RefreshIndicator(
        onRefresh: getPeriodeGaji,

        child: Column(
          children: [
            // ======================================================
            // SEARCH
            // ======================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: TextField(
                controller: searchController,
                onSubmitted: (_) {
                  getPeriodeGaji();
                },
                decoration: InputDecoration(
                  hintText: 'Cari periode gaji...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();

                            setState(() {});

                            getPeriodeGaji();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ======================================================
            // DATA
            // ======================================================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dataPeriodeGaji.isEmpty
                  ? _emptyData()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: dataPeriodeGaji.length,
                      itemBuilder: (context, index) {
                        final item = dataPeriodeGaji[index];

                        return _periodeCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _periodeCard(dynamic item) {
    final nama = item['nama_periode']?.toString() ?? '-';

    final mulai = item['mulai'];

    final selesai = item['selesai'];

    final tglCetak = item['tgl_cetak'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${item['id'] ?? '-'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      showFormPeriodeGaji(data: item);
                    }

                    if (value == 'delete') {
                      confirmDelete(item);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(height: 1),

            const SizedBox(height: 14),

            // ==================================================
            // PERIODE
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Mulai',
                    value: formatDateDisplay(mulai),
                  ),
                ),

                Expanded(
                  child: _infoItem(
                    icon: Icons.event_outlined,
                    title: 'Selesai',
                    value: formatDateDisplay(selesai),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==================================================
            // TGL CETAK
            // ==================================================
            _infoItem(
              icon: Icons.print_outlined,
              title: 'Tanggal Cetak',
              value: formatDateDisplay(tglCetak),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
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

  // ============================================================
  // EMPTY DATA
  // ============================================================

  Widget _emptyData() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 70,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada periode gaji',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Silakan tambahkan periode gaji.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
