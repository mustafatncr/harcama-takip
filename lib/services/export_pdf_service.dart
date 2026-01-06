import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:harcama_takip/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../l10n/app_localizations.dart';
import '../models/expense.dart';

class ExportPdfService {
  static String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final pattern = locale == "tr" ? "dd.MM.yyyy" : "MM/dd/yyyy";
    return DateFormat(pattern).format(date);
  }

  static Future<File> generatePdf(
    BuildContext context,
    List<Expense> expenses,
  ) async {
    final loc = AppLocalizations.of(context)!;

    // 🔤 Unicode font
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final Uint8List fontBytes = fontData.buffer.asUint8List();

    // 🖼️ Logo
    final Uint8List logoBytes =
        (await rootBundle.load("assets/icon/app_icon.png"))
            .buffer
            .asUint8List();
    final PdfBitmap logoImage = PdfBitmap(logoBytes);

    final document = PdfDocument();
    final page = document.pages.add();

    final titleFont = PdfTrueTypeFont(fontBytes, 22, style: PdfFontStyle.bold);
    final subFont = PdfTrueTypeFont(fontBytes, 12);
    final smallItalic =
        PdfTrueTypeFont(fontBytes, 11, style: PdfFontStyle.italic);
    final cellFont = PdfTrueTypeFont(fontBytes, 12);
    final headerFont = PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold);

    // 🖼️ LOGO
    page.graphics.drawImage(
      logoImage,
      const Rect.fromLTWH(0, 0, 60, 60),
    );

    // 📄 BAŞLIK
    page.graphics.drawString(
      loc.pdfReportTitle,
      titleFont,
      bounds: const Rect.fromLTWH(70, 0, 500, 40),
    );

    // 🕒 OLUŞTURULMA TARİHİ
    page.graphics.drawString(
      "${loc.pdfCreatedAt}: ${_formatDate(context, DateTime.now())}",
      subFont,
      bounds: const Rect.fromLTWH(70, 30, 500, 20),
    );

    // 🏷️ REPORTED BY
    page.graphics.drawString(
      loc.pdfReportedBy,
      smallItalic,
      bounds: const Rect.fromLTWH(70, 48, 500, 20),
    );

    // 📊 TABLO
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);

    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 6, right: 6, top: 4, bottom: 4),
      font: cellFont,
    );

    grid.headers.add(1);
    final header = grid.headers[0];

    header.cells[0].value = loc.pdfColumnDate;
    header.cells[1].value = loc.pdfColumnCategory;
    header.cells[2].value = loc.pdfColumnNote;
    header.cells[3].value = loc.pdfColumnAmount;
    header.cells[4].value = loc.pdfColumnCurrency;

    final headerStyle = PdfGridCellStyle(
      backgroundBrush: PdfBrushes.lightGray,
      textBrush: PdfBrushes.black,
      font: headerFont,
    );

    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style = headerStyle;
    }

    // 📄 SATIRLAR
    for (final e in expenses) {
      final row = grid.rows.add();
      row.cells[0].value = _formatDate(context, e.date);
      row.cells[1].value = e.category;
      row.cells[2].value = e.note ?? "";
      row.cells[3].value = formatCurrencyWithoutSymbol(
        context,
        e.amount,
        e.currency,
      );
      row.cells[4].value = e.currency;
    }

    // 🔥 ÇOKLU PARA BİRİMİ TOPLAM
    final Map<String, double> totalsByCurrency = {};
    for (final e in expenses) {
      totalsByCurrency[e.currency] =
          (totalsByCurrency[e.currency] ?? 0) + e.amount;
    }

    final entries = totalsByCurrency.entries.toList();

// 🔹 TOPLAM + İLK PARA BİRİMİ AYNI SATIRDA
    final PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[2].value = loc.pdfTotal;
    totalRow.cells[3].value = formatCurrencyWithoutSymbol(
      context,
      entries.first.value,
      entries.first.key,
    );
    totalRow.cells[4].value = entries.first.key;

    for (int i = 2; i < 5; i++) {
      totalRow.cells[i].style = PdfGridCellStyle(
        font: PdfTrueTypeFont(fontBytes, 13, style: PdfFontStyle.bold),
      );
    }

// 🔹 KALAN PARA BİRİMLERİ ALT SATIRLARDA
    for (int i = 1; i < entries.length; i++) {
      final row = grid.rows.add();
      row.cells[3].value = formatCurrencyWithoutSymbol(
        context,
        entries[i].value,
        entries[i].key,
      );
      row.cells[4].value = entries[i].key;

      row.cells[3].style = PdfGridCellStyle(
        font: PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
      );
      row.cells[4].style = PdfGridCellStyle(
        font: PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
      );
    }

    grid.repeatHeader = true;
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);

    grid.draw(
      page: page,
      bounds: const Rect.fromLTWH(0, 80, 0, 0),
    );

    final bytes = await document.save();
    document.dispose();

    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/expense_report.pdf");

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> exportAndShare(
    BuildContext context,
    List<Expense> expenses,
  ) async {
    final loc = AppLocalizations.of(context)!;

    final file = await generatePdf(context, expenses);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: "application/pdf")],
      text: loc.pdfShareText,
    );
  }
}
