import 'dart:async';
import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:flutter/material.dart';

// Sesuaikan import Network Anda
// import '../network/network.dart';

class AturanPotonganPage extends StatefulWidget {
  const AturanPotonganPage({super.key});

  @override
  State<AturanPotonganPage> createState() => _AturanPotonganPageState();
}

class _AturanPotonganPageState extends State<AturanPotonganPage> {
  List<AturanPotongan> data = [];

  bool isLoading = false;

  final TextEditingController searchController = TextEditingController();

  Timer? _searchTimer;

  String? selectedJenisPotongan;

  final List<String> jenisPotonganList = [
    'terlambat',
    'izin',
    'sakit',
    'alpha',
    'lupa_absen',
    'bpjs',
  ];

  @override
  void initState() {
    super.initState();
    getAturanPotongan();
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // GET DATA
  // ============================================================

  Future<void> getAturanPotongan({
    String? search,
    String? jenisPotongan,
  }) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String endpoint = 'aturanPotonganAdmin';

      final params = <String>[];

      if (search != null && search.trim().isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search.trim())}');
      }

      if (jenisPotongan != null && jenisPotongan.trim().isNotEmpty) {
        params.add('jenis_potongan=${Uri.encodeComponent(jenisPotongan)}');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await Network().getData(endpoint);

      debugPrint('================================');
      debugPrint('GET ATURAN POTONGAN');
      debugPrint('ENDPOINT : $endpoint');
      debugPrint('STATUS   : ${response.statusCode}');
      debugPrint('BODY     : ${response.body}');
      debugPrint('================================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];

          final hasil = list
              .map((e) => AturanPotongan.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          if (mounted) {
            setState(() {
              data = hasil;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              data = [];
            });
          }
        }
      } else {
        _showMessage('Gagal mengambil data aturan potongan', Colors.red);
      }
    } catch (e) {
      debugPrint('ERROR GET ATURAN POTONGAN: $e');

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
  // STORE
  // ============================================================

  Future<bool> tambahAturanPotongan({
    required int konfigId,
    required String jenisPotongan,
    required String namaAturan,
    int? menitMulai,
    int? menitSelesai,
    int? qtyMulai,
    int? qtySelesai,
    required String tipeNilai,
    required double nilaiPotongan,
    String? sumberPotongan,
    required bool isActive,
  }) async {
    try {
      final body = {
        'konfig_id': konfigId,
        'jenis_potongan': jenisPotongan,
        'nama_aturan': namaAturan,
        'menit_mulai': menitMulai,
        'menit_selesai': menitSelesai,
        'qty_mulai': qtyMulai,
        'qty_selesai': qtySelesai,
        'tipe_nilai': tipeNilai,
        'nilai_potongan': nilaiPotongan,
        'sumber_potongan': sumberPotongan,
        'is_active': isActive,
      };

      debugPrint('STORE BODY: $body');

      final response = await Network().getData_post(
        body,
        'aturanPotonganAdmin',
      );

      debugPrint('================================');
      debugPrint('STORE ATURAN POTONGAN');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('================================');

      final responseBody = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseBody['success'] == true) {
        await getAturanPotongan(
          search: searchController.text,
          jenisPotongan: selectedJenisPotongan,
        );

        _showMessage(
          responseBody['message'] ?? 'Aturan potongan berhasil ditambahkan',
          Colors.green,
        );

        return true;
      }

      _showMessage(
        responseBody['message'] ?? 'Gagal menambahkan aturan potongan',
        Colors.red,
      );

      return false;
    } catch (e) {
      debugPrint('ERROR STORE: $e');

      _showMessage('Terjadi kesalahan: $e', Colors.red);

      return false;
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<bool> updateAturanPotongan({
    required int id,
    required int konfigId,
    required String jenisPotongan,
    required String namaAturan,
    int? menitMulai,
    int? menitSelesai,
    int? qtyMulai,
    int? qtySelesai,
    required String tipeNilai,
    required double nilaiPotongan,
    String? sumberPotongan,
    required bool isActive,
  }) async {
    try {
      final body = {
        'konfig_id': konfigId,
        'jenis_potongan': jenisPotongan,
        'nama_aturan': namaAturan,
        'menit_mulai': menitMulai,
        'menit_selesai': menitSelesai,
        'qty_mulai': qtyMulai,
        'qty_selesai': qtySelesai,
        'tipe_nilai': tipeNilai,
        'nilai_potongan': nilaiPotongan,
        'sumber_potongan': sumberPotongan,
        'is_active': isActive,
      };

      debugPrint('UPDATE BODY: $body');

      final response = await Network().putData(body, 'aturanPotonganAdmin/$id');

      debugPrint('================================');
      debugPrint('UPDATE ATURAN POTONGAN');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('================================');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        await getAturanPotongan(
          search: searchController.text,
          jenisPotongan: selectedJenisPotongan,
        );

        _showMessage(
          responseBody['message'] ?? 'Aturan potongan berhasil diperbarui',
          Colors.green,
        );

        return true;
      }

      _showMessage(
        responseBody['message'] ?? 'Gagal memperbarui aturan potongan',
        Colors.red,
      );

      return false;
    } catch (e) {
      debugPrint('ERROR UPDATE: $e');

      _showMessage('Terjadi kesalahan: $e', Colors.red);

      return false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteAturanPotongan(int id) async {
    try {
      final response = await Network().deleteData('aturanPotonganAdmin/$id');

      debugPrint('================================');
      debugPrint('DELETE ATURAN POTONGAN');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('================================');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        await getAturanPotongan(
          search: searchController.text,
          jenisPotongan: selectedJenisPotongan,
        );

        _showMessage(
          body['message'] ?? 'Aturan potongan berhasil dihapus',
          Colors.green,
        );
      } else {
        _showMessage(
          body['message'] ?? 'Gagal menghapus aturan potongan',
          Colors.red,
        );
      }
    } catch (e) {
      debugPrint('ERROR DELETE: $e');

      _showMessage('Terjadi kesalahan: $e', Colors.red);
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      getAturanPotongan(search: value, jenisPotongan: selectedJenisPotongan);
    });

    setState(() {});
  }

  // ============================================================
  // FORM
  // ============================================================

  void showForm({AturanPotongan? item}) {
    final bool isEdit = item != null;

    final konfigController = TextEditingController(
      text: item?.konfigId.toString() ?? '1',
    );

    final namaController = TextEditingController(text: item?.namaAturan ?? '');

    final menitMulaiController = TextEditingController(
      text: item?.menitMulai?.toString() ?? '',
    );

    final menitSelesaiController = TextEditingController(
      text: item?.menitSelesai?.toString() ?? '',
    );

    final qtyMulaiController = TextEditingController(
      text: item?.qtyMulai?.toString() ?? '',
    );

    final qtySelesaiController = TextEditingController(
      text: item?.qtySelesai?.toString() ?? '',
    );

    final nilaiController = TextEditingController(
      text: item?.nilaiPotongan.toString() ?? '',
    );

    final sumberController = TextEditingController(
      text: item?.sumberPotongan ?? '',
    );

    String jenisPotongan = item?.jenisPotongan ?? jenisPotonganList.first;

    String tipeNilai = item?.tipeNilai ?? 'nominal';

    bool isActive = item?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_outlined : Icons.rule_outlined,
                            color: const Color(0xff1976D2),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            isEdit
                                ? 'Edit Aturan Potongan'
                                : 'Tambah Aturan Potongan',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // KONFIG ID
                    _textField(
                      controller: konfigController,
                      label: 'Konfigurasi ID',
                      hint: 'Contoh: 1',
                      icon: Icons.settings_outlined,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 15),

                    // JENIS
                    DropdownButtonFormField<String>(
                      value: jenisPotongan,
                      isExpanded: true,
                      decoration: _inputDecoration(
                        label: 'Jenis Potongan',
                        icon: Icons.category_outlined,
                      ),
                      items: jenisPotonganList.map((jenis) {
                        return DropdownMenuItem<String>(
                          value: jenis,
                          child: Text(_capitalize(jenis)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            jenisPotongan = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // NAMA
                    _textField(
                      controller: namaController,
                      label: 'Nama Aturan',
                      hint: 'Contoh: Terlambat 1-15 Menit',
                      icon: Icons.rule_outlined,
                    ),

                    const SizedBox(height: 15),

                    // MENIT
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller: menitMulaiController,
                            label: 'Menit Mulai',
                            hint: 'Contoh: 1',
                            icon: Icons.timer_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _textField(
                            controller: menitSelesaiController,
                            label: 'Menit Selesai',
                            hint: 'Contoh: 15',
                            icon: Icons.timer_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // QTY
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller: qtyMulaiController,
                            label: 'Qty Mulai',
                            hint: 'Opsional',
                            icon: Icons.numbers_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _textField(
                            controller: qtySelesaiController,
                            label: 'Qty Selesai',
                            hint: 'Opsional',
                            icon: Icons.numbers_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // TIPE NILAI
                    DropdownButtonFormField<String>(
                      value: tipeNilai,
                      isExpanded: true,
                      decoration: _inputDecoration(
                        label: 'Tipe Nilai',
                        icon: Icons.payments_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'nominal',
                          child: Text('Nominal'),
                        ),

                        DropdownMenuItem(
                          value: 'persen',
                          child: Text('Persentase'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            tipeNilai = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // NILAI
                    _textField(
                      controller: nilaiController,
                      label: tipeNilai == 'persen'
                          ? 'Nilai Persentase'
                          : 'Nilai Potongan',
                      hint: tipeNilai == 'persen'
                          ? 'Contoh: 2.5'
                          : 'Contoh: 10000',
                      icon: Icons.money_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // SUMBER
                    DropdownButtonFormField<String>(
                      value: sumberController.text.isEmpty
                          ? null
                          : sumberController.text,
                      decoration: InputDecoration(
                        labelText: 'Sumber Potongan',
                        hintText: 'Pilih sumber potongan',
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Color(0xff1976D2),
                        ),
                        filled: true,
                        fillColor: const Color(0xffF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'uang_makan',
                          child: Text('Uang Makan'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'gaji_pokok',
                          child: Text('Gaji Pokok'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          sumberController.text = value;
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    // ACTIVE
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        value: isActive,
                        title: const Text(
                          'Aturan Aktif',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          isActive
                              ? 'Aturan akan digunakan'
                              : 'Aturan tidak digunakan',
                        ),
                        secondary: Icon(
                          isActive
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final konfigId = int.tryParse(
                            konfigController.text.trim(),
                          );

                          final nama = namaController.text.trim();

                          final menitMulai = int.tryParse(
                            menitMulaiController.text.trim(),
                          );

                          final menitSelesai = int.tryParse(
                            menitSelesaiController.text.trim(),
                          );

                          final qtyMulai = int.tryParse(
                            qtyMulaiController.text.trim(),
                          );

                          final qtySelesai = int.tryParse(
                            qtySelesaiController.text.trim(),
                          );

                          final nilai = double.tryParse(
                            nilaiController.text.trim(),
                          );

                          final sumber = sumberController.text.trim().isEmpty
                              ? null
                              : sumberController.text.trim();

                          // VALIDASI
                          if (konfigId == null) {
                            _showMessage(
                              'Konfigurasi ID harus diisi',
                              Colors.red,
                            );
                            return;
                          }

                          if (nama.isEmpty) {
                            _showMessage('Nama aturan harus diisi', Colors.red);
                            return;
                          }

                          if (nilai == null) {
                            _showMessage(
                              'Nilai potongan harus diisi',
                              Colors.red,
                            );
                            return;
                          }

                          if (nilai < 0) {
                            _showMessage(
                              'Nilai potongan tidak boleh negatif',
                              Colors.red,
                            );
                            return;
                          }

                          // CLOSE
                          Navigator.pop(modalContext);

                          bool berhasil;

                          if (isEdit) {
                            berhasil = await updateAturanPotongan(
                              id: item.id,
                              konfigId: konfigId,
                              jenisPotongan: jenisPotongan,
                              namaAturan: nama,
                              menitMulai: menitMulai,
                              menitSelesai: menitSelesai,
                              qtyMulai: qtyMulai,
                              qtySelesai: qtySelesai,
                              tipeNilai: tipeNilai,
                              nilaiPotongan: nilai,
                              sumberPotongan: sumber,
                              isActive: isActive,
                            );
                          } else {
                            berhasil = await tambahAturanPotongan(
                              konfigId: konfigId,
                              jenisPotongan: jenisPotongan,
                              namaAturan: nama,
                              menitMulai: menitMulai,
                              menitSelesai: menitSelesai,
                              qtyMulai: qtyMulai,
                              qtySelesai: qtySelesai,
                              tipeNilai: tipeNilai,
                              nilaiPotongan: nilai,
                              sumberPotongan: sumber,
                              isActive: isActive,
                            );
                          }

                          debugPrint('HASIL SIMPAN: $berhasil');
                        },
                        icon: Icon(isEdit ? Icons.save_outlined : Icons.add),
                        label: Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Aturan',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DELETE CONFIRM
  // ============================================================

  void confirmDelete(AturanPotongan item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Hapus Aturan'),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            '"${item.namaAturan}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await deleteAturanPotongan(item.id);
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
  // HELPER TEXT FIELD
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xff1976D2)),
      filled: true,
      fillColor: const Color(0xffF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _itemCard(AturanPotongan item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // ICON
            // =========================
            Container(
              width: 45,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.rule_outlined,
                color: Color(0xff1976D2),
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // =========================
            // CONTENT
            // =========================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // NAMA ATURAN
                  // =========================
                  Text(
                    item.namaAturan,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // =========================
                  // JENIS + STATUS
                  // =========================
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _badge(_capitalize(item.jenisPotongan), Colors.blue),

                      _badge(
                        item.isActive ? 'Aktif' : 'Nonaktif',
                        item.isActive ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // DETAIL
                  // =========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Konfig ID
                        _detailRow(
                          icon: Icons.settings_outlined,
                          label: 'Konfigurasi',
                          value: item.konfigId.toString(),
                        ),

                        // Menit
                        _detailRow(
                          icon: Icons.timer_outlined,
                          label: 'Menit',
                          value: _rangeValue(
                            item.menitMulai,
                            item.menitSelesai,
                            'menit',
                          ),
                        ),

                        // Qty
                        _detailRow(
                          icon: Icons.numbers_outlined,
                          label: 'Qty',
                          value: _rangeValue('-', '-', 'qty'),
                        ),

                        // Tipe Nilai
                        _detailRow(
                          icon: Icons.category_outlined,
                          label: 'Tipe Nilai',
                          value: _capitalize(item.tipeNilai),
                        ),

                        // Nilai Potongan
                        _detailRow(
                          icon: Icons.payments_outlined,
                          label: 'Nilai Potongan',
                          value: item.tipeNilai == 'persen'
                              ? '${_formatNumber(item.nilaiPotongan)}%'
                              : 'Rp ${_formatNumber(item.nilaiPotongan)}',
                        ),

                        // Sumber
                        _detailRow(
                          icon: Icons.source_outlined,
                          label: 'Sumber',
                          value: item.sumberPotongan?.isNotEmpty == true
                              ? item.sumberPotongan!
                              : '-',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // MENU
            // =========================
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') {
                  showForm(item: item);
                }

                if (value == 'delete') {
                  confirmDelete(item);
                }
              },
              itemBuilder: (context) {
                return const [
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
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  String _rangeValue(dynamic mulai, dynamic selesai, String satuan) {
    if (mulai == null && selesai == null) {
      return '-';
    }

    if (mulai != null && selesai != null) {
      return '$mulai - $selesai $satuan';
    }

    if (mulai != null) {
      return 'Mulai $mulai $satuan';
    }

    return 'Sampai $selesai $satuan';
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Icon(icon, size: 17, color: const Color(0xff64748B)),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xff64748B)),
            ),
          ),

          const Text(
            ': ',
            style: TextStyle(fontSize: 13, color: Color(0xff64748B)),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xff1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Aturan Potongan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari aturan potongan...',
                prefixIcon: const Icon(Icons.search, color: Color(0xff1976D2)),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();

                          setState(() {});

                          getAturanPotongan(
                            jenisPotongan: selectedJenisPotongan,
                          );
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: selectedJenisPotongan,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Semua Jenis',
                      prefixIcon: const Icon(
                        Icons.filter_alt_outlined,
                        color: Color(0xff1976D2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Semua Jenis'),
                      ),

                      ...jenisPotonganList.map((jenis) {
                        return DropdownMenuItem<String?>(
                          value: jenis,
                          child: Text(_capitalize(jenis)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedJenisPotongan = value;
                      });

                      getAturanPotongan(
                        search: searchController.text,
                        jenisPotongan: value,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () {
                    getAturanPotongan(
                      search: searchController.text,
                      jenisPotongan: selectedJenisPotongan,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),

          // COUNT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${data.length} Aturan Potongan',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => getAturanPotongan(
                search: searchController.text,
                jenisPotongan: selectedJenisPotongan,
              ),

              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff1976D2),
                      ),
                    )
                  : data.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),

                        Icon(
                          Icons.rule_outlined,
                          size: 60,
                          color: Colors.black26,
                        ),

                        SizedBox(height: 15),

                        Center(
                          child: Text(
                            'Belum ada aturan potongan',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 100),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return _itemCard(data[index]);
                      },
                    ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showForm(),
        backgroundColor: const Color(0xff1976D2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

// ================================================================
// MODEL
// ================================================================

class AturanPotongan {
  final int id;
  final int konfigId;
  final String jenisPotongan;
  final String namaAturan;

  final int? menitMulai;
  final int? menitSelesai;

  final int? qtyMulai;
  final int? qtySelesai;

  final String tipeNilai;
  final double nilaiPotongan;

  final String? sumberPotongan;

  final bool isActive;

  AturanPotongan({
    required this.id,
    required this.konfigId,
    required this.jenisPotongan,
    required this.namaAturan,
    this.menitMulai,
    this.menitSelesai,
    this.qtyMulai,
    this.qtySelesai,
    required this.tipeNilai,
    required this.nilaiPotongan,
    this.sumberPotongan,
    required this.isActive,
  });

  factory AturanPotongan.fromJson(Map<String, dynamic> json) {
    return AturanPotongan(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,

      konfigId: int.tryParse(json['konfig_id']?.toString() ?? '') ?? 0,

      jenisPotongan: json['jenis_potongan']?.toString() ?? '',

      namaAturan: json['nama_aturan']?.toString() ?? '',

      menitMulai: json['menit_mulai'] == null
          ? null
          : int.tryParse(json['menit_mulai'].toString()),

      menitSelesai: json['menit_selesai'] == null
          ? null
          : int.tryParse(json['menit_selesai'].toString()),

      qtyMulai: json['qty_mulai'] == null
          ? null
          : int.tryParse(json['qty_mulai'].toString()),

      qtySelesai: json['qty_selesai'] == null
          ? null
          : int.tryParse(json['qty_selesai'].toString()),

      tipeNilai: json['tipe_nilai']?.toString() ?? 'nominal',

      nilaiPotongan:
          double.tryParse(json['nilai_potongan']?.toString() ?? '0') ?? 0,

      sumberPotongan: json['sumber_potongan']?.toString(),

      isActive:
          json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active']?.toString() == '1',
    );
  }
}
