import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:absensiadmin/groupjadwal/groupjadwal_model.dart';
import 'package:flutter/material.dart';

class DataKaryawanPage extends StatefulWidget {
  const DataKaryawanPage({super.key});

  @override
  State<DataKaryawanPage> createState() => _DataKaryawanPageState();
}

class _DataKaryawanPageState extends State<DataKaryawanPage> {
  final Network network = Network();

  bool isLoading = true;

  List<dynamic> dataKaryawan = [];

  String search = '';

  @override
  void initState() {
    super.initState();
    getKaryawan();
    getGroupJadwal();
  }

  // =========================================================
  // GET DATA
  // =========================================================

  Future<void> getKaryawan() async {
    setState(() {
      isLoading = true;
    });

    try {
      String endpoint = 'karyawan';

      if (search.trim().isNotEmpty) {
        endpoint += '?search=${Uri.encodeComponent(search.trim())}';
      }

      final response = await network.getData(endpoint);

      print('================================');
      print('GET KARYAWAN');
      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final data = body['data'];

          // Laravel paginate()
          if (data is Map && data['data'] is List) {
            dataKaryawan = data['data'];
          }
          // Kalau API mengembalikan List langsung
          else if (data is List) {
            dataKaryawan = data;
          } else {
            dataKaryawan = [];
          }
        } else {
          dataKaryawan = [];
        }
      } else {
        _showMessage(
          'Gagal mengambil data (${response.statusCode})',
          isError: true,
        );
      }
    } catch (e) {
      print('ERROR GET KARYAWAN: $e');

      _showMessage('Terjadi kesalahan: $e', isError: true);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteKaryawan(dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Karyawan'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus data karyawan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final response = await network.deleteData('karyawan/$id');

      print('DELETE STATUS : ${response.statusCode}');
      print('DELETE BODY   : ${response.body}');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        _showMessage(body['message'] ?? 'Data berhasil dihapus.');

        getKaryawan();
      } else {
        _showMessage(body['message'] ?? 'Gagal menghapus data.', isError: true);
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  // =========================================================
  // FORM TAMBAH / EDIT
  // =========================================================

  void showFormKaryawan({Map<String, dynamic>? data}) {
    final bool isEdit = data != null;

    final noKaryawanController = TextEditingController(
      text: data?['no_karyawan']?.toString() ?? '',
    );

    final namaController = TextEditingController(
      text: data?['nama_lengkap']?.toString() ?? '',
    );

    final nikController = TextEditingController(
      text: data?['nik']?.toString() ?? '',
    );

    final noTelpController = TextEditingController(
      text: data?['no_telp']?.toString() ?? '',
    );

    final emailController = TextEditingController(
      text: data?['email']?.toString() ?? '',
    );

    final passwordController = TextEditingController();

    final alamatController = TextEditingController(
      text: data?['alamat_domisili']?.toString() ?? '',
    );

    final noRekController = TextEditingController(
      text: data?['no_rek']?.toString() ?? '',
    );

    final bankController = TextEditingController(
      text: data?['bank']?.toString() ?? '',
    );

    String? selectedJk = data?['jk']?.toString();

    String? selectedStatus = data?['sts_karyawan']?.toString();

    selectedGroupJadwalId = data?['group_jadwal_id'] == null
        ? null
        : int.tryParse(data!['group_jadwal_id'].toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool loading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Karyawan' : 'Tambah Karyawan'),

              content: SizedBox(
                width: 600,

                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ==========================
                      // NO KARYAWAN
                      // ==========================

                      TextField(
                        controller: noKaryawanController,
                        decoration: const InputDecoration(
                          labelText: 'No. Karyawan *',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================
                      // NAMA
                      // ==========================
                      TextField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap *',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================
                      // NIK
                      // ==========================
                      TextField(
                        controller: nikController,
                        decoration: const InputDecoration(
                          labelText: 'NIK',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================
                      // JENIS KELAMIN
                      // ==========================
                      DropdownButtonFormField<String>(
                        value: ['L', 'P'].contains(selectedJk)
                            ? selectedJk
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kelamin',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'L',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'P',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedJk = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // ==========================
                      // NO TELEPON
                      // ==========================
                      TextField(
                        controller: noTelpController,
                        decoration: const InputDecoration(
                          labelText: 'No. Telepon',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================
                      // EMAIL
                      // ==========================
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================
                      // PASSWORD
                      // ==========================
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: isEdit
                              ? 'Password (kosongkan jika tidak diubah)'
                              : 'Password',
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================
                      // ALAMAT
                      // ==========================
                      TextField(
                        controller: alamatController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Domisili',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================
                      // NO REKENING
                      // ==========================
                      TextField(
                        controller: noRekController,
                        decoration: const InputDecoration(
                          labelText: 'No. Rekening',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==========================
                      // BANK
                      // ==========================
                      TextField(
                        controller: bankController,
                        decoration: const InputDecoration(
                          labelText: 'Bank',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<int>(
                        value:
                            groupJadwal.any(
                              (item) =>
                                  int.tryParse(item['id'].toString()) ==
                                  selectedGroupJadwalId,
                            )
                            ? selectedGroupJadwalId
                            : null,

                        decoration: const InputDecoration(
                          labelText: 'Group Jadwal',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.schedule),
                        ),

                        hint: const Text('Pilih Group Jadwal'),

                        items: groupJadwal.map<DropdownMenuItem<int>>((item) {
                          final id = int.tryParse(item['id'].toString());

                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(item['nama_grup']?.toString() ?? '-'),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedGroupJadwalId = value;
                          });
                        },
                      ),
                    ],
                  ),
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
                          if (namaController.text.trim().isEmpty) {
                            _showMessage(
                              'Nama lengkap wajib diisi.',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() {
                            loading = true;
                          });

                          final requestData = {
                            'no_karyawan': noKaryawanController.text.trim(),

                            'nama_lengkap': namaController.text.trim(),

                            'nik': nikController.text.trim(),

                            'jk': selectedJk,

                            'no_telp': noTelpController.text.trim(),

                            'email': emailController.text.trim(),

                            'alamat_domisili': alamatController.text.trim(),

                            'no_rek': noRekController.text.trim(),

                            'bank': bankController.text.trim(),

                            'group_jadwal_id': selectedGroupJadwalId,

                            if (passwordController.text.trim().isNotEmpty)
                              'password': passwordController.text.trim(),
                          };

                          bool berhasil = false;

                          try {
                            dynamic response;

                            if (isEdit) {
                              response = await network.putData(
                                requestData,
                                'karyawan/${data['id']}',
                              );
                            } else {
                              response = await network.getData_post(
                                requestData,
                                'karyawan',
                              );
                            }

                            print('SAVE STATUS : ${response.statusCode}');

                            print('SAVE BODY : ${response.body}');

                            final body = jsonDecode(response.body);

                            if ((response.statusCode == 200 ||
                                    response.statusCode == 201) &&
                                body['success'] == true) {
                              berhasil = true;

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }

                              _showMessage(
                                body['message'] ?? 'Data berhasil disimpan.',
                              );

                              getKaryawan();
                            } else {
                              _showMessage(
                                body['message'] ?? 'Gagal menyimpan data.',
                                isError: true,
                              );

                              if (body['errors'] != null) {
                                print('VALIDATION ERROR: ${body['errors']}');
                              }
                            }
                          } catch (e) {
                            print('ERROR SAVE: $e');

                            _showMessage(
                              'Terjadi kesalahan: $e',
                              isError: true,
                            );
                          }

                          if (!berhasil && dialogContext.mounted) {
                            setDialogState(() {
                              loading = false;
                            });
                          }
                        },

                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEdit ? 'Update' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<dynamic> groupJadwal = [];

  int? selectedGroupJadwalId;

  Future<void> getGroupJadwal() async {
    try {
      final response = await network.getData('masterGroupJadwal');

      print('================================');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] is List) {
          setState(() {
            groupJadwal = List<dynamic>.from(body['data']);
          });
        } else {
          setState(() {
            groupJadwal = [];
          });
        }
      } else {
        setState(() {
          groupJadwal = [];
        });
      }
    } catch (e) {
      print('ERROR GROUP JADWAL: $e');

      setState(() {
        groupJadwal = [];
      });
    }
  }

  // =========================================================
  // DETAIL
  // =========================================================

  void showDetail(Map<String, dynamic> data) {
    final departement = data['departement'];

    final jabatan = data['jabatan'];

    final pendidikan = data['pendidikan'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detail Karyawan'),

          content: SizedBox(
            width: 550,

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _detailItem('No. Karyawan', data['no_karyawan']),

                  _detailItem('Nama Lengkap', data['nama_lengkap']),

                  _detailItem('NIK', data['nik']),

                  _detailItem('Jenis Kelamin', data['jk']),

                  _detailItem(
                    'Departement',
                    departement != null ? departement['nama_departement'] : '-',
                  ),

                  _detailItem(
                    'Jabatan',
                    jabatan != null ? jabatan['nama_jabatan'] : '-',
                  ),

                  _detailItem(
                    'Pendidikan',
                    pendidikan != null ? pendidikan['nama_pendidikan'] : '-',
                  ),

                  _detailItem('No. Telepon', data['no_telp']),

                  _detailItem('Email', data['email']),

                  _detailItem('Alamat', data['alamat_domisili']),

                  _detailItem('Status', data['sts_karyawan']),

                  _detailItem('Bank', data['bank']),

                  _detailItem('No. Rekening', data['no_rek']),
                ],
              ),
            ),
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

  Widget _detailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // =========================================================
  // CARD
  // =========================================================

  Widget _karyawanCard(Map<String, dynamic> data) {
    // final departement = data['departement'];

    final groupJadwal = data['group_jadwal'];

    final jabatan = data['jabatan'];

    final nama = data['nama_lengkap'] ?? '-';

    final noKaryawan = data['no_karyawan'] ?? '-';

    final groupJadwalName = groupJadwal != null
        ? groupJadwal['nama_grup']?.toString() ?? '-'
        : '-';

    final jabatanName = jabatan != null
        ? jabatan['nama_jabatan']?.toString() ?? '-'
        : '-';

    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () {
          showDetail(data);
        },

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,

                    child: Text(
                      nama.toString().isNotEmpty
                          ? nama.toString().substring(0, 1).toUpperCase()
                          : '?',

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          nama.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          noKaryawan.toString(),

                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'generate_absensi') {
                        generateAbsensi(data);
                      }
                      if (value == 'edit') {
                        showFormKaryawan(data: data);
                      }

                      if (value == 'delete') {
                        deleteKaryawan(data['id']);
                      }
                    },

                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'generate_absensi',
                        child: Row(
                          children: [
                            Icon(Icons.event_available_outlined, size: 20),
                            SizedBox(width: 10),
                            Text('Generate Absensi'),
                          ],
                        ),
                      ),
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

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.business_outlined, size: 18),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      groupJadwalName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.work_outline, size: 18),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(jabatanName, overflow: TextOverflow.ellipsis),
                  ),
                ],
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

  Future<void> generateAbsensi(Map<String, dynamic> data) async {
    final karyawanId = data['id'];

    final nama = data['nama_lengkap']?.toString() ?? '-';

    // =========================
    // KONFIRMASI
    // =========================
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Generate Absensi'),
          content: Text(
            'Apakah Anda yakin akan generate absensi untuk karyawan "$nama"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Generate'),
            ),
          ],
        );
      },
    );

    // Jika batal
    if (confirm != true) {
      return;
    }

    // =========================
    // LOADING
    // =========================
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Sedang generate absensi...')),
            ],
          ),
        );
      },
    );

    try {
      // =========================
      // REQUEST
      // =========================
      final response = await network.getData_post({
        'karyawan_id': karyawanId,
      }, 'findSundaysToKaryawan');

      // Tutup loading
      if (mounted) {
        Navigator.pop(context);
      }

      print('================================');
      print('GENERATE ABSENSI');
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');
      print('================================');

      final body = jsonDecode(response.body);

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200 && body['status'] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body['message']?.toString() ?? 'Absensi berhasil dibuat.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // =========================
        // ERROR API
        // =========================
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body['message']?.toString() ?? 'Gagal generate absensi.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Pastikan loading ditutup
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      print('ERROR GENERATE ABSENSI: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Karyawan')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showFormKaryawan();
        },

        icon: const Icon(Icons.add),

        label: const Text('Tambah Karyawan'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            // =========================
            // SEARCH
            // =========================

            TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama, NIK atau nomor karyawan...',

                prefixIcon: const Icon(Icons.search),

                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            search = '';
                          });

                          getKaryawan();
                        },

                        icon: const Icon(Icons.clear),
                      )
                    : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onChanged: (value) {
                search = value;
              },

              onSubmitted: (_) {
                getKaryawan();
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // DATA
            // =========================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dataKaryawan.isEmpty
                  ? _emptyData()
                  : RefreshIndicator(
                      onRefresh: getKaryawan,

                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 1;

                          if (constraints.maxWidth >= 1100) {
                            crossAxisCount = 3;
                          } else if (constraints.maxWidth >= 700) {
                            crossAxisCount = 2;
                          }

                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,

                                  crossAxisSpacing: 18,

                                  mainAxisSpacing: 18,

                                  childAspectRatio: 1.65,
                                ),

                            itemCount: dataKaryawan.length,

                            itemBuilder: (context, index) {
                              final data = Map<String, dynamic>.from(
                                dataKaryawan[index],
                              );

                              return _karyawanCard(data);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.people_outline, size: 70, color: Colors.grey.shade400),

          const SizedBox(height: 15),

          Text(
            'Belum ada data karyawan',

            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: getKaryawan,

            icon: const Icon(Icons.refresh),

            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
