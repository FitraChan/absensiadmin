import 'dart:convert';

import 'package:absensiadmin/api/api.dart';
import 'package:absensiadmin/master_data/set_payroll/set_payroll_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SetPayrollPage extends StatefulWidget {
  const SetPayrollPage({super.key});

  @override
  State<SetPayrollPage> createState() => _SetPayrollPageState();
}

class _SetPayrollPageState extends State<SetPayrollPage> {
  bool isLoading = true;

  List<SetPayroll> data = [];
  List<SetPayroll> filteredData = [];

  final TextEditingController searchController = TextEditingController();

  String selectedDepartemen = 'Semua';

  @override
  void initState() {
    super.initState();
    getSetPayroll();
    getDepartemen();
    getItemGaji();

    searchController.addListener(() {
      filterData();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getSetPayroll({int? departemenId}) async {
    setState(() {
      isLoading = true;
    });

    try {
      String endpoint = 'payrollSettingAdmin';

      // Jika departemen dipilih, kirim ID ke API
      if (departemenId != null) {
        endpoint += '?departemen_id=$departemenId';
      }

      final response = await Network().getData(endpoint);

      debugPrint('==============================');
      debugPrint('GET SET PAYROLL');
      debugPrint('ENDPOINT : $endpoint');
      debugPrint('STATUS   : ${response.statusCode}');
      debugPrint('BODY     : ${response.body}');
      debugPrint('==============================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final List list = body['data'] ?? [];

          setState(() {
            data = list
                .map((e) => SetPayroll.fromJson(Map<String, dynamic>.from(e)))
                .toList();

            filteredData = data;
          });
        }
      }
    } catch (e) {
      debugPrint('ERROR GET SET PAYROLL: $e');

      if (mounted) {
        _showMessage('Gagal mengambil data payroll', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterData() {
    final keyword = searchController.text.toLowerCase().trim();

    setState(() {
      filteredData = data.where((item) {
        final cocokSearch =
            item.itemGajiNama.toLowerCase().contains(keyword) ||
            item.departemenNama.toLowerCase().contains(keyword);

        final cocokDepartemen =
            selectedDepartemen == 'Semua' ||
            item.departemenNama == selectedDepartemen;

        return cocokSearch && cocokDepartemen;
      }).toList();
    });
  }

  List<Map<String, dynamic>> departemenList = [];

  Future<void> getDepartemen() async {
    try {
      final response = await Network().getData('getDepartemen');

      debugPrint('==============================');
      debugPrint('GET DEPARTEMEN');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('==============================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] is List) {
          setState(() {
            departemenList = List<Map<String, dynamic>>.from(body['data']);
          });
        }
      }
    } catch (e) {
      debugPrint('ERROR GET DEPARTEMEN: $e');
    }
  }

  List<Map<String, dynamic>> itemGajiList = [];

  Future<void> getItemGaji() async {
    try {
      final response = await Network().getData('getItemGaji');

      debugPrint('==============================');
      debugPrint('GET ITEM GAJI');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY   : ${response.body}');
      debugPrint('==============================');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] is List) {
          setState(() {
            itemGajiList = List<Map<String, dynamic>>.from(body['data']);
          });
        }
      }
    } catch (e) {
      debugPrint('ERROR GET ITEM GAJI: $e');
    }
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1976D2),
        foregroundColor: Colors.white,
        title: const Text(
          'Set Payroll',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff1976D2),
        foregroundColor: Colors.white,
        onPressed: () {
          showForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),

      body: RefreshIndicator(
        onRefresh: getSetPayroll,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _header(),
                  Expanded(
                    child: filteredData.isEmpty ? _emptyData() : _listData(),
                  ),
                ],
              ),
      ),
    );
  }

  int? selectedDepartemenId;
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // =========================
          // SEARCH + FILTER
          // =========================
          Row(
            children: [
              // =========================
              // SEARCH
              // =========================
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari item gaji...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              filterData();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xffF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // =========================
              // FILTER DEPARTEMEN
              // =========================
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<int?>(
                  value: selectedDepartemenId,
                  isExpanded: true,

                  decoration: InputDecoration(
                    hintText: 'Semua Departemen',
                    prefixIcon: const Icon(
                      Icons.business_outlined,
                      color: Color(0xff1976D2),
                    ),
                    filled: true,
                    fillColor: const Color(0xffF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  items: [
                    // =========================
                    // SEMUA DEPARTEMEN
                    // =========================
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Semua Departemen'),
                    ),

                    // =========================
                    // DATA DARI API
                    // =========================
                    ...departemenList.map((departemen) {
                      return DropdownMenuItem<int?>(
                        value: int.tryParse(departemen['id'].toString()),
                        child: Text(
                          departemen['nama_departement'].toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],

                  onChanged: (value) {
                    setState(() {
                      selectedDepartemenId = value;
                    });

                    getSetPayroll(departemenId: value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =========================
          // JUMLAH DATA
          // =========================
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 20,
                color: Color(0xff1976D2),
              ),

              const SizedBox(width: 8),

              Text(
                '${filteredData.length} item payroll',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listData() {
    final Map<String, List<SetPayroll>> grouped = {};

    for (final item in filteredData) {
      grouped.putIfAbsent(item.departemenNama, () => []);

      grouped[item.departemenNama]!.add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return _departemenCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _departemenCard(String departemen, List<SetPayroll> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xffEAF3FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xff1976D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        departemen,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${items.length} item gaji',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ...items.map((item) => _payrollItem(item)),
        ],
      ),
    );
  }

  Widget _payrollItem(SetPayroll item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffEEEEEE))),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xff1976D2),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemGajiNama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatRupiah(item.nominal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1976D2),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Edit',
            onPressed: () {
              showForm(item: item);
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.orange),
          ),

          IconButton(
            tooltip: 'Hapus',
            onPressed: () {
              deletePayroll(item);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _emptyData() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(Icons.payments_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'Belum ada setting payroll',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            'Tambahkan item payroll untuk departemen',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  void showForm({SetPayroll? item}) {
    int? departemenId = item?.departemenId;
    int? itemGajiId = item?.itemGajiId;

    final nominalController = TextEditingController(
      text: item == null ? '' : item.nominal.toStringAsFixed(0),
    );

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    item == null ? 'Tambah Set Payroll' : 'Edit Set Payroll',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Departemen',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  // Nanti diisi dari API departemen
                  DropdownButtonFormField<int>(
                    value: departemenId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      // labelText: 'Departemen',
                      hintText: 'Pilih departemen',
                      prefixIcon: const Icon(
                        Icons.business_outlined,
                        color: Color(0xff1976D2),
                      ),
                      filled: true,
                      fillColor: const Color(0xffF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    items: departemenList.map((departemen) {
                      return DropdownMenuItem<int>(
                        value: int.tryParse(departemen['id'].toString()),
                        child: Text(
                          departemen['nama_departement']?.toString() ?? '-',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setModalState(() {
                        departemenId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Item Gaji',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  // Nanti diisi dari API item gaji
                  DropdownButtonFormField<int>(
                    value: itemGajiId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      // labelText: 'Item Gaji',
                      hintText: 'Pilih item gaji',
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
                    items: itemGajiList.map((item) {
                      return DropdownMenuItem<int>(
                        value: int.tryParse(item['id'].toString()),
                        child: Text(
                          item['nama_item_gaji']?.toString() ?? '-',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        itemGajiId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Nominal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 500000',
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: const Color(0xffF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        // =========================
                        // VALIDASI
                        // =========================
                        if (departemenId == null) {
                          _showMessage('Silakan pilih departemen', Colors.red);
                          return;
                        }

                        if (itemGajiId == null) {
                          _showMessage('Silakan pilih item gaji', Colors.red);
                          return;
                        }

                        if (nominalController.text.trim().isEmpty) {
                          _showMessage('Nominal harus diisi', Colors.red);
                          return;
                        }

                        try {
                          final nominal = nominalController.text
                              .replaceAll('.', '')
                              .replaceAll(',', '')
                              .trim();

                          final Map<String, dynamic> body = {
                            'departemen_id': departemenId,
                            'item_gaji_id': itemGajiId,
                            'nominal': nominal,
                          };

                          debugPrint('==============================');
                          debugPrint(
                            item == null
                                ? 'POST SET PAYROLL'
                                : 'PUT UPDATE SET PAYROLL',
                          );
                          debugPrint('ID    : ${item?.id}');
                          debugPrint('BODY  : $body');
                          debugPrint('==============================');

                          FocusScope.of(context).unfocus();

                          late final response;

                          // =========================
                          // TAMBAH
                          // =========================
                          if (item == null) {
                            response = await Network().getData_post(
                              body,
                              'payrollSettingAdmin',
                            );
                          }
                          // =========================
                          // UPDATE
                          // =========================
                          else {
                            response = await Network().putData(
                              body,
                              'payrollSettingAdmin/${item.id}',
                            );
                          }

                          debugPrint('==============================');
                          debugPrint('RESPONSE SET PAYROLL');
                          debugPrint('STATUS : ${response.statusCode}');
                          debugPrint('BODY   : ${response.body}');
                          debugPrint('==============================');

                          final responseBody = jsonDecode(response.body);

                          // Laravel store = 201
                          // Laravel update biasanya = 200
                          if ((response.statusCode == 201 ||
                                  response.statusCode == 200) &&
                              responseBody['success'] == true) {
                            Navigator.pop(context);

                            _showMessage(
                              responseBody['message'] ??
                                  (item == null
                                      ? 'Set payroll berhasil ditambahkan'
                                      : 'Set payroll berhasil diperbarui'),
                              Colors.green,
                            );

                            // Refresh data sesuai departemen yang sedang dipilih
                            await getSetPayroll(
                              departemenId: selectedDepartemenId,
                            );
                          } else {
                            _showMessage(
                              responseBody['message'] ??
                                  (item == null
                                      ? 'Gagal menambahkan set payroll'
                                      : 'Gagal memperbarui set payroll'),
                              Colors.red,
                            );
                          }
                        } catch (e) {
                          debugPrint('ERROR SAVE SET PAYROLL: $e');

                          _showMessage('Terjadi kesalahan: $e', Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        item == null ? 'Simpan' : 'Update',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> deletePayroll(SetPayroll item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Payroll'),
          content: Text('Yakin ingin menghapus "${item.itemGajiNama}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final response = await Network().deleteData(
        'payrollSettingAdmin/${item.id}',
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        _showMessage('Payroll berhasil dihapus', Colors.green);

        getSetPayroll();
      } else {
        _showMessage(body['message'] ?? 'Gagal menghapus data', Colors.red);
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan', Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
