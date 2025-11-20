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
  String get home => 'Home';

  @override
  String get charts => 'Charts';

  @override
  String get categories => 'Categories';

  @override
  String get settings => 'Settings';

  @override
  String get all => 'All';

  @override
  String get total => 'Total';

  @override
  String get addExpense => 'New Expense';

  @override
  String get amount => 'Amount (₺)';

  @override
  String get amountRequired => 'Please enter an amount';

  @override
  String get category => 'Category';

  @override
  String get noCategories => 'No categories found. Please add a category first.';

  @override
  String get note => 'Note (optional)';

  @override
  String get date => 'Date';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Deleted';

  @override
  String get emptyExpenses => 'No expenses added yet';

  @override
  String get emptyExpensesHint => 'Tap the + button below to add your first expense';

  @override
  String get newCategory => 'Add New Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get weekSpend => 'Weekly Spending';

  @override
  String get noData => 'No expense data available';

  @override
  String get noDataPeriod => 'No expenses found for this period';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get thisMonth => 'This Month';

  @override
  String get prevMonth => 'Previous Month';

  @override
  String get resetAll => 'Reset All Data';

  @override
  String get resetConfirmation => 'Delete all data?';

  @override
  String get food => 'Food';

  @override
  String get transport => 'Transport';

  @override
  String get bill => 'Bill';

  @override
  String get market => 'Groceries';

  @override
  String get sortDateDesc => 'Date (Newer > Older)';

  @override
  String get sortDateAsc => 'Date (Older > Newer)';

  @override
  String get sortAmountDesc => 'Amount (High > Low)';

  @override
  String get sortAmountAsc => 'Amount (Low > High)';
}
