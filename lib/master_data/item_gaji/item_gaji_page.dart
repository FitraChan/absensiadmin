import 'dart:async';
import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:flutter/material.dart';

// Sesuaikan import Network dengan project kamu
// import 'package:your_app/network/network.dart';

class ItemGajiPage extends StatefulWidget {
  const ItemGajiPage({super.key});

  @override
  State<ItemGajiPage> createState() => _ItemGajiPageState();
}

class _ItemGajiPageState extends State<ItemGajiPage> {
  // ============================================================
  // DATA
  // ============================================================

  List<ItemGaji> data = [];

  List<Map<String, dynamic>> kategoriList = [];

  bool isLoading = false;

  final TextEditingController searchController = TextEditingController();

  Timer? _searchTimer;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    getItemGaji();
    getKategoriItem();
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchTimer?.cancel();

    super.dispose();
  }

  // ============================================================
  // GET ITEM GAJI
  // ============================================================

  Future<void> getItemGaji({String? search}) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String endpoint = 'itemGajiAdmin';

      if (search != null && search.trim().isNotEmpty) {
        endpoint += '?search=${Uri.encodeComponent(search.trim())}';
      }

      final response = await Network().getData(endpoint);

      debugPrint('==============================');
      debugPrint('GET ITEM GAJI');
      debugPrint('ENDPOINT : $endpoint');
      debugPrint('STATUS   : ${response.statusCode}');
      debugPrint('BODY     : ${response.body}');
      debugPrint('==============================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];

          final List<ItemGaji> hasil = list
              .map((e) => ItemGaji.fromJson(Map<String, dynamic>.from(e)))
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
        _showMessage('Gagal mengambil data item gaji', Colors.red);
      }
    } catch (e) {
      debugPrint('ERROR GET ITEM GAJI: $e');

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
  // GET KATEGORI
  // ============================================================

  Future<void> getKategoriItem() async {
    try {
      final response = await Network().getData('getKategoriItem');

      debugPrint('==============================');
      debugPrint('GET KATEGORI ITEM');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('==============================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];

          if (mounted) {
            setState(() {
              kategoriList = List<Map<String, dynamic>>.from(list);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('ERROR GET KATEGORI ITEM: $e');
    }
  }

  // ============================================================
  // TAMBAH ITEM GAJI
  // ============================================================

  Future<bool> tambahItemGaji({
    required String nama,
    required int kategoriId,
    required int noUrut,
  }) async {
    try {
      final body = {
        'nama_item_gaji': nama.trim(),
        'kategori_item_id': kategoriId,
        'no_urut': noUrut,
      };

      debugPrint('==============================');
      debugPrint('POST ITEM GAJI');
      debugPrint('BODY : $body');
      debugPrint('==============================');

      final response = await Network().getData_post(body, 'itemGajiAdmin');

      debugPrint('==============================');
      debugPrint('RESPONSE POST ITEM GAJI');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('==============================');

      final responseBody = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseBody['success'] == true) {
        await getItemGaji(search: searchController.text);

        _showMessage(
          responseBody['message'] ?? 'Item gaji berhasil ditambahkan',
          Colors.green,
        );

        return true;
      }

      _showMessage(
        responseBody['message'] ?? 'Gagal menambahkan item gaji',
        Colors.red,
      );

      return false;
    } catch (e) {
      debugPrint('ERROR TAMBAH ITEM GAJI: $e');

      _showMessage('Terjadi kesalahan: $e', Colors.red);

      return false;
    }
  }

  // ============================================================
  // UPDATE ITEM GAJI
  // ============================================================

  Future<bool> updateItemGaji({
    required int id,
    required String nama,
    required int kategoriId,
    required int noUrut,
  }) async {
    try {
      final body = {
        'nama_item_gaji': nama.trim(),
        'kategori_item_id': kategoriId,
        'no_urut': noUrut,
      };

      debugPrint('==============================');
      debugPrint('PUT ITEM GAJI');
      debugPrint('ID   : $id');
      debugPrint('BODY : $body');
      debugPrint('==============================');

      final response = await Network().putData(body, 'itemGajiAdmin/$id');

      debugPrint('==============================');
      debugPrint('RESPONSE PUT ITEM GAJI');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('==============================');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        await getItemGaji(search: searchController.text);

        _showMessage(
          responseBody['message'] ?? 'Item gaji berhasil diperbarui',
          Colors.green,
        );

        return true;
      }

      _showMessage(
        responseBody['message'] ?? 'Gagal memperbarui item gaji',
        Colors.red,
      );

      return false;
    } catch (e) {
      debugPrint('ERROR UPDATE ITEM GAJI: $e');

      _showMessage('Terjadi kesalahan: $e', Colors.red);

      return false;
    }
  }

  // ============================================================
  // DELETE ITEM GAJI
  // ============================================================

  Future<void> deleteItemGaji(int id) async {
    try {
      debugPrint('==============================');
      debugPrint('DELETE ITEM GAJI');
      debugPrint('ID : $id');
      debugPrint('==============================');

      final response = await Network().deleteData('itemGajiAdmin/$id');

      debugPrint('==============================');
      debugPrint('RESPONSE DELETE ITEM GAJI');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('==============================');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        await getItemGaji(search: searchController.text);

        _showMessage(
          body['message'] ?? 'Item gaji berhasil dihapus',
          Colors.green,
        );
      } else {
        _showMessage(
          body['message'] ?? 'Gagal menghapus item gaji',
          Colors.red,
        );
      }
    } catch (e) {
      debugPrint('ERROR DELETE ITEM GAJI: $e');

      _showMessage('Terjadi kesalahan: $e', Colors.red);
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      getItemGaji(search: value);
    });

    setState(() {});
  }

  // ============================================================
  // FORM TAMBAH / EDIT
  // ============================================================

  void showForm({ItemGaji? item}) {
    final bool isEdit = item != null;

    final namaController = TextEditingController(
      text: item?.namaItemGaji ?? '',
    );

    final noUrutController = TextEditingController(
      text: item?.noUrut.toString() ?? '',
    );

    int? kategoriId = item?.kategoriItemId;

    // Default kategori pertama saat tambah
    if (!isEdit && kategoriId == null && kategoriList.isNotEmpty) {
      kategoriId = int.tryParse(kategoriList.first['id'].toString());
    }

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
                    // ==================================================
                    // HEADER
                    // ==================================================

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit
                                ? Icons.edit_outlined
                                : Icons.add_card_outlined,
                            color: const Color(0xff1976D2),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Item Gaji' : 'Tambah Item Gaji',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Navigator.pop(modalContext);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // NAMA ITEM GAJI
                    // ==================================================
                    TextField(
                      controller: namaController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nama Item Gaji',
                        hintText: 'Contoh: Gaji Pokok',
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                          color: Color(0xff1976D2),
                        ),
                        filled: true,
                        fillColor: const Color(0xffF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // KATEGORI
                    // ==================================================
                    DropdownButtonFormField<int>(
                      value: kategoriId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        hintText: 'Pilih kategori',
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          color: Color(0xff1976D2),
                        ),
                        filled: true,
                        fillColor: const Color(0xffF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: kategoriList.map((kategori) {
                        final id = int.tryParse(kategori['id'].toString());

                        final nama =
                            kategori['nama_kategori']?.toString() ?? '-';

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(nama, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          kategoriId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // NO URUT
                    // ==================================================
                    TextField(
                      controller: noUrutController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'No. Urut',
                        hintText: 'Contoh: 1',
                        prefixIcon: const Icon(
                          Icons.format_list_numbered,
                          color: Color(0xff1976D2),
                        ),
                        filled: true,
                        fillColor: const Color(0xffF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // BUTTON
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final nama = namaController.text.trim();

                          final noUrut = int.tryParse(
                            noUrutController.text.trim(),
                          );

                          // Validasi nama
                          if (nama.isEmpty) {
                            _showMessage(
                              'Nama item gaji harus diisi',
                              Colors.red,
                            );
                            return;
                          }

                          // Validasi kategori
                          if (kategoriId == null) {
                            _showMessage('Silakan pilih kategori', Colors.red);
                            return;
                          }

                          // Validasi no urut
                          // if (noUrut == null || noUrut < 1) {
                          //   _showMessage(
                          //     'No. urut harus diisi dengan benar',
                          //     Colors.red,
                          //   );
                          //   return;
                          // }

                          // Tutup modal
                          Navigator.pop(modalContext);

                          if (isEdit) {
                            await updateItemGaji(
                              id: item.id,
                              nama: nama,
                              kategoriId: kategoriId!,
                              noUrut: 0,
                            );
                          } else {
                            await tambahItemGaji(
                              nama: nama,
                              kategoriId: kategoriId!,
                              noUrut: 0,
                            );
                          }
                        },
                        icon: Icon(isEdit ? Icons.save_outlined : Icons.add),
                        label: Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Item Gaji',
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
  // CONFIRM DELETE
  // ============================================================

  void confirmDelete(ItemGaji item) {
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
              Text('Hapus Item Gaji'),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            '"${item.namaItemGaji}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await deleteItemGaji(item.id);
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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Item Gaji',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Column(
        children: [
          // ========================================================
          // SEARCH
          // ========================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari item gaji...',
                prefixIcon: const Icon(Icons.search, color: Color(0xff1976D2)),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();

                          setState(() {});

                          getItemGaji();
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

          // ========================================================
          // TOTAL
          // ========================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              children: [
                Text(
                  '${data.length} Item Gaji',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),

                const Spacer(),

                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () {
                    getItemGaji(search: searchController.text);
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),

          // ========================================================
          // LIST
          // ========================================================
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                return getItemGaji(search: searchController.text);
              },
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
                          Icons.payments_outlined,
                          size: 60,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 15),
                        Center(
                          child: Text(
                            'Belum ada item gaji',
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
                        final item = data[index];

                        return _itemCard(item);
                      },
                    ),
            ),
          ),
        ],
      ),

      // ==========================================================
      // ADD BUTTON
      // ==========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showForm();
        },
        backgroundColor: const Color(0xff1976D2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  // ============================================================
  // ITEM CARD
  // ============================================================

  Widget _itemCard(ItemGaji item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ======================================================
            // NOMOR URUT
            // ======================================================

            Container(
              width: 45,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.payments_outlined,
                size: 24,
                color: Color(0xff1976D2),
              ),
            ),

            const SizedBox(width: 14),

            // ======================================================
            // INFO
            // ======================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaItemGaji,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.kategoriNama,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // MENU
            // ======================================================
            PopupMenuButton<String>(
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
}

// =================================================================
// MODEL ITEM GAJI
// =================================================================

class ItemGaji {
  final int id;
  final String namaItemGaji;
  final int kategoriItemId;
  final int noUrut;
  final String kategoriNama;

  ItemGaji({
    required this.id,
    required this.namaItemGaji,
    required this.kategoriItemId,
    required this.noUrut,
    required this.kategoriNama,
  });

  factory ItemGaji.fromJson(Map<String, dynamic> json) {
    final kategori = json['kategori_items'];

    return ItemGaji(
      id: int.tryParse(json['id'].toString()) ?? 0,

      namaItemGaji: json['nama_item_gaji']?.toString() ?? '-',

      kategoriItemId: int.tryParse(json['kategori_item_id'].toString()) ?? 0,

      noUrut: int.tryParse(json['no_urut'].toString()) ?? 0,

      kategoriNama: kategori is Map
          ? kategori['nama_kategori']?.toString() ?? '-'
          : '-',
    );
  }
}
