import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExportExcelService {
  static String _formatDate(DateTime date) {
    return DateFormat("dd.MM.yyyy").format(date);
  }

  static Future<File> generateExcel(List<Expense> expenses) async {
    final workbook = xls.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = "Expenses";

    sheet.getRangeByName('A1').setText("Tarih");
    sheet.getRangeByName('B1').setText("Kategori");
    sheet.getRangeByName('C1').setText("Tutar");
    sheet.getRangeByName('D1').setText("Para Birimi");
    sheet.getRangeByName('E1').setText("Not");

    final headerStyle = workbook.styles.add('Header');
    headerStyle.bold = true;

    sheet.getRangeByName("A1:E1").cellStyle = headerStyle;

    int row = 2;
    for (final e in expenses) {
      sheet.getRangeByIndex(row, 1).setText(_formatDate(e.date));
      sheet.getRangeByIndex(row, 2).setText(e.category);
      sheet.getRangeByIndex(row, 3).setNumber(e.amount);
      sheet.getRangeByIndex(row, 4).setText(e.currency);
      sheet.getRangeByIndex(row, 5).setText(e.note ?? "");
      row++;
    }

    sheet.autoFitColumn(1);
    sheet.autoFitColumn(2);
    sheet.autoFitColumn(3);
    sheet.autoFitColumn(4);
    sheet.autoFitColumn(5);

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/harcama_raporu.xlsx");
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  static Future<void> exportAndShare(List<Expense> expenses) async {
    final file = await generateExcel(expenses);

    await Share.shareXFiles([
      XFile(file.path, mimeType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    ], text: "Harcama Raporu");
  }
}
