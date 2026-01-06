// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Expense Tracker';

  @override
  String get drawerTitle => '💰 Expense Tracker';

  @override
  String get drawerSubtitle => 'Manage your personal finance easily';

  @override
  String get drawerHome => 'Home';

  @override
  String get drawerCharts => 'Charts';

  @override
  String get drawerCategories => 'Categories';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get emptyExpenses => 'You haven\'t added any expenses yet';

  @override
  String get emptyExpensesHint => 'Tap the + button below to add your first expense';

  @override
  String get homeAddExpense => 'Add Expense';

  @override
  String get sortDateDesc => 'Date (Newer > Older)';

  @override
  String get sortDateAsc => 'Date (Older > Newer)';

  @override
  String get sortAmountDesc => 'Amount (High > Low)';

  @override
  String get sortAmountAsc => 'Amount (Low > High)';

  @override
  String get addExpenseTitle => 'New Expense';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountRequired => 'Please enter an amount';

  @override
  String get noCategories => 'No categories found. Please add a category first.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String get notePlaceholder => 'e.g. Lunch';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get filterAll => 'All';

  @override
  String get chartNoData => 'No data available for this currency';

  @override
  String get chartTitle => 'Charts';

  @override
  String get filterLast7Days => 'Last 7 Days';

  @override
  String get filterThisWeek => 'This Week';

  @override
  String get filterThisMonth => 'This Month';

  @override
  String get filterPrevMonth => 'Previous Month';

  @override
  String get categoryTitle => 'Categories';

  @override
  String get categoryAddButton => 'Add Category';

  @override
  String get categoryEmpty => 'No categories yet';

  @override
  String get expenseAdded => 'Added';

  @override
  String get chartNoDataForPeriod => 'No expenses for this period';

  @override
  String get categoryAddDialogTitle => 'Add New Category';

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get totalLabel => 'Total';

  @override
  String get totalSpending => 'Total Spending';

  @override
  String get basedOnSelectedFilters => 'Based on selected filters';

  @override
  String get settingsClearDataTitle => 'Delete All Data';

  @override
  String get settingsClearDataMessage => 'All expenses will be permanently deleted. Are you sure?';

  @override
  String get settingsConfirmDelete => 'Yes, delete';

  @override
  String get settingsDataCleared => 'All data has been deleted';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsClearDataListTitle => 'Delete all data';

  @override
  String get settingsClearDataListSubtitle => 'Permanently deletes all expenses';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryEditDialogTitle => 'Edit Category';

  @override
  String get buttonSave => 'Save';

  @override
  String get settingsCurrencyTitle => 'Currency';

  @override
  String get categorySelectIcon => 'Select Icon';

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get drawerReport => 'Report';

  @override
  String get reportTitle => 'Report';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get selectDateRangeHint => 'Please select a date range';

  @override
  String get export => 'Export';

  @override
  String get share => 'Share';

  @override
  String get amountCannotBeZero => 'Amount cannot be zero';

  @override
  String get categoryRequired => 'You must select a category.';

  @override
  String get selectCategoryPlaceholder => 'Select category';

  @override
  String get categoryNameRequired => 'Category name cannot be empty';

  @override
  String get editExpenseTitle => 'Edit Expense';

  @override
  String get expenseUpdated => 'Expense updated';

  @override
  String get buttonSaveChanges => 'Save Changes';

  @override
  String get buttonUpdate => 'Update';

  @override
  String get categoryDeleteTitle => 'Delete category?';

  @override
  String get categoryDeleteMessage => 'This category and all related expenses will be deleted. This action cannot be undone.';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get exportPdf => 'Export as PDF';

  @override
  String get exportExcel => 'Export as Excel';

  @override
  String get close => 'Close';

  @override
  String get reportEmpty => 'No expenses in this date range';

  @override
  String get pdfReportTitle => 'Expense Report';

  @override
  String get pdfCreatedAt => 'Created at';

  @override
  String get pdfReportedBy => 'Reported by MustApp Studio';

  @override
  String get pdfColumnDate => 'Date';

  @override
  String get pdfColumnCategory => 'Category';

  @override
  String get pdfColumnNote => 'Note';

  @override
  String get pdfColumnAmount => 'Amount';

  @override
  String get pdfColumnCurrency => 'Currency';

  @override
  String get pdfTotal => 'TOTAL';

  @override
  String get pdfShareText => 'Expense Report (PDF)';
}
