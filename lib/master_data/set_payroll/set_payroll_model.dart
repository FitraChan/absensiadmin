class SetPayroll {
  final int id;
  final int departemenId;
  final int itemGajiId;
  final double nominal;

  final String departemenNama;
  final String itemGajiNama;

  SetPayroll({
    required this.id,
    required this.departemenId,
    required this.itemGajiId,
    required this.nominal,
    required this.departemenNama,
    required this.itemGajiNama,
  });

  factory SetPayroll.fromJson(Map<String, dynamic> json) {
    final departement = json['departement'];
    final itemGaji = json['item_gaji'] ?? json['itemGaji'];

    return SetPayroll(
      id: int.tryParse(json['id'].toString()) ?? 0,
      departemenId: int.tryParse(json['departemen_id'].toString()) ?? 0,
      itemGajiId: int.tryParse(json['item_gaji_id'].toString()) ?? 0,
      nominal: double.tryParse(json['nominal'].toString()) ?? 0,

      departemenNama: departement is Map
          ? (departement['nama'] ??
                    departement['nama_departemen'] ??
                    departement['name'] ??
                    '-')
                .toString()
          : '-',

      itemGajiNama: itemGaji is Map
          ? (itemGaji['nama_item_gaji'] ??
                    itemGaji['nama_item_gaji'] ??
                    itemGaji['nama_item_gaji'] ??
                    '-')
                .toString()
          : '-',
    );
  }
}
