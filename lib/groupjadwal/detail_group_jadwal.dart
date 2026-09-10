import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:flutter/material.dart';

class DetailGroupJadwalPage extends StatefulWidget {
  final int id;

  const DetailGroupJadwalPage({super.key, required this.id});

  @override
  State<DetailGroupJadwalPage> createState() => _DetailGroupJadwalPageState();
}

class _DetailGroupJadwalPageState extends State<DetailGroupJadwalPage>
    with SingleTickerProviderStateMixin {
  final Network network = Network();

  bool isLoading = true;

  Map<String, dynamic>? groupData;

  List<dynamic> detailGroupJadwal = [];
  List<dynamic> karyawan = [];

  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    getDetailGroup();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> getDetailGroup() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await network.getData('groupJadwal/${widget.id}');

      debugPrint('================================');
      debugPrint('DETAIL GROUP RESPONSE');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('================================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];

          if (data is Map) {
            groupData = Map<String, dynamic>.from(data);

            // ==========================================
            // DETAIL JAM KERJA
            // ==========================================

            final detail =
                data['detail_group_jadwal'] ?? data['detailGroupJadwal'] ?? [];

            if (detail is List) {
              detailGroupJadwal = detail;
            } else {
              detailGroupJadwal = [];
            }

            // ==========================================
            // KARYAWAN
            // ==========================================

            final kry = data['karyawan'] ?? [];

            if (kry is List) {
              karyawan = kry;
            } else {
              karyawan = [];
            }
          }
        } else {
          groupData = null;
          detailGroupJadwal = [];
          karyawan = [];
        }
      } else {
        _showError('Gagal mengambil data.\nStatus: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ERROR DETAIL GROUP: $e');

      _showError('Terjadi kesalahan saat mengambil data.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<dynamic> dataJamKerja = [];

  Future<void> getJamKerja() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await Network().getData('jam-kerja');

      debugPrint('================================');
      debugPrint('GET JAM KERJA');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('================================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final data = body['data'];

          // Karena Laravel paginate() menghasilkan object
          // bukan langsung List
          if (data is Map && data['data'] is List) {
            setState(() {
              dataJamKerja = List<dynamic>.from(data['data']);
            });
          } else {
            setState(() {
              dataJamKerja = [];
            });
          }
        } else {
          setState(() {
            dataJamKerja = [];
          });
        }
      } else {
        setState(() {
          dataJamKerja = [];
        });
      }
    } catch (e) {
      debugPrint('ERROR GET JAM KERJA: $e');

      setState(() {
        dataJamKerja = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String value(dynamic value) {
    if (value == null) return '-';

    final text = value.toString().trim();

    if (text.isEmpty) return '-';

    return text;
  }

  dynamic getValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        return data[key];
      }
    }

    return null;
  }

  // ==========================================================
  // HALAMAN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Detail Group Karyawan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: getDetailGroup,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)),
            )
          : groupData == null
          ? _emptyData()
          : Column(
              children: [
                _groupHeader(),

                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: tabController,
                    labelColor: const Color(0xFF1976D2),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF1976D2),
                    tabs: const [
                      Tab(icon: Icon(Icons.access_time), text: 'Jam Kerja'),
                      Tab(icon: Icon(Icons.people), text: 'Karyawan'),
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [_jamKerjaTab(), _karyawanTab()],
                  ),
                ),
              ],
            ),
    );
  }

  // ==========================================================
  // HEADER GROUP
  // ==========================================================

  Widget _groupHeader() {
    final namaGrup = value(getValue(groupData!, ['nama_grup', 'namaGrup']));

    final keterangan = value(getValue(groupData!, ['keterangan']));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1976D2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups,
                color: Color(0xFF1976D2),
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GROUP JADWAL',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    namaGrup,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (keterangan != '-')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        keterangan,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
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

  // ==========================================================
  // TAB JAM KERJA
  // ==========================================================

  Widget _jamKerjaTab() {
    return RefreshIndicator(
      onRefresh: getDetailGroup,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================
          // TOMBOL TAMBAH JAM KERJA
          // ==========================================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showTambahJamKerja();
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Tambah Jam Kerja',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1976D2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ==========================================
          // DATA KOSONG
          // ==========================================
          if (detailGroupJadwal.isEmpty)
            _emptySection(
              icon: Icons.access_time,
              title: 'Belum Ada Jam Kerja',
              subtitle: 'Belum ada jadwal kerja yang ditambahkan ke group ini.',
            ),

          // ==========================================
          // DATA JAM KERJA
          // ==========================================
          if (detailGroupJadwal.isNotEmpty)
            ...List.generate(detailGroupJadwal.length, (index) {
              final item = detailGroupJadwal[index];

              if (item is! Map) {
                return const SizedBox();
              }

              final data = Map<String, dynamic>.from(item);

              return _jamKerjaCard(data, index);
            }),
        ],
      ),
    );
  }

  Widget _jamKerjaCard(Map<String, dynamic> data, int index) {
    final jamKerja = data['jam_kerja'];

    String shift = value(getValue(data, ['nama_shift', 'shift']));

    String datang = value(
      getValue(data, ['datang', 'jam_masuk', 'jam_datang']),
    );

    String pulang = value(getValue(data, ['pulang', 'jam_pulang']));

    // Jika Laravel menggunakan relasi jamKerja
    if (jamKerja is Map) {
      shift = value(
        getValue(Map<String, dynamic>.from(jamKerja), ['nama_shift', 'shift']),
      );

      datang = value(
        getValue(Map<String, dynamic>.from(jamKerja), [
          'datang',
          'waktu_mulai',
          'waktu_mulai',
        ]),
      );

      pulang = value(
        getValue(Map<String, dynamic>.from(jamKerja), [
          'waktu_akhir',
          'waktu_akhir',
        ]),
      );
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Color(0xFF1976D2),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift ${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        shift,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDeleteJamKerja(data);
                    }
                  },
                ),
              ],
            ),

            const Divider(height: 24),

            Row(
              children: [
                Expanded(
                  child: _timeItem(
                    icon: Icons.login,
                    title: 'Datang',
                    value: datang,
                  ),
                ),

                Container(width: 1, height: 45, color: Colors.grey.shade300),

                Expanded(
                  child: _timeItem(
                    icon: Icons.logout,
                    title: 'Pulang',
                    value: pulang,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  dynamic selectedJamKerja;
  bool isLoadingJamKerja = false;
  Future<void> _showTambahJamKerja() async {
    await getJamKerja();

    if (!mounted) return;

    final namaGrup = value(getValue(groupData!, ['nama_grup', 'namaGrup']));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Jam Kerja',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Pilih jam kerja yang akan ditambahkan ke group ini.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    namaGrup,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<dynamic>(
                    value: selectedJamKerja,
                    decoration: InputDecoration(
                      labelText: 'Jam Kerja',
                      hintText: 'Pilih jam kerja',
                      prefixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: dataJamKerja.map<DropdownMenuItem<dynamic>>((item) {
                      return DropdownMenuItem<dynamic>(
                        value: item['id'],
                        child: Text(item['nama_shift']?.toString() ?? '-'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedJamKerja = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedJamKerja == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Silakan pilih jam kerja terlebih dahulu.',
                              ),
                            ),
                          );
                          return;
                        }

                        print('Jam kerja dipilih: $selectedJamKerja');

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _timeItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1976D2)),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TAB KARYAWAN
  // ==========================================================

  Widget _karyawanTab() {
    return RefreshIndicator(
      onRefresh: getDetailGroup,
      child: karyawan.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 100),
                _emptySection(
                  icon: Icons.people_outline,
                  title: 'Belum Ada Karyawan',
                  subtitle: 'Belum ada karyawan yang masuk ke group ini.',
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: karyawan.length,
              itemBuilder: (context, index) {
                final item = karyawan[index];

                if (item is! Map) {
                  return const SizedBox();
                }

                final data = Map<String, dynamic>.from(item);

                return _karyawanCard(data, index);
              },
            ),
    );
  }

  Widget _karyawanCard(Map<String, dynamic> data, int index) {
    final nama = value(getValue(data, ['nama_lengkap', 'nama', 'name']));

    String jabatan = value(getValue(data, ['nama_jabatan', 'jabatan']));

    // Jika Laravel mengirim relasi jabatan
    final jabatanData = data['jabatan'];

    if (jabatanData is Map) {
      jabatan = value(
        getValue(Map<String, dynamic>.from(jabatanData), [
          'nama_jabatan',
          'nama',
          'name',
        ]),
      );
    }

    final id = value(data['id']);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE3F2FD),
          child: Text(
            nama != '-' ? nama.substring(0, 1).toUpperCase() : '?',
            style: const TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(jabatan),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDeleteKaryawan(data);
            }
          },
        ),
      ),
    );
  }

  // ==========================================================
  // DELETE JAM KERJA
  // ==========================================================

  void _confirmDeleteJamKerja(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Jam Kerja?'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus jam kerja ini dari group?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);

                _deleteJamKerja(data);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteJamKerja(Map<String, dynamic> data) async {
    final id = data['id'];

    if (id == null) {
      _showError('ID detail jam kerja tidak ditemukan.');
      return;
    }

    try {
      final response = await network.deleteData('detailGroup/${id}');

      debugPrint('DELETE JAM KERJA: ${response.body}');

      if (response.statusCode == 200) {
        await getDetailGroup();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jam kerja berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Gagal menghapus jam kerja.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  // ==========================================================
  // DELETE KARYAWAN
  // ==========================================================

  void _confirmDeleteKaryawan(Map<String, dynamic> data) {
    final nama = value(getValue(data, ['nama_lengkap', 'nama', 'name']));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Karyawan?'),
          content: Text('Apakah Anda yakin ingin menghapus $nama dari group?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);

                _deleteKaryawan(data);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteKaryawan(Map<String, dynamic> data) async {
    final id = data['id'];

    if (id == null) {
      _showError('ID karyawan tidak ditemukan.');
      return;
    }

    try {
      final response = await network.deleteData(
        'groupJadwal/${widget.id}/karyawan/$id',
      );

      debugPrint('DELETE KARYAWAN: ${response.body}');

      if (response.statusCode == 200) {
        await getDetailGroup();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Karyawan berhasil dihapus dari group.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Gagal menghapus karyawan.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget _emptyData() {
    return Center(
      child: _emptySection(
        icon: Icons.groups_outlined,
        title: 'Data Tidak Ditemukan',
        subtitle: 'Group jadwal tidak ditemukan.',
      ),
    );
  }

  Widget _emptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: Colors.grey.shade400),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
