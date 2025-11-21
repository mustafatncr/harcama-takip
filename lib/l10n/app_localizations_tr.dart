// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Harcama Takip';

  @override
  String get drawerTitle => '💰 Harcama Takip';

  @override
  String get drawerSubtitle => 'Kişisel finansını kolayca yönet';

  @override
  String get drawerHome => 'Ana Sayfa';

  @override
  String get drawerCharts => 'Grafikler';

  @override
  String get drawerCategories => 'Kategoriler';

  @override
  String get drawerSettings => 'Ayarlar';

  @override
  String get emptyExpenses => 'Henüz harcama eklenmemiş';

  @override
  String get emptyExpensesHint => 'Aşağıdaki + butonuna dokunarak ilk harcamanı ekle';

  @override
  String get homeAddExpense => 'Harcama Ekle';

  @override
  String get sortDateDesc => 'Tarih (Yeni > Eski)';

  @override
  String get sortDateAsc => 'Tarih (Eski > Yeni)';

  @override
  String get sortAmountDesc => 'Tutar (Yüksek > Düşük)';

  @override
  String get sortAmountAsc => 'Tutar (Düşük > Yüksek)';

  @override
  String get addExpenseTitle => 'Yeni Harcama';

  @override
  String get amountLabel => 'Tutar (₺)';

  @override
  String get amountRequired => 'Tutar giriniz';

  @override
  String get noCategories => 'Kategori bulunamadı. Lütfen önce kategori ekleyin.';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get noteLabel => 'Not (isteğe bağlı)';

  @override
  String get buttonAdd => 'Ekle';

  @override
  String get filterAll => 'Tümü';

  @override
  String get chartNoData => 'Henüz harcama verisi bulunmuyor';

  @override
  String get chartTitle => 'Grafikler';

  @override
  String get filterLast7Days => 'Son 7 Gün';

  @override
  String get filterThisWeek => 'Bu Hafta';

  @override
  String get filterThisMonth => 'Bu Ay';

  @override
  String get filterPrevMonth => 'Geçen Ay';

  @override
  String get categoryTitle => 'Kategoriler';

  @override
  String get categoryAddButton => 'Kategori Ekle';

  @override
  String get categoryEmpty => 'Henüz kategori yok';
}
