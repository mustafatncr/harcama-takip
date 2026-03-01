import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import 'package:harcama_takip/utils/formatters.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

enum TimeFilter { last7, thisWeek, thisMonth, prevMonth }

class GrafikEkrani extends StatefulWidget {
  const GrafikEkrani({super.key});

  @override
  State<GrafikEkrani> createState() => _GrafikEkraniState();
}

class _GrafikEkraniState extends State<GrafikEkrani> {
  List<Expense> _expenses = [];
  TimeFilter _filter = TimeFilter.thisMonth;
  late String _selectedCurrency;
  bool _showTrend = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final expenses = await StorageService.loadExpenses();
    final currency = await StorageService.loadCurrency();

    setState(() {
      _expenses = expenses;
      _selectedCurrency = currency;
    });
  }

  Color _generatePastelColor(String key) {
    final hue = (((key.hashCode % 360) + 360) % 360).toDouble();
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

  Map<DateTime, double> get _dailyTotals {
    final map = <DateTime, double>{};
    for (final e in _currencyFiltered) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map[day] = (map[day] ?? 0) + e.amount;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  String _formatDateRange(DateTimeRange r) {
    return "${formatDate(context, r.start)}  –  ${formatDate(context, r.end)}";
  }

  String _shortDayName(int weekday, String langCode) {
    const trDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    const enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (langCode == 'tr' ? trDays : enDays)[weekday - 1];
  }

  Widget _buildChartToggle(Color primary) {
    final langCode = Localizations.localeOf(context).languageCode;
    final donutLabel = langCode == 'tr' ? '🍩  Pasta' : '🍩  Donut';
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F2624),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: donutLabel,
            selected: !_showTrend,
            primary: primary,
            onTap: () => setState(() => _showTrend = false),
          ),
          const SizedBox(width: 4),
          _buildToggleButton(
            label: '📊  Trend',
            selected: _showTrend,
            primary: primary,
            onTap: () => setState(() => _showTrend = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool selected,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: primary.withValues(alpha: 0.45))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? primary : Colors.white54,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendView(Color primary, double screenHeight) {
    final chartHeight = (screenHeight * 0.28).clamp(180.0, 260.0);
    return Column(
      children: [
        SizedBox(height: chartHeight, child: _buildBarChart(primary)),
        const SizedBox(height: 20),
        _buildBarLegend(primary),
      ],
    );
  }

  Widget _buildBarChart(Color primary) {
    final dailyList = _dailyTotals.entries.toList();
    if (dailyList.isEmpty) return const SizedBox.shrink();

    final maxY = dailyList.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final useShortDay = dailyList.length <= 7;
    final langCode = Localizations.localeOf(context).languageCode;
    final barWidth = dailyList.length <= 7
        ? 26.0
        : dailyList.length <= 14
            ? 18.0
            : 11.0;

    return BarChart(
      BarChartData(
        maxY: maxY * 1.25,
        barGroups: dailyList.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                gradient: LinearGradient(
                  colors: [primary.withValues(alpha: 0.65), primary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: barWidth,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= dailyList.length) {
                  return const SizedBox.shrink();
                }
                final date = dailyList[idx].key;
                if (!useShortDay && date.day % 5 != 0 && date.day != 1) {
                  return const SizedBox.shrink();
                }
                final label = useShortDay
                    ? _shortDayName(date.weekday, langCode)
                    : '${date.day}';
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.07),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0A1F1D),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = dailyList[group.x].key;
              return BarTooltipItem(
                '${formatDate(context, date)}\n',
                const TextStyle(color: Colors.white70, fontSize: 12),
                children: [
                  TextSpan(
                    text: formatCurrency(context, rod.toY, _selectedCurrency),
                    style: TextStyle(
                      color: primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarLegend(Color primary) {
    final dailyList = _dailyTotals.entries.toList();
    if (dailyList.isEmpty) return const SizedBox.shrink();
    final loc = AppLocalizations.of(context)!;
    final maxEntry = dailyList.reduce((a, b) => a.value > b.value ? a : b);
    final rangeDays = _dateRange.end.difference(_dateRange.start).inDays + 1;
    final avg = dailyList.fold(0.0, (s, e) => s + e.value) / rangeDays;

    return Column(
      children: [
        _buildStatRow(
          primary,
          Icons.bar_chart_rounded,
          loc.trendMaxDay,
          '${formatDate(context, maxEntry.key)}  ·  ${formatCurrency(context, maxEntry.value, _selectedCurrency)}',
        ),
        const SizedBox(height: 10),
        _buildStatRow(
          primary,
          Icons.show_chart_rounded,
          loc.trendDailyAvg,
          formatCurrency(context, avg, _selectedCurrency),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    Color primary,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2624),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totals = _categoryTotals;
    final total = _totalSpending;
    final primary = cs.primary;
    final mq = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.chartTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [_buildCurrencyAction(primary)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSegmentedTimeline(primary, mq.size.width),
            const SizedBox(height: 12),
            _buildControlRow(primary),
            const SizedBox(height: 20),
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
                  : _showTrend
                      ? _buildTrendView(primary, mq.size.height)
                      : Column(
                          children: [
                            _buildDonutChart(primary, totals, total, mq.size.height),
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

  Widget _buildCurrencyAction(Color primary) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        initialValue: _selectedCurrency,
        onSelected: (v) => setState(() => _selectedCurrency = v),
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: const Color(0xFF0F2624),
        itemBuilder: (context) => ["TRY", "USD", "EUR", "GBP"]
            .map((c) => PopupMenuItem(
                  value: c,
                  child: Text(
                    c,
                    style: TextStyle(
                      color: c == _selectedCurrency ? primary : Colors.white,
                      fontWeight: c == _selectedCurrency
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: primary.withValues(alpha: 0.45), width: 1.2),
            color: primary.withValues(alpha: 0.08),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedCurrency,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 3),
              Icon(Icons.expand_more_rounded, color: primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateCapsule(),
        const SizedBox(height: 10),
        _buildChartToggle(primary),
      ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTimeline(Color primary, double screenWidth) {
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
          EdgeInsets.symmetric(
            horizontal: screenWidth < 380 ? 6.0 : 16.0,
            vertical: screenWidth < 380 ? 10.0 : 12.0,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildDonutChart(
    Color primary,
    Map<String, double> totals,
    double total,
    double screenHeight,
  ) {
    final chartHeight = (screenHeight * 0.3).clamp(210.0, 290.0);
    final loc = AppLocalizations.of(context)!;
    return SizedBox(
      height: chartHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 58,
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatCurrency(context, total, _selectedCurrency),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                loc.totalLabel,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
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
                formatCurrency(context, e.value, _selectedCurrency),
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
