import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExportPdfService {
  static String _formatDate(DateTime date) {
    return DateFormat("dd.MM.yyyy").format(date);
  }

  static Future<File> generatePdf(List<Expense> expenses) async {
    // Unicode font
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final Uint8List fontBytes = fontData.buffer.asUint8List();

    // Logo
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

    // ⭐ LOGO
    page.graphics.drawImage(
      logoImage,
      const Rect.fromLTWH(0, 0, 60, 60),
    );

    // ⭐ BAŞLIK
    page.graphics.drawString(
      "Harcama Raporu",
      titleFont,
      bounds: const Rect.fromLTWH(70, 0, 500, 40),
    );

    // ⭐ OLUŞTURULMA TARİHİ
    page.graphics.drawString(
      "Oluşturulma: ${_formatDate(DateTime.now())}",
      subFont,
      bounds: const Rect.fromLTWH(70, 30, 500, 20),
    );

    // ⭐ REPORTED BY
    page.graphics.drawString(
      "Reported by MustApp Studio",
      smallItalic,
      bounds: const Rect.fromLTWH(70, 48, 500, 20),
    );

    // ⭐ TABLO
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);

    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 6, right: 6, top: 4, bottom: 4),
      font: cellFont,
    );

    grid.headers.add(1);
    final header = grid.headers[0];
    header.cells[0].value = "Tarih";
    header.cells[1].value = "Kategori";
    header.cells[2].value = "Not";
    header.cells[3].value = "Tutar";
    header.cells[4].value = "Para Birimi";

    final headerStyle = PdfGridCellStyle(
      backgroundBrush: PdfBrushes.lightGray,
      textBrush: PdfBrushes.black,
      font: headerFont,
    );

    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style = headerStyle;
    }

    // Satırları doldur
    for (final e in expenses) {
      final row = grid.rows.add();
      row.cells[0].value = _formatDate(e.date);
      row.cells[1].value = e.category;
      row.cells[2].value = e.note ?? "";
      row.cells[3].value = e.amount.toString();
      row.cells[4].value = e.currency;
    }

    // ⭐ TOPLAM HESAPLA
    final double total = expenses.fold(0, (sum, e) => sum + e.amount);

    // ⭐ TOPLAM SATIRI EKLE
    final PdfGridRow totalRow = grid.rows.add();

    // İlk 2 hücre boş ve borders görünmez
    for (int i = 0; i < 2; i++) {
      totalRow.cells[i].value = "";
      totalRow.cells[i].style = PdfGridCellStyle(
        borders: PdfBorders(
          left: PdfPen(PdfColor(255, 255, 255), width: 0),
          right: PdfPen(PdfColor(255, 255, 255), width: 0),
          top: PdfPen(PdfColor(255, 255, 255), width: 0),
          bottom: PdfPen(PdfColor(255, 255, 255), width: 0),
        ),
      );
    }

    // ⭐ TOPLAM (3. sütunda)
    totalRow.cells[2].value = "TOPLAM";
    totalRow.cells[2].style = PdfGridCellStyle(
      font: PdfTrueTypeFont(fontBytes, 13, style: PdfFontStyle.bold),
      backgroundBrush: PdfBrushes.white,
      textBrush: PdfBrushes.black,
    );

    // ⭐ TOPLAM TUTAR (4. sütun)
    totalRow.cells[3].value = total.toStringAsFixed(2);
    totalRow.cells[3].style = PdfGridCellStyle(
      font: PdfTrueTypeFont(fontBytes, 13, style: PdfFontStyle.bold),
      backgroundBrush: PdfBrushes.white,
      textBrush: PdfBrushes.black,
    );

    // ⭐ PARA BİRİMİ (5. sütun)
    totalRow.cells[4].value = "TRY";
    totalRow.cells[4].style = PdfGridCellStyle(
      font: PdfTrueTypeFont(fontBytes, 13, style: PdfFontStyle.bold),
      backgroundBrush: PdfBrushes.white,
      textBrush: PdfBrushes.black,
    );

    grid.repeatHeader = true;
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);

    // ⭐ TABLOYU ÇİZ
    grid.draw(
      page: page,
      bounds: const Rect.fromLTWH(0, 80, 0, 0),
    );

    // ⭐ KAYDET
    final bytes = await document.save();
    document.dispose();

    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/harcama_raporu.pdf");

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> exportAndShare(List<Expense> expenses) async {
    final file = await generatePdf(expenses);

    await Share.shareXFiles(
      [
        XFile(file.path, mimeType: "application/pdf"),
      ],
      text: "Harcama Raporu (PDF)",
    );
  }
}
