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
  String get emptyExpenses => 'No expenses added yet';

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
  String get amountLabel => 'Amount (₺)';

  @override
  String get amountRequired => 'Please enter an amount';

  @override
  String get noCategories => 'No categories found. Please add a category first.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String get buttonAdd => 'Add';

  @override
  String get filterAll => 'All';

  @override
  String get chartNoData => 'No expense data available yet';

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
}
