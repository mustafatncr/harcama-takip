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

  // ---------------------------------------------------------------------
  // PREMIUM POPUP
  // ---------------------------------------------------------------------
  Future<void> _openCategoryDialog({Category? edit, int? editIndex}) async {
    final nameController = TextEditingController(text: edit?.name ?? "");
    IconData selectedIcon = edit?.icon ?? Icons.category;
    final primary = Theme.of(context).colorScheme.primary;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------- TITLE -------
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

                    // ------- PREMIUM INPUT -------
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
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

                    // ------- LABEL -------
                    Text(
                      AppLocalizations.of(context)!.categorySelectIcon,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ------- ICON GRID -------
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final icon in _iconList)
                          GestureDetector(
                            onTap: () {
                              setStateDialog(() => selectedIcon = icon);
                            },
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: selectedIcon == icon
                                    ? primary.withOpacity(0.18)
                                    : const Color(0xFF071312),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selectedIcon == icon
                                      ? primary
                                      : Colors.white12,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: selectedIcon == icon
                                    ? primary
                                    : Colors.white54,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // ------- BUTTONS -------
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
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;

                            setState(() {
                              if (edit != null) {
                                _categories[editIndex!] = Category(
                                  name: name,
                                  icon: selectedIcon,
                                );
                              } else {
                                _categories.add(
                                  Category(name: name, icon: selectedIcon),
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
            );
          },
        );
      },
    );
  }

  // DELETE
  void _deleteCategory(int index) {
    final deleted = _categories[index];
    setState(() => _categories.removeAt(index));
    _saveCategories();

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

  // ---------------------------------------------------------------------
  // PREMIUM CATEGORY ITEM CARD
  // ---------------------------------------------------------------------
  Widget _buildCategoryItem(Category c, int index) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2624),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(c.icon, size: 26, color: primary),
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
            onPressed: () => _deleteCategory(index),
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

// ICON LIST
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
