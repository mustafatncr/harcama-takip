import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../widgets/add_expense_sheet.dart';
import '../services/storage_service.dart';
import '../services/category_service.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _items = [];
  List<Category> _categories = [];
  String _selectedCategory =
      ui.PlatformDispatcher.instance.locale.languageCode == "tr"
          ? "Tümü"
          : "All";

  String _sortBy = "";
  bool _isDescending = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCategories();
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadExpenses();
    setState(() => _items.addAll(data));
  }

  Future<void> _loadCategories() async {
    final data = await CategoryService.loadCategories();
    setState(() {
      _categories = data;
    });
  }

  Future<void> _saveData() async {
    await StorageService.saveExpenses(_items);
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

  String _formatTL(num v) {
    final dp = v % 1 == 0 ? 0 : 2; // tam sayıysa .00 gösterme
    return NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: dp,
    ).format(v);
  }

  num get _total {
    final list = _selectedCategory == AppLocalizations.of(context)!.filterAll
        ? _items
        : _items.where((e) => e.category == _selectedCategory);
    return list.fold<num>(0, (sum, e) => sum + e.amount);
  }

  Future<void> _openAddSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddExpenseSheet(),
    );

    if (result != null) {
      final expense = Expense(
        amount: (result['amount'] as num).toDouble(),
        category: result['category'] as String,
        note: result['note'] as String?,
        date: result['date'] as DateTime,
        icon: result['icon'] != null
            ? IconData(result['icon'] as int, fontFamily: 'MaterialIcons')
            : null,
      );

      setState(() => _items.insert(0, expense));
      await _saveData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Eklendi: ${_formatTL(expense.amount)} • "
            "${expense.category} • ${_formatDate(expense.date)}",
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _items.isNotEmpty;

    // 🔹 Dinamik kategori listesi
    final categoryNames = [
      AppLocalizations.of(context)!.filterAll,
      ..._categories.map((c) => c.name)
    ];

    final filteredItems =
        _selectedCategory == AppLocalizations.of(context)!.filterAll
            ? _items
            : _items.where((e) => e.category == _selectedCategory).toList();

    final sortedItems = [...filteredItems];

    if (_sortBy.startsWith("Tarih")) {
      sortedItems.sort(
        (a, b) =>
            _isDescending ? b.date.compareTo(a.date) : a.date.compareTo(b.date),
      );
    } else if (_sortBy.startsWith("Tutar")) {
      sortedItems.sort(
        (a, b) => _isDescending
            ? b.amount.compareTo(a.amount)
            : a.amount.compareTo(b.amount),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == "Tarih" || value == "Tutar") {
                  _sortBy = value == "Tarih"
                      ? "Tarih (Yeni > Eski)"
                      : "Tutar (Yüksek > Düşük)";
                  _isDescending = true;
                } else if (value == "Tarih (Eski > Yeni)") {
                  _sortBy = "Tarih (Eski > Yeni)";
                  _isDescending = false;
                } else if (value == "Tutar (Düşük > Yüksek)") {
                  _sortBy = "Tutar (Düşük > Yüksek)";
                  _isDescending = false;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "Tarih",
                child: Text(AppLocalizations.of(context)!.sortDateDesc),
              ),
              PopupMenuItem(
                value: "Tarih (Eski > Yeni)",
                child: Text(AppLocalizations.of(context)!.sortDateAsc),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: "Tutar",
                child: Text(AppLocalizations.of(context)!.sortAmountDesc),
              ),
              PopupMenuItem(
                value: "Tutar (Düşük > Yüksek)",
                child: Text(AppLocalizations.of(context)!.sortAmountAsc),
              ),
            ],
            icon: const Icon(Icons.sort),
            tooltip: "Sıralama",
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.homeAddExpense),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: hasData
            ? Column(
                children: [
                  // 🔹 Dinamik kategori menüsü
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        for (final category in categoryNames)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() => _selectedCategory = category);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Toplam kutusu
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Toplam",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _formatTL(_total),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Harcama listesi
                  Expanded(
                    child: ListView.separated(
                      itemCount: sortedItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final e = sortedItems[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.15),
                            child: Icon(
                              e.icon ?? Icons.receipt_long,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            "${_formatTL(e.amount)} • ${e.category}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            (e.note?.trim().isEmpty ?? true)
                                ? _formatDate(e.date)
                                : "${_formatDate(e.date)} • ${e.note}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() => _items.remove(e));
                              _saveData();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : _EmptyState(onAdd: _openAddSheet),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("📭"),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.emptyExpenses,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.emptyExpensesHint,
            style: TextStyle(color: Theme.of(context).hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
