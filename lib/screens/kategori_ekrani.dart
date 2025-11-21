import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class KategoriEkrani extends StatefulWidget {
  const KategoriEkrani({super.key});

  @override
  State<KategoriEkrani> createState() => _KategoriEkraniState();
}

class _KategoriEkraniState extends State<KategoriEkrani> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories(context);
    });
  }

  Future<void> _loadCategories(BuildContext context) async {
    final loaded = await CategoryService.loadCategories(context);
    setState(() => _categories = loaded);
  }

  Future<void> _saveCategories() async {
    await CategoryService.saveCategories(_categories);
  }

  Future<void> _addCategoryDialog() async {
    final nameController = TextEditingController();
    IconData? selectedIcon = Icons.category;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.categoryAddDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.categoryNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final icon in _iconList)
                      GestureDetector(
                        onTap: () {
                          setStateDialog(() => selectedIcon = icon);
                        },
                        child: CircleAvatar(
                          backgroundColor: selectedIcon == icon
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.grey.shade200,
                          child: Icon(
                            icon,
                            color: selectedIcon == icon
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.buttonCancel),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  setState(() {
                    _categories.add(Category(name: name, icon: selectedIcon!));
                  });
                  _saveCategories();

                  Navigator.pop(context, true); // → Önemli
                },
                child: Text(AppLocalizations.of(context)!.buttonAdd),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteCategory(int index) {
    final deleted = _categories[index];
    setState(() => _categories.removeAt(index));
    _saveCategories();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${deleted.name} • ${AppLocalizations.of(context)!.categoryDeleted}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // ← En kritik satır
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.categoryTitle),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addCategoryDialog,
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.categoryAddButton),
        ),
        body: _categories.isEmpty
            ? Center(
                child: Text(
                  AppLocalizations.of(context)!.categoryEmpty,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = _categories[i];
                  return ListTile(
                    leading: Icon(
                      c.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(c.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteCategory(i),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

final List<IconData> _iconList = [
  Icons.restaurant,
  Icons.directions_car,
  Icons.receipt_long,
  Icons.shopping_cart,
  Icons.home,
  Icons.flight_takeoff,
  Icons.coffee,
  Icons.fastfood,
  Icons.work,
  Icons.local_hospital,
  Icons.school,
  Icons.sports_soccer,
  Icons.pets,
  Icons.local_mall,
  Icons.local_gas_station,
];
