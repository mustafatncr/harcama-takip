import 'dart:io';

import 'package:flutter/material.dart';
import 'package:harcama_takip/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

import '../l10n/app_localizations.dart';
import '../models/expense.dart';

class ExportExcelService {
  // 📅 Tarih formatı – dile göre
  static String _formatDate(BuildContext context, DateTime date) {
    final lang = Localizations.localeOf(context).languageCode;
    final pattern = lang == "tr" ? "dd.MM.yyyy" : "MM/dd/yyyy";
    return DateFormat(pattern).format(date);
  }

  static Future<File> generateExcel(
    BuildContext context,
    List<Expense> expenses,
  ) async {
    final loc = AppLocalizations.of(context)!;

    final workbook = xls.Workbook();

    // =========================
    // 📄 SHEET 1: EXPENSES
    // =========================
    final sheet = workbook.worksheets[0];
    sheet.name = loc.excelSheetName; // "Expenses"

    // 🧾 Başlıklar
    sheet.getRangeByName('A1').setText(loc.excelColumnDate);
    sheet.getRangeByName('B1').setText(loc.excelColumnCategory);
    sheet.getRangeByName('C1').setText(loc.excelColumnAmount);
    sheet.getRangeByName('D1').setText(loc.excelColumnCurrency);
    sheet.getRangeByName('E1').setText(loc.excelColumnNote);

    final headerStyle = workbook.styles.add('Header');
    headerStyle.bold = true;

    sheet.getRangeByName("A1:E1").cellStyle = headerStyle;

    int row = 2;
    for (final e in expenses) {
      sheet.getRangeByIndex(row, 1).setText(
            _formatDate(context, e.date),
          );
      sheet.getRangeByIndex(row, 2).setText(e.category);
      sheet.getRangeByIndex(row, 3).setText(
            formatCurrencyWithoutSymbol(
              context,
              e.amount,
              e.currency,
            ),
          );
      sheet.getRangeByIndex(row, 4).setText(e.currency);
      sheet.getRangeByIndex(row, 5).setText(e.note ?? "");
      row++;
    }

    for (int i = 1; i <= 5; i++) {
      sheet.autoFitColumn(i);
    }

    final summarySheet = workbook.worksheets.add();
    summarySheet.name = loc.excelSummarySheetName;

    summarySheet.getRangeByName('A1').setText(loc.excelSummaryCurrency);
    summarySheet.getRangeByName('B1').setText(loc.excelSummaryTotal);

    summarySheet.getRangeByName("A1:B1").cellStyle = headerStyle;

    final Map<String, double> totalsByCurrency = {};

    for (final e in expenses) {
      totalsByCurrency[e.currency] =
          (totalsByCurrency[e.currency] ?? 0) + e.amount;
    }

    int summaryRow = 2;
    for (final entry in totalsByCurrency.entries) {
      summarySheet.getRangeByIndex(summaryRow, 1).setText(entry.key);
      summarySheet.getRangeByIndex(summaryRow, 2).setText(
            formatCurrencyWithoutSymbol(
              context,
              entry.value,
              entry.key,
            ),
          );
      summaryRow++;
    }

    summarySheet.autoFitColumn(1);
    summarySheet.autoFitColumn(2);
    
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getTemporaryDirectory();
    final file = File(
      "${directory.path}/${loc.excelFileName}.xlsx",
    );

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> exportAndShare(
    BuildContext context,
    List<Expense> expenses,
  ) async {
    final loc = AppLocalizations.of(context)!;

    final file = await generateExcel(context, expenses);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType:
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        )
      ],
      text: loc.excelShareText,
    );
  }
}
