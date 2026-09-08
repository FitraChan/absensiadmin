import 'package:absensiadmin/absensi/absen.dart';
import 'package:absensiadmin/groupjadwal/groupjadwal.dart';
import 'package:absensiadmin/karyawanAbsen/karyawan_absen_page.dart';
import 'package:absensiadmin/lembur/lemburPage.dart';
import 'package:absensiadmin/master_data/master_data_page.dart';
import 'package:absensiadmin/payroll/payroll.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // =====================================================
              // HEADER BIRU
              // =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 35),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1565C0),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'Admin Absensi',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 48,
                          height: 48,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: IconButton(
                            onPressed: () {
                              // Profile
                            },
                            icon: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Selamat Datang 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Kelola absensi dan payroll karyawan dengan mudah.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // CONTENT
              // =====================================================
              Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // STATISTIK
                    // =================================================

                    const Text(
                      'Ringkasan Hari Ini',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 15),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;

                        if (constraints.maxWidth >= 1000) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 2;
                        }

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 2.5,

                          children: const [
                            _StatCard(
                              title: 'Total Karyawan',
                              value: '120',
                              icon: Icons.people_alt_outlined,
                            ),

                            _StatCard(
                              title: 'Hadir',
                              value: '98',
                              icon: Icons.check_circle_outline,
                            ),

                            _StatCard(
                              title: 'Tidak Hadir',
                              value: '22',
                              icon: Icons.cancel_outlined,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // MENU
                    // =================================================
                    const Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 15),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;

                        if (constraints.maxWidth >= 1000) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 2;
                        }

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),

                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,

                          childAspectRatio: 1.35,

                          children: [
                            _MenuCard(
                              title: 'Absensi',
                              subtitle: 'Kelola dan pantau absensi karyawan',
                              icon: Icons.access_time_rounded,

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Absensi(),
                                  ),
                                );
                              },
                            ),

                            _MenuCard(
                              title: 'Payroll',
                              subtitle: 'Kelola penggajian dan pembayaran',
                              icon: Icons.account_balance_wallet_outlined,

                              onTap: () {
                                // Payroll

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Payroll(),
                                  ),
                                );
                              },
                            ),

                            _MenuCard(
                              title: 'Lembur',
                              subtitle: 'Kelola data lembur karyawan',
                              icon: Icons.work_outline,

                              onTap: () {
                                // Lembur

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LemburPage(),
                                  ),
                                );
                              },
                            ),

                            // =========================
                            // KARYAWAN ABSEN
                            // =========================
                            _MenuCard(
                              title: 'Karyawan Absen',
                              subtitle: 'Kelola izin, sakit, alpha dan cuti',
                              icon: Icons.event_available_outlined,

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const KaryawanAbsenPage(),
                                  ),
                                );
                              },
                            ),

                            _MenuCard(
                              title: 'Group Jadwal',
                              subtitle:
                                  'Kelola group dan jadwal kerja karyawan',
                              icon: Icons.calendar_month_outlined,

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GroupJadwalPage(),
                                  ),
                                );
                              },
                            ),

                            // =========================
                            // MASTER DATA
                            // =========================
                            _MenuCard(
                              title: 'Master Data',
                              subtitle: 'Kelola data dasar sistem',
                              icon: Icons.storage_outlined,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MasterDataPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// STAT CARD
// =============================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.people_alt_outlined,
              color: Color(0xFF1976D2),
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// MENU CARD
// =============================================================

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),

      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(22),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  ),

                  borderRadius: BorderRadius.circular(17),
                ),

                child: Icon(icon, color: Colors.white, size: 30),
              ),

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Text(
                    'Buka Menu',
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: 30,
                    height: 30,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
