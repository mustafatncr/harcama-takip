import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../widgets/add_expense_sheet.dart';
import '../services/storage_service.dart';
import '../services/category_service.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SortField { date, amount }

enum SortOrder { desc, asc }

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _items = [];
  List<Category> _categories = [];

  String _selectedCategory = "";
  String _currencyCode = "TRY";

  SortField _sortField = SortField.date;
  SortOrder _sortOrder = SortOrder.desc;

  @override
  void initState() {
    super.initState();
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCategories();
      await _loadCurrency();
      setState(() {
        _selectedCategory = AppLocalizations.of(context)!.filterAll;
      });
    });
  }

  Future<void> _loadCurrency() async {
    final saved = await StorageService.loadCurrency();
    setState(() => _currencyCode = saved);
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadExpenses();
    setState(() {
      _items
        ..clear()
        ..addAll(data);
    });
  }

  Future<void> _loadCategories() async {
    final data = await CategoryService.loadCategories();
    setState(() => _categories = data);
  }

  Future<void> _saveData() async {
    await StorageService.saveExpenses(_items);
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

  String _currencySymbol(String code) {
    switch (code) {
      case "USD":
        return "\$";
      case "EUR":
        return "€";
      case "GBP":
        return "£";
      case "TRY":
      default:
        return "₺";
    }
  }

  String _formatCurrency(num value, String code) {
    final symbol = _currencySymbol(code);
    final digits = value % 1 == 0 ? 0 : 2;
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: digits,
    ).format(value);
  }

  Map<String, num> get _totalsByCurrency {
    final filtered =
        _selectedCategory == AppLocalizations.of(context)!.filterAll
            ? _items
            : _items.where((e) => e.category == _selectedCategory).toList();

    final Map<String, num> result = {};

    for (var e in filtered) {
      result[e.currency] = (result[e.currency] ?? 0) + e.amount;
    }
    return result;
  }

  String get _formattedTotal {
    final parts =
        _totalsByCurrency.entries.map((e) => _formatCurrency(e.value, e.key));
    return parts.join("  +  ");
  }

  Future<void> _openAddSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseSheet(currencyCode: _currencyCode),
    );

    if (result != null) {
      final expense = Expense(
        amount: (result['amount'] as num).toDouble(),
        category: result['category'] as String,
        note: result['note'] as String?,
        date: result['date'] as DateTime,
        currency: result['currency'],
        iconCode: result['iconCode'] as int?,
        iconFamily: result['iconFamily'] as String?,
      );

      setState(() => _items.insert(0, expense));
      await _saveData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppLocalizations.of(context)!.expenseAdded}: "
            "${_formatCurrency(expense.amount, expense.currency)} • "
            "${expense.category} • ${_formatDate(expense.date)}",
          ),
        ),
      );
    }
  }

  Widget _buildFilterChip(String label, bool selected) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? primary : primary.withValues(alpha: 0.25),
            width: 1.4,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : const Color(0xFFD5F3EE),
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    final cardColor = Theme.of(context).colorScheme.surface;
    const borderColor = Color(0xFF1C3A37);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.totalLabel,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            _formattedTotal,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense e) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2624),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1C3A37),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: primary.withValues(alpha: 0.30),
                width: 1.4,
              ),
            ),
            child: Icon(
              IconData(
                e.iconCode ?? Icons.receipt_long.codePoint,
                fontFamily: e.iconFamily ?? Icons.receipt_long.fontFamily!,
              ),
              color: primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_formatCurrency(e.amount, e.currency)} • ${e.category}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9BF7EB),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (e.note?.trim().isEmpty ?? true)
                      ? _formatDate(e.date)
                      : "${_formatDate(e.date)} • ${e.note}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7C8B8A),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: primary.withValues(alpha: 0.9),
            ),
            onPressed: () {
              setState(() => _items.remove(e));
              _saveData();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _items.isNotEmpty;

    final categoryNames = [
      AppLocalizations.of(context)!.filterAll,
      ..._categories.map((c) => c.name),
    ];

    var filteredItems =
        _selectedCategory == AppLocalizations.of(context)!.filterAll
            ? _items
            : _items.where((e) => e.category == _selectedCategory).toList();

    final sortedItems = [...filteredItems];

    if (_sortField == SortField.date) {
      sortedItems.sort((a, b) => _sortOrder == SortOrder.desc
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date));
    } else {
      sortedItems.sort((a, b) => _sortOrder == SortOrder.desc
          ? b.amount.compareTo(a.amount)
          : a.amount.compareTo(b.amount));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appName,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          PopupMenuButton<Map<String, dynamic>>(
            color: Theme.of(context).colorScheme.surface,
            onSelected: (value) {
              setState(() {
                _sortField = value["field"] as SortField;
                _sortOrder = value["order"] as SortOrder;
              });
            },
            icon: const Icon(Icons.sort),
            itemBuilder: (context) {
              final loc = AppLocalizations.of(context)!;
              return [
                PopupMenuItem(
                  value: {"field": SortField.date, "order": SortOrder.desc},
                  child: Text(loc.sortDateDesc),
                ),
                PopupMenuItem(
                  value: {"field": SortField.date, "order": SortOrder.asc},
                  child: Text(loc.sortDateAsc),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: {"field": SortField.amount, "order": SortOrder.desc},
                  child: Text(loc.sortAmountDesc),
                ),
                PopupMenuItem(
                  value: {"field": SortField.amount, "order": SortOrder.asc},
                  child: Text(loc.sortAmountAsc),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        onCategoriesChanged: () async {
          // Önce bellek içindeki eski verileri temizle
          _items.clear();
          _categories.clear();

          // Yeni (boş) verileri yükle
          await _loadData();
          await _loadCategories();

          // Filtreyi resetle
          setState(() {
            _selectedCategory = AppLocalizations.of(context)!.filterAll;
          });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(
          AppLocalizations.of(context)!.homeAddExpense,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: hasData
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in categoryNames)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildFilterChip(
                              category,
                              _selectedCategory == category,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTotalCard(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: sortedItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _buildExpenseCard(sortedItems[i]),
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
          const Text(
            "📭",
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.emptyExpenses,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
