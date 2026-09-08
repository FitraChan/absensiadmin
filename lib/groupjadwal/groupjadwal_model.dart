class GroupJadwal {
  final int? id;
  final String namaGrup;
  final String keterangan;

  GroupJadwal({this.id, required this.namaGrup, required this.keterangan});

  factory GroupJadwal.fromJson(Map<String, dynamic> json) {
    return GroupJadwal(
      id: json['id'],
      namaGrup: json['nama_grup']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'nama_grup': namaGrup, 'keterangan': keterangan};
  }
}
