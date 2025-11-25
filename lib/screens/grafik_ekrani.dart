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

  // Yeni: para birimi filtresi
  String _selectedCurrency = "TRY";

  final List<Color> chartColors = [
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFFFFC107),
    const Color(0xFFFF5722),
    const Color(0xFF9C27B0),
    const Color(0xFF009688),
    const Color(0xFFE91E63),
    const Color(0xFF795548),
    const Color(0xFF607D8B),
    const Color(0xFF8BC34A),
  ];

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
    return HSLColor.fromAHSL(1, hue, 0.5, 0.65).toColor();
  }

  Color getColorForCategory(String key) {
    if (key.hashCode % chartColors.length < chartColors.length) {
      return chartColors[key.hashCode % chartColors.length];
    } else {
      return _generatePastelColor(key);
    }
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
        final end = start.add(const Duration(days: 6));
        return DateTimeRange(start: start, end: end);
      case TimeFilter.thisMonth:
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 0);
        return DateTimeRange(start: start, end: end);
      case TimeFilter.prevMonth:
        final start = DateTime(today.year, today.month - 1, 1);
        final end = DateTime(today.year, today.month, 0);
        return DateTimeRange(start: start, end: end);
    }
  }

  // Tarihle filtrele
  List<Expense> get _filteredExpenses {
    final range = _dateRange;
    return _expenses.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }).toList();
  }

  // Yeni → Para birimine göre filtrele
  List<Expense> get _currencyFiltered {
    return _filteredExpenses
        .where((e) => e.currency == _selectedCurrency)
        .toList();
  }

  // Yeni → Para birimine göre kategori toplamları
  Map<String, double> get _categoryTotals {
    final map = <String, double>{};
    for (final e in _currencyFiltered) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  // Yeni → toplam
  double get _totalSpending =>
      _currencyFiltered.fold(0, (sum, e) => sum + e.amount);

  // Yeni → Çoklu para birimi formatı
  String _formatCurrency(num v, String code) {
    switch (code) {
      case "USD":
        return "\$${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}";
      case "EUR":
        return "€${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}";
      case "GBP":
        return "£${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}";
      default:
        return "₺${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}";
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final locale = Localizations.localeOf(context).toString();
    final start = range.start;
    final end = range.end;

    final dayFormat = DateFormat("d", locale);
    final monthYearFormat = DateFormat("MMMM yyyy", locale);
    final fullFormat = DateFormat("d MMMM yyyy", locale);

    if (start.month == end.month && start.year == end.year) {
      return "${dayFormat.format(start)} - ${dayFormat.format(end)} "
          "${monthYearFormat.format(start)}";
    }

    if (start.year == end.year) {
      return "${fullFormat.format(start)} - "
          "${fullFormat.format(end).replaceAll(" ${end.year}", "")} "
          "${end.year}";
    }

    return "${fullFormat.format(start)} - ${fullFormat.format(end)}";
  }

  @override
  Widget build(BuildContext context) {
    final data = _categoryTotals;
    final total = _totalSpending;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chartTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _expenses.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.chartNoData))
            : Column(
                children: [
                  // 🔹 Para birimi seçici
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    onChanged: (v) => setState(() => _selectedCurrency = v!),
                    items: ["TRY", "USD", "EUR", "GBP"]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                  ),

                  const SizedBox(height: 8),

                  // 🔹 Zaman filtresi
                  Center(
                    child: SegmentedButton<TimeFilter>(
                      segments: [
                        ButtonSegment(
                            value: TimeFilter.last7,
                            label: Text(
                                AppLocalizations.of(context)!.filterLast7Days)),
                        ButtonSegment(
                            value: TimeFilter.thisWeek,
                            label: Text(
                                AppLocalizations.of(context)!.filterThisWeek)),
                        ButtonSegment(
                            value: TimeFilter.thisMonth,
                            label: Text(
                                AppLocalizations.of(context)!.filterThisMonth)),
                        ButtonSegment(
                            value: TimeFilter.prevMonth,
                            label: Text(
                                AppLocalizations.of(context)!.filterPrevMonth)),
                      ],
                      showSelectedIcon: false,
                      selected: {_filter},
                      onSelectionChanged: (set) =>
                          setState(() => _filter = set.first),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tarih etiketi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateRange(_dateRange),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (data.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                            "${AppLocalizations.of(context)!.chartNoDataForPeriod} ($_selectedCurrency)"),
                      ),
                    )
                  else ...[
                    // Pasta grafiği
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 45,
                          sections: data.entries.map((entry) {
                            final percent = ((entry.value / total) * 100)
                                .toStringAsFixed(1);
                            final color = getColorForCategory(entry.key);

                            return PieChartSectionData(
                              color: color,
                              value: entry.value,
                              title: "$percent%",
                              radius: 85,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Liste
                    Expanded(
                      child: ListView(
                        children: data.entries.map((entry) {
                          final color = getColorForCategory(entry.key);
                          final percent = (entry.value / total) * 100;

                          return ListTile(
                            leading: CircleAvatar(backgroundColor: color),
                            title: Text(entry.key),
                            subtitle: Text(
                              "${_formatCurrency(entry.value, _selectedCurrency)} • %${percent.toStringAsFixed(1)}",
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
