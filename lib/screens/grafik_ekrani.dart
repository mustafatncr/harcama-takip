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
  TimeFilter _filter = TimeFilter.thisMonth; // Varsayılan: Bu Ay

  // 🌈 Sabit renk paleti (ilk 10 kategori için)
  final List<Color> chartColors = [
    const Color(0xFF4CAF50), // yeşil
    const Color(0xFF2196F3), // mavi
    const Color(0xFFFFC107), // amber
    const Color(0xFFFF5722), // turuncu
    const Color(0xFF9C27B0), // mor
    const Color(0xFF009688), // teal
    const Color(0xFFE91E63), // pembe
    const Color(0xFF795548), // kahverengi
    const Color(0xFF607D8B), // mavi-gri
    const Color(0xFF8BC34A), // açık yeşil
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

  // 🎨 Dinamik renk üretici (kategoriye göre pastel tonlar)
  Color _generatePastelColor(String key) {
    final hue = (key.hashCode % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.5, 0.65).toColor();
  }

  // 🎨 Kategorilere göre renk atama
  Color getColorForCategory(String key) {
    if (key.hashCode % chartColors.length < chartColors.length) {
      return chartColors[key.hashCode % chartColors.length];
    } else {
      return _generatePastelColor(key);
    }
  }

  // 🗓 Tarih aralığı hesaplama
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
        final start = today.subtract(Duration(days: today.weekday - 1)); // Pzt
        final end = start.add(const Duration(days: 6)); // Paz
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

  // 🔹 Seçili tarih aralığına göre filtreleme
  List<Expense> get _filteredExpenses {
    final range = _dateRange;
    return _expenses.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }).toList();
  }

  // 🔹 Kategoriye göre toplam hesapla
  Map<String, double> get _categoryTotals {
    final map = <String, double>{};
    for (final e in _filteredExpenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  double get _totalSpending =>
      _filteredExpenses.fold(0, (sum, e) => sum + e.amount);

  // 🔹 TL formatı
  String _formatTL(num v) => "₺${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}";

  // String _formatDateRange(DateTimeRange range) {
  //   final months = [
  //     'Ocak',
  //     'Şubat',
  //     'Mart',
  //     'Nisan',
  //     'Mayıs',
  //     'Haziran',
  //     'Temmuz',
  //     'Ağustos',
  //     'Eylül',
  //     'Ekim',
  //     'Kasım',
  //     'Aralık'
  //   ];

  //   final start = range.start;
  //   final end = range.end;

  //   // Eğer aynı ay içindeyse: "1 - 7 Ekim 2025"
  //   if (start.month == end.month && start.year == end.year) {
  //     return "${start.day} - ${end.day} ${months[start.month - 1]} ${start.year}";
  //   }

  //   // Farklı ay: "25 Eylül - 1 Ekim 2025"
  //   if (start.year == end.year) {
  //     return "${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${start.year}";
  //   }

  //   // Farklı yıl olursa (örneğin Aralık - Ocak geçişi)
  //   return "${start.day} ${months[start.month - 1]} ${start.year} - ${end.day} ${months[end.month - 1]} ${end.year}";
  // }

  String _formatDateRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;

    final dayFormat = DateFormat("d", Intl.getCurrentLocale());
    final monthYearFormat = DateFormat("MMMM yyyy", Intl.getCurrentLocale());
    final fullFormat = DateFormat("d MMMM yyyy", Intl.getCurrentLocale());

    // Aynı ay → "1 - 7 Ekim 2025"
    if (start.month == end.month && start.year == end.year) {
      return "${dayFormat.format(start)} - ${dayFormat.format(end)} "
          "${monthYearFormat.format(start)}";
    }

    // Farklı ay ama aynı yıl → "25 Eylül - 1 Ekim 2025"
    if (start.year == end.year) {
      return "${fullFormat.format(start)} - "
          "${fullFormat.format(end).replaceAll(" ${end.year}", "")} "
          "${end.year}";
    }

    // Farklı yıl → "25 Aralık 2025 - 1 Ocak 2026"
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
            ? Center(
                child: Text(AppLocalizations.of(context)!.chartNoData),
              )
            : Column(
                children: [
                  // 🔹 Zaman filtresi (SegmentedButton)
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

                  // 🔹 🗓 Tarih aralığı etiketi
                  const SizedBox(height: 8),
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
                    const Expanded(
                      child: Center(
                        child: Text("Bu dönem için harcama bulunmuyor"),
                      ),
                    )
                  else ...[
                    // 🔹 Pasta grafiği
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

                    // 🔹 Kategori detay listesi
                    Expanded(
                      child: ListView(
                        children: data.entries.map((entry) {
                          final color = getColorForCategory(entry.key);
                          final percent = (entry.value / total) * 100;
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: color),
                            title: Text(entry.key),
                            subtitle: Text(
                              "${_formatTL(entry.value)} • %${percent.toStringAsFixed(1)}",
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
