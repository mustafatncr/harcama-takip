import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import 'package:intl/intl.dart';

enum TimeFilter { last7, thisWeek, thisMonth, prevMonth }

class GrafikEkrani extends StatefulWidget {
  const GrafikEkrani({super.key});

  @override
  State<GrafikEkrani> createState() => _GrafikEkraniState();
}

class _GrafikEkraniState extends State<GrafikEkrani> {
  List<Expense> _expenses = [];
  TimeFilter _filter = TimeFilter.thisMonth;
  String _selectedCurrency = "TRY";

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await StorageService.loadExpenses();
    setState(() => _expenses = data);
  }

  Color _generatePastelColor(String key) {
    final hue = (key.hashCode % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();
  }

  DateTimeRange get _dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_filter) {
      case TimeFilter.last7:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case TimeFilter.thisWeek:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(
            start: start, end: start.add(const Duration(days: 6)));
      case TimeFilter.thisMonth:
        return DateTimeRange(
          start: DateTime(today.year, today.month, 1),
          end: DateTime(today.year, today.month + 1, 0),
        );
      case TimeFilter.prevMonth:
        return DateTimeRange(
          start: DateTime(today.year, today.month - 1, 1),
          end: DateTime(today.year, today.month, 0),
        );
    }
  }

  List<Expense> get _filteredExpenses {
    final range = _dateRange;
    return _expenses.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }).toList();
  }

  List<Expense> get _currencyFiltered =>
      _filteredExpenses.where((e) => e.currency == _selectedCurrency).toList();

  Map<String, double> get _categoryTotals {
    final map = <String, double>{};
    for (final e in _currencyFiltered) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  double get _totalSpending =>
      _currencyFiltered.fold(0, (sum, e) => sum + e.amount);

  String _formatDateRange(DateTimeRange r) {
    final locale = Localizations.localeOf(context).toString();
    final f = DateFormat("d MMM yyyy", locale);
    return "${f.format(r.start)}  -  ${f.format(r.end)}";
  }

  String _currencySymbol(String code) {
    switch (code) {
      case "USD":
        return "\$";
      case "EUR":
        return "€";
      case "GBP":
        return "£";
      default:
        return "₺";
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totals = _categoryTotals;
    final total = _totalSpending;
    final primary = cs.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.chartTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCurrencySelector(primary),
            const SizedBox(height: 20),

            _buildSegmentedTimeline(primary),
            const SizedBox(height: 20),

            _buildDateCapsule(),
            const SizedBox(height: 28),

            Expanded(
              child: _currencyFiltered.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.chartNoData,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _buildDonutChart(primary, totals, total),
                        const SizedBox(height: 16),

                        Expanded(
                          child: _buildLegendList(primary, totals, total),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrencySelector(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.4), width: 1.4),
        color: const Color(0xFF0F2624),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          icon: Icon(Icons.expand_more, color: primary),
          items: ["TRY", "USD", "EUR", "GBP"]
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedCurrency = v!),
        ),
      ),
    );
  }

  Widget _buildSegmentedTimeline(Color primary) {
    return SegmentedButton<TimeFilter>(
      segments: [
        ButtonSegment(
          value: TimeFilter.last7,
          label: Text(AppLocalizations.of(context)!.filterLast7Days),
        ),
        ButtonSegment(
          value: TimeFilter.thisWeek,
          label: Text(AppLocalizations.of(context)!.filterThisWeek),
        ),
        ButtonSegment(
          value: TimeFilter.thisMonth,
          label: Text(AppLocalizations.of(context)!.filterThisMonth),
        ),
        ButtonSegment(
          value: TimeFilter.prevMonth,
          label: Text(AppLocalizations.of(context)!.filterPrevMonth),
        ),
      ],
      selected: {_filter},
      showSelectedIcon: false,
      onSelectionChanged: (s) => setState(() => _filter = s.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.25)
              : const Color(0xFF071312);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primary
              : Colors.white70;
        }),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildDateCapsule() {
    final r = _dateRange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            _formatDateRange(r),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDonutChart(
    Color primary,
    Map<String, double> totals,
    double total,
  ) {
    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 55,
          startDegreeOffset: -90,
          borderData: FlBorderData(show: false),
          sections: totals.entries.map((entry) {
            final percent = (entry.value / total) * 100;
            final color = _generatePastelColor(entry.key);

            return PieChartSectionData(
              color: color,
              value: entry.value,
              radius: 70,
              title: "${percent.toStringAsFixed(1)}%",
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLegendList(
    Color primary,
    Map<String, double> totals,
    double total,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 10),
      itemCount: totals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final e = totals.entries.elementAt(i);
        final percent = (e.value / total) * 100;
        final color = _generatePastelColor(e.key);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2624),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: color),
              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                "${_currencySymbol(_selectedCurrency)}${e.value.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                "${percent.toStringAsFixed(1)}%",
                style: TextStyle(
                  color: primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
