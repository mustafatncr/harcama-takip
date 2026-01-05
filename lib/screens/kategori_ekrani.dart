import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import 'package:harcama_takip/services/storage_service.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../utils/icon_map.dart';

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
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    final loaded = await CategoryService.loadCategories();
    setState(() => _categories = loaded);
  }

  Future<void> _saveCategories() async {
    await CategoryService.saveCategories(_categories);
  }

  Future<void> _openCategoryDialog({Category? edit, int? editIndex}) async {
    final oldCategoryName = edit?.name;
    final nameController = TextEditingController(text: edit?.name ?? "");

    String selectedIconName = edit?.iconName ?? iconMap.keys.first;

    final primary = Theme.of(context).colorScheme.primary;

    final dialogFormKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2624),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          edit == null
                              ? AppLocalizations.of(context)!
                                  .categoryAddDialogTitle
                              : AppLocalizations.of(context)!
                                  .categoryEditDialogTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      /// --- VALIDATOR EKLENMİŞ TEXTFORMFIELD ---
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return AppLocalizations.of(context)!
                                .categoryNameRequired;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF071312),
                          hintText:
                              AppLocalizations.of(context)!.categoryNameLabel,
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        AppLocalizations.of(context)!.categorySelectIcon,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final entry in iconMap.entries)
                            GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  selectedIconName = entry.key;
                                });
                              },
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: selectedIconName == entry.key
                                      ? primary.withValues(alpha: 0.18)
                                      : const Color(0xFF071312),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selectedIconName == entry.key
                                        ? primary
                                        : Colors.white12,
                                  ),
                                ),
                                child: Icon(
                                  entry.value,
                                  color: selectedIconName == entry.key
                                      ? primary
                                      : Colors.white54,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.buttonCancel,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// --- BUTON ARTIK VALIDASYONU TETİKLİYOR ---
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              if (!dialogFormKey.currentState!.validate()) {
                                return;
                              }

                              final name = nameController.text.trim();
                              final isEdit = edit != null;
                              final nameChanged =
                                  isEdit && oldCategoryName != name;

                              if (isEdit && nameChanged) {
                                await StorageService.updateExpensesCategory(
                                  oldName: oldCategoryName!,
                                  newName: name,
                                  newIconName: selectedIconName,
                                );
                              }

                              setState(() {
                                if (edit != null) {
                                  _categories[editIndex!] = Category(
                                    name: name,
                                    iconName: selectedIconName,
                                  );
                                } else {
                                  _categories.add(
                                    Category(
                                      name: name,
                                      iconName: selectedIconName,
                                    ),
                                  );
                                }
                              });

                              _saveCategories();
                              Navigator.pop(context);
                            },
                            child: Text(
                              edit == null
                                  ? AppLocalizations.of(context)!.buttonAdd
                                  : AppLocalizations.of(context)!.buttonSave,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteCategory(int index) async {
    final loc = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF0F2624),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.categoryDeleteTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.categoryDeleteMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      loc.buttonCancel,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(
                      loc.buttonDelete,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      _deleteCategory(index);
    }
  }

  Future<void> _deleteCategory(int index) async {
    final deleted = _categories[index];

    // 🔥 Önce bu kategoriye bağlı harcamaları sil
    await StorageService.deleteExpensesByCategory(deleted.name);

    // 🔥 Sonra kategoriyi sil
    setState(() => _categories.removeAt(index));
    await _saveCategories();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F2624),
        content: Text(
          "${deleted.name} • ${AppLocalizations.of(context)!.categoryDeleted}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Category c, int index) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2624),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(
            iconMap[c.iconName] ?? Icons.category,
            size: 26,
            color: primary,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              c.name,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            onPressed: () => _openCategoryDialog(edit: c, editIndex: index),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDeleteCategory(index),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.categoryTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () => _openCategoryDialog(),
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.categoryAddButton),
        ),
        body: _categories.isEmpty
            ? Center(
                child: Text(
                  AppLocalizations.of(context)!.categoryEmpty,
                  style: const TextStyle(fontSize: 16, color: Colors.white60),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) =>
                    _buildCategoryItem(_categories[i], i),
              ),
      ),
    );
  }
}
