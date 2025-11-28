import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../utils/icon_map.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Expense> _allExpenses = [];
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await StorageService.loadExpenses();
    setState(() => _allExpenses = data);
  }

  String _formatDate(DateTime date) {
    return DateFormat("dd.MM.yyyy").format(date);
  }

  Color get _cardBorder => const Color(0xFF1C3A37);
  Color get _cardBg => const Color(0xFF0F2624);

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 3);
    final last = DateTime(now.year + 3);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange: _selectedRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              surface: const Color(0xFF071312),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  List<Expense> get _filtered {
    if (_selectedRange == null) return [];
    return _allExpenses.where((e) {
      return e.date.isAfter(_selectedRange!.start.subtract(const Duration(days: 1))) &&
             e.date.isBefore(_selectedRange!.end.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Widget _buildExpenseCard(Expense e) {
    final primary = Theme.of(context).colorScheme.primary;
    final iconData = iconMap[e.iconName] ?? Icons.receipt_long;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.12),
              border: Border.all(color: primary.withValues(alpha: 0.30)),
            ),
            child: Icon(iconData, color: primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${e.amount} ${e.currency} • ${e.category}",
                  style: const TextStyle(
                    color: Color(0xFF9BF7EB),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${_formatDate(e.date)}${e.note != null ? " • ${e.note}" : ""}",
                  style: const TextStyle(
                    color: Color(0xFF7C8B8A),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  num get _totalAmount {
    num sum = 0;
    for (var e in _filtered) {
      sum += e.amount;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.reportTitle, style: Theme.of(context).textTheme.headlineLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DATE RANGE PICKER CARD
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedRange == null
                          ? loc.selectDateRange
                          : "${_formatDate(_selectedRange!.start)}  →  ${_formatDate(_selectedRange!.end)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TOTAL CARD
            if (_selectedRange != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.totalLabel, style: Theme.of(context).textTheme.bodyMedium),
                    Text("${_totalAmount}", style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // LIST
            Expanded(
              child: _selectedRange == null
                  ? Center(child: Text(loc.selectDateRangeHint))
                  : _filtered.isEmpty
                      ? const Center(
                          child: Text("📭 Hiç harcama yok", style: TextStyle(fontSize: 16)),
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _buildExpenseCard(_filtered[i]),
                        ),
            ),
          ],
        ),
      ),

      // BOTTOM BUTTONS
      bottomNavigationBar: _selectedRange == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _cardBg,
                border: Border(top: BorderSide(color: _cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file),
                      label: Text(loc.export),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      label: Text(loc.share),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
