import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../screens/grafik_ekrani.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onCategoriesChanged;

  const AppDrawer({super.key, this.onCategoriesChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF071312),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF00C6A9),
                        Color(0xFF009E88),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),

                // İçerik
                Positioned(
                  left: 20,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.drawerTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.drawerSubtitle,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                _drawerItem(
                  context,
                  icon: Icons.home,
                  label: AppLocalizations.of(context)!.drawerHome,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.bar_chart,
                  label: AppLocalizations.of(context)!.drawerCharts,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GrafikEkrani()),
                    );
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.category,
                  label: AppLocalizations.of(context)!.drawerCategories,
                  onTap: () async {
                    Navigator.pop(context);
                    final result =
                        await Navigator.pushNamed(context, '/kategoriler');

                    if (result == true && onCategoriesChanged != null) {
                      onCategoriesChanged!();
                    }
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.settings,
                  label: AppLocalizations.of(context)!.drawerSettings,
                  onTap: () async {
                    Navigator.pop(context); // Drawer'ı kapat
                    final result =
                        await Navigator.pushNamed(context, '/ayarlar');
                    if (result == true) {
                      // ana ekrandaki verileri temizle
                      if (onCategoriesChanged != null) onCategoriesChanged!();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 34),
            child: Text(
              "by MustApp Studio",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.28),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
