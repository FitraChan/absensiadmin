import 'package:absensiadmin/master_data/aturan_potongan/aturan_potongan_page.dart';
import 'package:absensiadmin/master_data/item_gaji/item_gaji_page.dart';
import 'package:absensiadmin/master_data/jam_kerja/jam_kerja_page.dart';
import 'package:absensiadmin/master_data/karyawan/karyawan_page.dart';
import 'package:absensiadmin/master_data/periode_gaji/periode_gaji_page.dart';
import 'package:absensiadmin/master_data/set_payroll/set_payroll_page.dart';
import 'package:flutter/material.dart';

class MasterDataPage extends StatelessWidget {
  const MasterDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Data'), elevation: 0),

      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 1;

          if (constraints.maxWidth >= 1000) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth >= 600) {
            crossAxisCount = 2;
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: GridView.count(
              crossAxisCount: crossAxisCount,

              crossAxisSpacing: 18,
              mainAxisSpacing: 18,

              childAspectRatio: 1.5,

              children: [
                // =========================
                // DATA KARYAWAN
                // =========================
                _MasterMenuCard(
                  title: 'Data Karyawan',
                  subtitle: 'Kelola data karyawan',
                  icon: Icons.people_alt_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DataKaryawanPage(),
                      ),
                    );
                  },
                ),

                // =========================
                // DATA JAM KERJA
                // =========================
                _MasterMenuCard(
                  title: 'Data Jam Kerja',
                  subtitle: 'Kelola shift dan jam kerja',
                  icon: Icons.schedule_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JamKerjaPage(),
                      ),
                    );
                  },
                ),

                // =========================
                // PERIODE GAJI
                // =========================
                _MasterMenuCard(
                  title: 'Periode Gaji',
                  subtitle: 'Kelola periode penggajian',
                  icon: Icons.payments_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PeriodeGajiPage(),
                      ),
                    );
                  },
                ),

                _MasterMenuCard(
                  title: 'Setting Gaji',
                  subtitle: 'Atur item dan nominal payroll',
                  icon: Icons.request_quote_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetPayrollPage(),
                      ),
                    );
                  },
                ),

                // =========================
                // ITEM GAJI
                // =========================
                _MasterMenuCard(
                  title: 'Item Gaji',
                  subtitle: 'Kelola komponen dan kategori gaji',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ItemGajiPage(),
                      ),
                    );
                  },
                ),

                // =========================
                // ATURAN POTONGAN
                // =========================
                _MasterMenuCard(
                  title: 'Aturan Potongan',
                  subtitle: 'Atur ketentuan dan nilai potongan gaji',
                  icon: Icons.rule_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AturanPotonganPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MasterMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MasterMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(22),

          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.primary
                      .withOpacity(0.10),
                ),

                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
