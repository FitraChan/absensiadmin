import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:absensiadmin/groupjadwal/detail_group_jadwal.dart';
import 'package:absensiadmin/groupjadwal/groupjadwal_model.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class GroupJadwalPage extends StatefulWidget {
  const GroupJadwalPage({super.key});

  @override
  State<GroupJadwalPage> createState() => _GroupJadwalPageState();
}

class _GroupJadwalPageState extends State<GroupJadwalPage> {
  final Network network = Network();

  List<GroupJadwal> dataGroup = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getGroupJadwal();
  }

  // =========================================================
  // GET DATA
  // =========================================================

  Future<void> getGroupJadwal() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await network.getData('groupJadwal');

      print('====================================');
      print('GET GROUP JADWAL');
      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.body}');
      print('====================================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final data = body['data'];

          if (data is List) {
            dataGroup = data
                .map<GroupJadwal>((item) => GroupJadwal.fromJson(item))
                .toList();
          } else {
            dataGroup = [];
          }
        } else {
          dataGroup = [];
        }
      } else {
        _showError('Gagal mengambil data (${response.statusCode})');
      }
    } catch (e) {
      print('ERROR GET GROUP JADWAL: $e');

      _showError('Terjadi kesalahan saat mengambil data.');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================================================
  // TAMBAH
  // =========================================================

  Future<void> tambahGroupJadwal(String namaGrup, String keterangan) async {
    try {
      final data = {'nama_grup': namaGrup, 'keterangan': keterangan};

      final response = await network.getData_post(data, 'groupJadwal');

      print('====================================');
      print('POST GROUP JADWAL');
      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.body}');
      print('====================================');

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        Navigator.pop(context);

        await getGroupJadwal();

        _showSuccess('Group jadwal berhasil ditambahkan.');
      } else {
        _showError(body['message'] ?? 'Gagal menambahkan group jadwal.');
      }
    } catch (e) {
      print('ERROR TAMBAH: $e');

      _showError('Terjadi kesalahan saat menambahkan data.');
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<void> updateGroupJadwal(
    int id,
    String namaGrup,
    String keterangan,
  ) async {
    try {
      final data = {'nama_grup': namaGrup, 'keterangan': keterangan};

      final response = await network.getData_post(data, 'groupJadwal/$id');

      print('====================================');
      print('UPDATE GROUP JADWAL');
      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.body}');
      print('====================================');

      final body = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        Navigator.pop(context);

        await getGroupJadwal();

        _showSuccess('Group jadwal berhasil diperbarui.');
      } else {
        _showError(body['message'] ?? 'Gagal memperbarui group jadwal.');
      }
    } catch (e) {
      print('ERROR UPDATE: $e');

      _showError('Terjadi kesalahan saat memperbarui data.');
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> hapusGroupJadwal(int id) async {
    try {
      final response = await network.deleteData('groupJadwal/$id');

      print('====================================');
      print('DELETE GROUP JADWAL');
      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.body}');
      print('====================================');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        await getGroupJadwal();

        _showSuccess('Group jadwal berhasil dihapus.');
      } else {
        _showError(body['message'] ?? 'Gagal menghapus group jadwal.');
      }
    } catch (e) {
      print('ERROR DELETE: $e');

      _showError('Terjadi kesalahan saat menghapus data.');
    }
  }

  // =========================================================
  // DIALOG TAMBAH / EDIT
  // =========================================================

  void showForm({GroupJadwal? item}) {
    final bool isEdit = item != null;

    final namaController = TextEditingController(text: item?.namaGrup ?? '');

    final keteranganController = TextEditingController(
      text: item?.keterangan ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Group Jadwal' : 'Tambah Group Jadwal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama Grup',
                        hintText: 'Contoh: Security Shift',
                        prefixIcon: Icon(Icons.groups),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: keteranganController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                        hintText: 'Keterangan group jadwal',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Batal'),
                ),

                ElevatedButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          final nama = namaController.text.trim();

                          final keterangan = keteranganController.text.trim();

                          if (nama.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama grup wajib diisi.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          if (isEdit) {
                            await updateGroupJadwal(item.id!, nama, keterangan);
                          } else {
                            await tambahGroupJadwal(nama, keterangan);
                          }
                        },
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(saving ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // KONFIRMASI DELETE
  // =========================================================

  void konfirmasiHapus(GroupJadwal item) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Hapus Group Jadwal?',
      text: 'Apakah Anda yakin ingin menghapus "${item.namaGrup}"?',
      confirmBtnText: 'Hapus',
      cancelBtnText: 'Batal',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () {
        Navigator.pop(context);

        hapusGroupJadwal(item.id!);
      },
    );
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Jadwal'),
        actions: [
          IconButton(
            onPressed: getGroupJadwal,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),

      body: RefreshIndicator(
        onRefresh: getGroupJadwal,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : dataGroup.isEmpty
            ? _emptyData()
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: dataGroup.length,
                itemBuilder: (context, index) {
                  final item = dataGroup[index];

                  return _cardGroup(item);
                },
              ),
      ),
    );
  }

  // =========================================================
  // CARD
  // =========================================================

  Widget _cardGroup(GroupJadwal item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.groups, color: Colors.blue.shade700),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaGrup,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item.keterangan.isEmpty
                        ? 'Tidak ada keterangan'
                        : item.keterangan,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'detail') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailGroupJadwalPage(id: item.id!),
                    ),
                  );
                }

                if (value == 'delete') {
                  konfirmasiHapus(item);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'detail',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 10),
                      Text('Detail'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Hapus'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _emptyData() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 70,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 15),
                Text(
                  'Belum ada group jadwal',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    showForm();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Group'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ALERT
  // =========================================================

  void _showSuccess(String message) {
    if (!mounted) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Berhasil',
      text: message,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Gagal',
      text: message,
    );
  }
}
