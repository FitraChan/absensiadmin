import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:flutter/material.dart';

class JamKerjaPage extends StatefulWidget {
  const JamKerjaPage({super.key});

  @override
  State<JamKerjaPage> createState() => _JamKerjaPageState();
}

class _JamKerjaPageState extends State<JamKerjaPage> {
  final Network network = Network();

  List<dynamic> dataJamKerja = [];

  bool isLoading = false;
  bool isSaving = false;

  String search = '';

  @override
  void initState() {
    super.initState();
    getJamKerja();
  }

  // ============================================================
  // GET DATA
  // ============================================================

  Future<void> getJamKerja() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('================================');
      print('MULAI GET JAM KERJA');
      print('URL: https://absensiapi.mbcconsulting.id/api/jam-kerja');
      print('================================');

      final response = await network.getData('jam-kerja');

      print('================================');
      print('REQUEST BERHASIL');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final data = body['data'];

          if (data is Map && data['data'] is List) {
            setState(() {
              dataJamKerja = List<dynamic>.from(data['data']);
            });
          } else if (data is List) {
            setState(() {
              dataJamKerja = List<dynamic>.from(data);
            });
          } else {
            setState(() {
              dataJamKerja = [];
            });
          }
        }
      } else {
        print('HTTP ERROR: ${response.statusCode}');
        print('BODY: ${response.body}');

        setState(() {
          dataJamKerja = [];
        });

        _showMessage(
          'Gagal mengambil data (${response.statusCode})',
          Colors.red,
        );
      }
    } catch (e, stackTrace) {
      print('================================');
      print('ERROR GET JAM KERJA');
      print('ERROR TYPE: ${e.runtimeType}');
      print('ERROR: $e');
      print('STACK TRACE:');
      print(stackTrace);
      print('================================');

      if (mounted) {
        _showMessage('Terjadi kesalahan koneksi.', Colors.red);
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
  // TAMBAH JAM KERJA
  // ============================================================

  Future<void> tambahJamKerja({
    required String namaShift,
    required String waktuMulai,
    required String waktuAkhir,
  }) async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final response = await network.getData_post({
        'nama_shift': namaShift,
        'waktu_mulai': waktuMulai,
        'waktu_akhir': waktuAkhir,
      }, 'jam-kerja');

      print('================================');
      print('TAMBAH JAM KERJA');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('================================');

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        if (!mounted) return;

        Navigator.pop(context);

        _showMessage(
          body['message']?.toString() ?? 'Jam kerja berhasil ditambahkan.',
          Colors.green,
        );

        await getJamKerja();
      } else {
        if (!mounted) return;

        _showMessage(
          body['message']?.toString() ?? 'Gagal menambahkan jam kerja.',
          Colors.red,
        );
      }
    } catch (e) {
      print('ERROR TAMBAH JAM KERJA: $e');

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
  // UPDATE JAM KERJA
  // ============================================================

  Future<void> updateJamKerja({
    required int id,
    required String namaShift,
    required String waktuMulai,
    required String waktuAkhir,
  }) async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final response = await network.putData({
        'nama_shift': namaShift,
        'waktu_mulai': waktuMulai,
        'waktu_akhir': waktuAkhir,
      }, 'jam-kerja/$id');

      print('================================');
      print('UPDATE JAM KERJA');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('================================');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        if (!mounted) return;

        Navigator.pop(context);

        _showMessage(
          body['message']?.toString() ?? 'Jam kerja berhasil diperbarui.',
          Colors.green,
        );

        await getJamKerja();
      } else {
        if (!mounted) return;

        _showMessage(
          body['message']?.toString() ?? 'Gagal memperbarui jam kerja.',
          Colors.red,
        );
      }
    } catch (e) {
      print('ERROR UPDATE JAM KERJA: $e');

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
  // DELETE JAM KERJA
  // ============================================================

  Future<void> deleteJamKerja(dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Jam Kerja'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus jam kerja ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    _showLoadingDialog('Menghapus jam kerja...');

    try {
      final response = await network.deleteData('jam-kerja/$id');

      if (mounted) {
        Navigator.pop(context);
      }

      print('================================');
      print('DELETE JAM KERJA');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('================================');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        _showMessage(
          body['message']?.toString() ?? 'Jam kerja berhasil dihapus.',
          Colors.green,
        );

        await getJamKerja();
      } else {
        _showMessage(
          body['message']?.toString() ?? 'Jam kerja tidak dapat dihapus.',
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }

      print('ERROR DELETE JAM KERJA: $e');

      _showMessage('Terjadi kesalahan: $e', Colors.red);
    }
  }

  // ============================================================
  // FORM TAMBAH / EDIT
  // ============================================================

  void showFormJamKerja({Map<String, dynamic>? data}) {
    final bool isEdit = data != null;

    final namaController = TextEditingController(
      text: data?['nama_shift']?.toString() ?? '',
    );

    final mulaiController = TextEditingController(
      text: data?['waktu_mulai']?.toString() ?? '',
    );

    final akhirController = TextEditingController(
      text: data?['waktu_akhir']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool loading = false;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Jam Kerja' : 'Tambah Jam Kerja'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ============================
                    // NAMA SHIFT
                    // ============================

                    TextField(
                      controller: namaController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama Shift',
                        hintText: 'Contoh: Shift Pagi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ============================
                    // WAKTU MULAI
                    // ============================
                    TextField(
                      controller: mulaiController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Waktu Mulai',
                        hintText: '08:00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.login_outlined),
                      ),
                      onTap: () async {
                        final selected = await showTimePicker(
                          context: context,
                          initialTime: _parseTime(mulaiController.text),
                        );

                        if (selected != null) {
                          dialogSetState(() {
                            mulaiController.text = _formatTime(selected);
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // ============================
                    // WAKTU AKHIR
                    // ============================
                    TextField(
                      controller: akhirController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Waktu Akhir',
                        hintText: '17:00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.logout_outlined),
                      ),
                      onTap: () async {
                        final selected = await showTimePicker(
                          context: context,
                          initialTime: _parseTime(akhirController.text),
                        );

                        if (selected != null) {
                          dialogSetState(() {
                            akhirController.text = _formatTime(selected);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          // ============================
                          // VALIDASI
                          // ============================

                          if (namaController.text.trim().isEmpty) {
                            _showMessage('Nama shift wajib diisi.', Colors.red);
                            return;
                          }

                          if (mulaiController.text.trim().isEmpty) {
                            _showMessage(
                              'Waktu mulai wajib diisi.',
                              Colors.red,
                            );
                            return;
                          }

                          if (akhirController.text.trim().isEmpty) {
                            _showMessage(
                              'Waktu akhir wajib diisi.',
                              Colors.red,
                            );
                            return;
                          }

                          dialogSetState(() {
                            loading = true;
                          });

                          if (isEdit) {
                            await updateJamKerja(
                              id: int.parse(data['id'].toString()),
                              namaShift: namaController.text.trim(),
                              waktuMulai: mulaiController.text.trim(),
                              waktuAkhir: akhirController.text.trim(),
                            );
                          } else {
                            await tambahJamKerja(
                              namaShift: namaController.text.trim(),
                              waktuMulai: mulaiController.text.trim(),
                              waktuAkhir: akhirController.text.trim(),
                            );
                          }

                          if (mounted) {
                            dialogSetState(() {
                              loading = false;
                            });
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TIME
  // ============================================================

  TimeOfDay _parseTime(String value) {
    if (value.isEmpty) {
      return const TimeOfDay(hour: 8, minute: 0);
    }

    try {
      final parts = value.split(':');

      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // ============================================================
  // LOADING DIALOG
  // ============================================================

  void _showLoadingDialog(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(text)),
            ],
          ),
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
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _jamKerjaCard(Map<String, dynamic> data) {
    final id = data['id'];

    final namaShift = data['nama_shift']?.toString() ?? '-';

    final waktuMulai = data['waktu_mulai']?.toString() ?? '-';

    final waktuAkhir = data['waktu_akhir']?.toString() ?? '-';

    final jumlahKaryawan = data['jadwal_karyawan_count'] ?? 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================
            // HEADER
            // ============================

            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  child: const Icon(Icons.schedule, size: 28),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaShift,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'ID: $id',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      showFormJamKerja(data: data);
                    }

                    if (value == 'delete') {
                      deleteJamKerja(id);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),

                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            // ============================
            // JAM KERJA
            // ============================
            Row(
              children: [
                Expanded(
                  child: _timeBox(
                    icon: Icons.login_outlined,
                    label: 'Mulai',
                    value: waktuMulai,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _timeBox(
                    icon: Icons.logout_outlined,
                    label: 'Selesai',
                    value: waktuAkhir,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ============================
            // JUMLAH KARYAWAN
            // ============================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, size: 20),

                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIME BOX
  // ============================================================

  Widget _timeBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
  // EMPTY
  // ============================================================

  Widget _emptyData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'Belum ada jam kerja',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Silakan tambahkan shift atau jam kerja.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jam Kerja')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showFormJamKerja();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),

      body: Column(
        children: [
          // ============================
          // SEARCH
          // ============================

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama shift...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            search = '';
                          });

                          getJamKerja();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                search = value;
              },
              onSubmitted: (value) {
                getJamKerja();
              },
            ),
          ),

          // ============================
          // DATA
          // ============================
          Expanded(
            child: RefreshIndicator(
              onRefresh: getJamKerja,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dataJamKerja.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: _emptyData(),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: dataJamKerja.length,
                      itemBuilder: (context, index) {
                        final item = dataJamKerja[index];

                        return _jamKerjaCard(Map<String, dynamic>.from(item));
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
