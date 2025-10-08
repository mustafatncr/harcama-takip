import 'package:flutter/material.dart';
import '../screens/ayarlar_ekrani.dart';
import '../screens/grafik_ekrani.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "💰 Harcama Takip",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text("Kişisel finansını kolayca yönet"),
              ],
            ),
          ),

          // 🔹 Ana Sayfa
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Ana Sayfa"),
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),

          // 🔹 Grafikler
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Grafikler"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GrafikEkrani()),
              );
            },
          ),

          // 🔹 Kategoriler
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text("Kategoriler"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/kategoriler');
            },
          ),

          // 🔹 Ayarlar
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Ayarlar"),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
              Navigator.pushNamed(context, '/ayarlar'); // route üzerinden git
            },
          ),
        ],
      ),
    );
  }
}
