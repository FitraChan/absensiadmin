class Karyawan {
  final int id;
  final String nama;
  final String email;
  final String departemen;
  final String jabatan;

  Karyawan({
    required this.id,
    required this.nama,
    required this.email,
    required this.departemen,
    required this.jabatan,
  });

  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      id: json['id'] ?? 0,
      nama: json['nama_lengkap'] ?? '-',
      email: json['email'] ?? '-',
      departemen: json['departement']?['nama_departement'] ?? '-',
      jabatan: json['jabatan']?['nama_jabatan'] ?? '-',
    );
  }
}
