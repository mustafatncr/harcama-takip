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

  Future<void> _openCategoryDialog({Category? edit, int? editIndex}) async {
    final nameController = TextEditingController(text: edit?.name ?? "");
    IconData selectedIcon = edit?.icon ?? Icons.category;

    await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
              edit == null
                  ? AppLocalizations.of(context)!.categoryAddDialogTitle
                  : AppLocalizations.of(context)!.categoryEditDialogTitle,
            ),
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
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.buttonCancel),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  setState(() {
                    if (edit != null) {
                      _categories[editIndex!] =
                          Category(name: name, icon: selectedIcon);
                    } else {
                      _categories.add(Category(name: name, icon: selectedIcon));
                    }
                  });

                  _saveCategories();
                  Navigator.pop(context, true);
                },
                child: Text(edit == null
                    ? AppLocalizations.of(context)!.buttonAdd
                    : AppLocalizations.of(context)!.buttonSave),
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
    return PopScope(
      canPop: false, // Geri tuşunu biz kontrol edeceğiz
      onPopInvokedWithResult: (didPop, result) {
        // Kullanıcı geri tuşuna bastıysa
        if (!didPop) {
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.categoryTitle),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openCategoryDialog(),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _openCategoryDialog(edit: c, editIndex: i);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteCategory(i),
                        ),
                      ],
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
