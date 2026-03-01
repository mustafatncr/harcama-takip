import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import 'package:harcama_takip/main.dart';
import 'package:harcama_takip/utils/formatters.dart';
import '../widgets/add_expense_sheet.dart';
import '../services/storage_service.dart';
import '../services/category_service.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';
import '../utils/icon_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SortField { date, amount }

enum SortOrder { desc, asc }

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final List<Expense> _items = [];
  List<Category> _categories = [];
  String? _settingsCurrency;

  String _selectedCategory = "";

  SortField _sortField = SortField.date;
  SortOrder _sortOrder = SortOrder.desc;

  @override
  void initState() {
    super.initState();
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCategories();
      final currency = await StorageService.loadCurrency();
      setState(() {
        _settingsCurrency = currency;
        _selectedCategory = AppLocalizations.of(context)!.filterAll;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() async {
    final currency = await StorageService.loadCurrency();

    if (!mounted) return;

    setState(() {
      _settingsCurrency = currency;
    });
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

  Map<String, num> get _totalsByCurrency {
    final now = DateTime.now();

    final filtered = _items.where((e) {
      final sameMonth = e.date.year == now.year && e.date.month == now.month;

      final sameCategory =
          _selectedCategory == AppLocalizations.of(context)!.filterAll
              ? true
              : e.category == _selectedCategory;

      return sameMonth && sameCategory;
    });

    final Map<String, num> result = {};

    for (var e in filtered) {
      result[e.currency] = (result[e.currency] ?? 0) + e.amount;
    }

    return result;
  }

  List<String> get _formattedTotals {
    final totals = _totalsByCurrency;

    if (totals.isEmpty) {
      if (_settingsCurrency == null) return [];

      return [
        formatCurrency(context, 0, _settingsCurrency!),
      ];
    }

    return totals.entries
        .map((e) => formatCurrency(context, e.value, e.key))
        .toList();
  }

  Future<void> _openAddSheet() async {
    final currency = await StorageService.loadCurrency();

    if (!mounted) return;

    final Expense? expense = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseSheet(currencyCode: currency),
    );

    if (expense == null) return;

    setState(() {
      _items.insert(0, expense);
    });

    await _saveData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${AppLocalizations.of(context)!.expenseAdded}: "
          "${formatCurrency(context, expense.amount, expense.currency)} • "
          "${expense.category} • ${formatDate(context, expense.date)}",
        ),
      ),
    );
  }

  Future<void> _confirmDeleteExpense(Expense e) async {
    final loc = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF0F2624),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.expenseDeleteTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.expenseDeleteMessage,
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
      setState(() => _items.remove(e));
      await _saveData();
    }
  }

  Future<void> _openEditSheet(Expense expense) async {
    final Expense? updatedExpense = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseSheet(
        currencyCode: expense.currency,
        expenseToEdit: expense,
      ),
    );

    if (updatedExpense == null) return;

    final actualIndex = _items.indexOf(expense);
    if (actualIndex == -1) return;

    setState(() {
      _items[actualIndex] = updatedExpense;
    });

    await _saveData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${AppLocalizations.of(context)!.expenseUpdated}: "
            "${formatCurrency(context, updatedExpense.amount, updatedExpense.currency)} • "
            "${updatedExpense.category} • ${formatDate(context, updatedExpense.date)}"),
      ),
    );
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
    final loc = AppLocalizations.of(context)!;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.thisMonth,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                loc.basedOnSelectedFilters,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _formattedTotals.map((text) {
              return Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense e) {
    final primary = Theme.of(context).colorScheme.primary;

    final IconData iconData = iconMap[e.iconName] ?? Icons.receipt_long;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SOL ICON ---
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
              iconData,
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
                  "${formatCurrency(context, e.amount, e.currency)} • ${e.category}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9BF7EB),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (e.note?.trim().isEmpty ?? true)
                      ? formatDate(context, e.date)
                      : "${formatDate(context, e.date)} • ${e.note}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7C8B8A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                icon: Icon(
                  Icons.edit,
                  color: primary.withValues(alpha: 0.9),
                ),
                onPressed: () => _openEditSheet(e),
              ),
              const SizedBox(height: 4),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                onPressed: () => _confirmDeleteExpense(e),
              ),
            ],
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
          _items.clear();
          _categories.clear();

          await _loadData();
          await _loadCategories();

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
            : const _EmptyState(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
