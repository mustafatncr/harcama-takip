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
      backgroundColor: const Color(0xFF071312), // Premium dark
      child: Column(
        children: [
          // -------------------------------------------------------
          // PREMIUM HEADER
          // -------------------------------------------------------
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                // Gradient arka plan
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
                // Blur efekti
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.05),
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
                          color: Colors.black.withOpacity(0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // -------------------------------------------------------
          // MENU ITEMS
          // -------------------------------------------------------
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
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
                    final result = await Navigator.pushNamed(context, '/kategoriler');

                    if (result == true && onCategoriesChanged != null) {
                      onCategoriesChanged!();
                    }
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.settings,
                  label: AppLocalizations.of(context)!.drawerSettings,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/ayarlar');
                  },
                ),

                const SizedBox(height: 16),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: Colors.white.withOpacity(0.08),
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------
          // FOOTER
          // -------------------------------------------------------
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "Harcama Takip • Premium",
              style: TextStyle(
                color: Colors.white.withOpacity(0.28),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PREMIUM DRAWER ITEM
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
